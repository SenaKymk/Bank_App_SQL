import csv
import random
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.db.models import Q, Avg
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_POST
from .ml_utils import get_real_prediction
# Tüm modelleriniz
from .models import Customer, CustomerActivity, TimeSeriesSummary, AuditLog

# 1. DASHBOARD
@login_required(login_url="/login/")
def dashboard_view(request):
    customers = Customer.objects.all()
    avg_risk = customers.aggregate(Avg('risk_score'))['risk_score__avg'] or 0
    
    context = {
        "total_customers": customers.count(),
        "high_risk_count": customers.filter(churn_risk="High").count(),
        "medium_risk_count": customers.filter(churn_risk="Medium").count(),
        "low_risk_count": customers.filter(churn_risk="Low").count(),
        "avg_risk_score": round(avg_risk, 1),
        "high_risk_customers": customers.filter(churn_risk="High").order_by("-risk_score")[:5],
        "recent_activities": AuditLog.objects.all().order_by('-action_date')[:5],
    }
    return render(request, "dashboard/dashboard.html", context)

# 2. CUSTOMER LIST
@login_required(login_url="/login/")
def customer_list_view(request):
    customers = Customer.objects.all().order_by("cust_id")
    q = (request.GET.get("q") or "").strip()
    risk_filter = (request.GET.get("risk") or "").strip()

    if q:
        query_filter = Q(province__icontains=q) | Q(work_sector__icontains=q)
        if q.isdigit():
            query_filter |= Q(cust_id=int(q))
        customers = customers.filter(query_filter)

    if risk_filter in ["High", "Medium", "Low"]:
        customers = customers.filter(churn_risk=risk_filter)

    paginator = Paginator(customers, 10)
    page = request.GET.get("page")
    customers_page = paginator.get_page(page)

    return render(request, "dashboard/customer_list.html", {
        "customers": customers_page,
        "total_count": customers.count(),
        "search_query": q,
        "risk_filter": risk_filter,
    })

# 3. CUSTOMER DETAIL
@login_required(login_url="/login/")
def customer_detail_view(request, cust_id):
    customer = get_object_or_404(Customer, cust_id=cust_id)
    activities = CustomerActivity.objects.filter(customer=customer).order_by('-activity_date')[:10]
    time_series = TimeSeriesSummary.objects.filter(customer=customer).order_by('-month_ref')
    
    health_score = 100 - customer.risk_score

    context = {
        "profile": customer,
        "activities": activities,
        "time_series": time_series,
        "churn": {
            "risk": customer.churn_risk,
            "score": customer.risk_score,
            "probability": customer.churn_prob,
            "health_score": health_score,
        }
    }
    return render(request, "dashboard/customer_detail.html", context)

# 4. PREDICT (Tekli Tahmin Güncellemesi)
@login_required(login_url="/login/")
def customer_predict_view(request, cust_id):
    customer = get_object_or_404(Customer, cust_id=cust_id)
    
    # Tarihe göre en güncel analiz verisini çekiyoruz
    stats = TimeSeriesSummary.objects.filter(customer=customer).order_by('-month_ref').first()
    
    if stats:
        # ML_UTILS'den gelen ham olasılık (Örn: 0.1274)
        prob = get_real_prediction(stats)
        
        # Olasılığı 100 ile çarpıp tam sayıya çeviriyoruz (Örn: 12)
        score = int(float(prob) * 100)
        
        # Müşteri objesini güncelliyoruz
        customer.risk_score = score
        customer.churn_prob = float(prob)
        
        # Risk kategorisi belirleme (Sınır değerlerini buradan ayarlayabilirsin)
        if score >= 15:
            customer.churn_risk = "High"
        elif score >= 5:
            customer.churn_risk = "Medium"
        else:
            customer.churn_risk = "Low"
            
        # VERİTABANINA ZORLA KAYDET
        customer.save(update_fields=['risk_score', 'churn_prob', 'churn_risk'])
        
        AuditLog.objects.create(
            action_type="PREDICT", 
            done_by=request.user.username, 
            table_affected="Customer", 
            description=f"AI Tahmini yapıldı. Müşteri: {cust_id}, Skor: %{score}"
        )
        messages.success(request, f"AI Tahmini Güncellendi: %{score}")
    else:
        messages.error(request, "Bu müşteri için analiz verisi (TimeSeriesSummary) bulunamadı.")
        
    return redirect("customer_detail", cust_id=cust_id)

# 5. BATCH PREDICTION (Toplu Tahmin)
@login_required(login_url="/login/")
def batch_prediction_view(request):
    customers = Customer.objects.all()
    count = 0
    for customer in customers:
        stats = TimeSeriesSummary.objects.filter(customer=customer).order_by('-month_ref').first()
        if stats:
            prob = get_real_prediction(stats)
            score = int(float(prob) * 100)
            
            customer.risk_score = score
            customer.churn_prob = float(prob)
            
            if score >= 15:
                customer.churn_risk = "High"
            elif score >= 5:
                customer.churn_risk = "Medium"
            else:
                customer.churn_risk = "Low"
                
            customer.save(update_fields=['risk_score', 'churn_prob', 'churn_risk'])
            count += 1
    
    messages.success(request, f"{count} müşteri için toplu tahmin başarıyla tamamlandı.")
    return redirect("dashboard")

    

# 6. EXPORT REPORT
@login_required(login_url="/login/")
def export_report_view(request):
    customers = Customer.objects.all().order_by("cust_id")
    response = HttpResponse(content_type="text/csv")
    response["Content-Disposition"] = 'attachment; filename="customers_report.csv"'

    writer = csv.writer(response)
    writer.writerow(["ID", "Age", "Gender", "Province", "Sector", "Risk", "Score"])
    for c in customers:
        writer.writerow([c.cust_id, c.age, c.gender, c.province, c.work_sector, c.churn_risk, c.risk_score])
    
    return response

# 7. DELETE
@login_required(login_url="/login/")
@require_POST
def customer_delete_view(request, cust_id):
    customer = get_object_or_404(Customer, cust_id=cust_id)
    customer.delete()
    messages.success(request, "Deleted.")
    return redirect("customer_list")

# 8. EDIT
# views.py içinde güvenli kaydetme yöntemi
@login_required(login_url="/login/")
def customer_edit_view(request, cust_id):
    customer = get_object_or_404(Customer, cust_id=cust_id)
    if request.method == "POST":
        customer.province = request.POST.get("province", customer.province)
        customer.work_sector = request.POST.get("work_sector", customer.work_sector)
        
        new_age = request.POST.get("age")
        if new_age and new_age.strip():
            # Sadece geçerli bir sayı girilirse güncelle
            customer.age = int(new_age)
        
        # Bu satır değişikliği MySQL'e kalıcı olarak işler
        customer.save() 
        messages.success(request, f"Müşteri #{cust_id} veritabanında güncellendi.")
        return redirect("customer_detail", cust_id=cust_id)
    
    return render(request, "dashboard/customer_edit.html", {"profile": customer})