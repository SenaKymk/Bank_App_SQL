from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db.models import Sum
from django.db.models.functions import TruncMonth
from datetime import date, datetime
from catboost import CatBoostClassifier
import os
from django.conf import settings
import numpy as np
import pandas as pd

from .models import (
    Users,
    CustomerProfile,
    CustomerActivity,
    CustomerTimeSeriesSummary,
    AuditLogs,
    CustomerChurnLabel,
    ChurnScoringRequests,
)

# Serializer importları
from .serializers import (
    AdminUserSerializer,
    AdminCustomerProfileSerializer,
    AdminLogSerializer
)

@api_view(["GET"])
def get_customer_profile(request, user_id):
    try:
        profile = CustomerProfile.objects.get(cust_id=user_id)
        data = {
            "gender": profile.gender,
            "age": profile.age,
            "province": profile.province,
            "religion": profile.religion,
            "work_type": profile.work_type,
            "work_sector": profile.work_sector,
            "tenure": profile.tenure,
        }
        return Response(data)
    except CustomerProfile.DoesNotExist:
        return Response({"error": "Profile not found"}, status=404)


@api_view(["PUT"])
def update_customer_profile(request, user_id):
    try:
        profile = CustomerProfile.objects.get(cust_id=user_id)

        profile.gender = request.data.get("gender", profile.gender)
        profile.age = request.data.get("age", profile.age)
        profile.province = request.data.get("province", profile.province)
        profile.religion = request.data.get("religion", profile.religion)
        profile.work_type = request.data.get("work_type", profile.work_type)
        profile.work_sector = request.data.get("work_sector", profile.work_sector)
        profile.tenure = request.data.get("tenure", profile.tenure)

        profile.save()
        return Response({"status": "success"})
    except CustomerProfile.DoesNotExist:
        return Response({"error": "Profile not found"}, status=404)

@api_view(['POST'])
def login(request):
    user_id = request.data.get("user_id")
    password = request.data.get("password")

    try:
        user = Users.objects.get(user_id=int(user_id), password=str(password))
        return Response({
            "status": "success",
            "user_id": user.user_id,
            "username": user.username,
            "role": user.role
        })
    except Users.DoesNotExist:
        return Response({
            "status": "error",
            "message": "Invalid credentials"
        }, status=400)

@api_view(['GET'])
def customer_trend(request, cust_id):
    try:
        summary = CustomerTimeSeriesSummary.objects.get(cust_id=cust_id)
        return Response({
            "mobile_eft_trend": summary.mobile_eft_all_cnt_trend,
            "cc_cnt_trend": summary.cc_transaction_all_cnt_trend,
            "mobile_mean": summary.mobile_eft_all_amt_mean,
            "cc_mean": summary.cc_transaction_all_amt_mean,
            "months_inactive": summary.months_since_last_txn,
            "product_last": summary.active_product_category_nbr_last,
            "ratio": summary.mobile_to_card_ratio_amt,
            "mobile_trend_3m": summary.mobile_eft_all_cnt_trend_3m,
            "cc_trend_3m": summary.cc_transaction_all_cnt_trend_3m,
        })
    except CustomerTimeSeriesSummary.DoesNotExist:
        return Response({"error": "Trend data not found"}, status=404)

        




@api_view(["GET"])
def get_customer_months(request, user_id):
    """
    Kullanıcının işlem yaptığı AYLARI döndürür.
    Örn: ["2024-01", "2024-02"]
    """

    months = (
        CustomerActivity.objects
        .filter(cust_id=user_id)
        .annotate(month=TruncMonth("date"))
        .order_by("month")
        .values_list("month", flat=True)
        .distinct()
    )

    month_strings = [m.strftime("%Y-%m") for m in months]

    return Response(month_strings)


@api_view(["GET"])
def customer_monthly_timeseries(request, user_id):
    """
    Müşterinin aylık EFT ve Kart işlem sayılarını döndürür.
    Flutter line chart buradaki veriyi kullanıyor.
    """
    records = (
        CustomerActivity.objects
        .filter(cust_id=user_id)
        .annotate(month=TruncMonth("date"))
        .values("month")
        .annotate(
            eft_cnt=Sum("mobile_eft_all_cnt"),
            card_cnt=Sum("cc_transaction_all_cnt")
        )
        .order_by("month")
    )

    result = []
    for r in records:
        result.append({
            "month": r["month"].strftime("%Y-%m"),
            "eft_cnt": r["eft_cnt"] or 0,
            "card_cnt": r["card_cnt"] or 0
        })

    return Response(result)



@api_view(["GET"])
def get_monthly_usage(request, user_id):
    """
    Seçilen ay için toplam hareketleri döndürür.
    /api/customer_monthly_usage/7?month=2025-01
    """

    month = request.GET.get("month")   # "2025-01" gelir

    if not month:
        return Response({"error": "Month parameter is required"}, status=400)

    # Örn: 2025-01 => yıl 2025, ay 1
    year, month_num = map(int, month.split("-"))

    records = CustomerActivity.objects.filter(
        cust_id=user_id,
        date__year=year,
        date__month=month_num
    )

    if not records.exists():
        return Response({"error": "No data found for this month"}, status=404)

    summary = records.aggregate(
    total_mobile_eft_amt=Sum("mobile_eft_all_amt") or 0,
    total_mobile_eft_cnt=Sum("mobile_eft_all_cnt") or 0,
    total_cc_amt=Sum("cc_transaction_all_amt") or 0,
    total_cc_cnt=Sum("cc_transaction_all_cnt") or 0,
)

    return Response(summary)

@api_view(['POST'])
def register(request):

    # 1 — Flutter'dan gelen bilgiler
    username = request.data.get("username")
    password = request.data.get("password")
    gender = request.data.get("gender")
    age = request.data.get("age")
    province = request.data.get("province")
    religion = request.data.get("religion")
    work_type = request.data.get("work_type")
    work_sector = request.data.get("work_sector")
    tenure = request.data.get("tenure")

    # 2 — Users tablosuna kayıt
    user = Users.objects.create(
        username=username,
        password=password,
        role="customer",
        created_at=date.today()
    )

    cust_id = user.user_id

    # 3 — Customer Profile tablosuna kayıt
    CustomerProfile.objects.create(
        cust_id=cust_id,
        gender=gender,
        age=age,
        province=province,
        religion=religion,
        work_type=work_type,
        work_sector=work_sector,
        tenure=tenure
    )

    # 4 — Customer Activity tablosuna boş kayıt
    CustomerActivity.objects.create(
        cust_id=cust_id,
        date=date.today(),
        mobile_eft_all_cnt=0,
        active_product_category_nbr=0,
        mobile_eft_all_amt=0.0,
        cc_transaction_all_amt=0.0,
        cc_transaction_all_cnt=0
    )

    # 5 — Customer Time Series Summary boş kayıt
    CustomerTimeSeriesSummary.objects.create(
    cust_id=cust_id,
    ref_date=date.today(),

    mobile_eft_all_cnt_trend=0,
    cc_transaction_all_cnt_trend=0,

    mobile_eft_all_amt_mean=0,
    cc_transaction_all_amt_mean=0,

    months_since_last_txn=0,
    is_inactive_3m=1,
    active_product_category_nbr_last=0,
    mobile_to_card_ratio_amt=0,

    mobile_eft_all_cnt_mean=0,
    active_product_category_nbr_mean=0,

    mobile_eft_all_amt_mean_all=0,
    cc_transaction_all_amt_mean_all=0,

    mobile_eft_all_cnt_trend_3m=0,
    cc_transaction_all_cnt_trend_3m=0,

    mobile_eft_all_cnt_mean_3m=0,
    cc_transaction_all_cnt_mean_3m=0,

    mobile_eft_all_amt_mean_3m=0,
    cc_transaction_all_amt_mean_3m=0
    )

    # 6 — Audit Log kaydı
    AuditLogs.objects.create(
        admin_user_id=0,
        action="REGISTER_NEW_USER",
        table_name="users",
        row_pk=cust_id,
        description=f"New customer registered: {username}",
        created_at=datetime.now()
    )

    # 7 — Flutter'a başarı cevabı
    return Response({
        "status": "success",
        "message": "Customer successfully registered",
        "user_id": cust_id
    })

@api_view(["GET"])
def admin_customer_list(request):
    users = Users.objects.filter(role="customer").values("user_id", "username", "created_at")
    return Response(list(users))


@api_view(["GET"])
def admin_customer_detail(request, user_id):
    try:
        user = Users.objects.get(user_id=user_id)
    except Users.DoesNotExist:
        return Response({"error": "User not found"}, status=404)

    try:
        profile = CustomerProfile.objects.get(cust_id=user_id)
        profile_data = {
            "gender": profile.gender,
            "age": profile.age,
            "province": profile.province,
            "religion": profile.religion,
            "work_type": profile.work_type,
            "work_sector": profile.work_sector,
            "tenure": profile.tenure,
        }
    except CustomerProfile.DoesNotExist:
        profile_data = None

    # Aktivite özeti
    usage = CustomerActivity.objects.filter(cust_id=user_id).aggregate(
        total_eft=Sum("mobile_eft_all_cnt"),
        total_card=Sum("cc_transaction_all_cnt"),
        total_amt_eft=Sum("mobile_eft_all_amt"),
        total_amt_card=Sum("cc_transaction_all_amt"),
    )

    return Response({
        "user": {
            "user_id": user.user_id,
            "username": user.username,
            "role": user.role,
            "created_at": user.created_at
        },
        "profile": profile_data,
        "usage": usage
    })

@api_view(["PUT"])
def admin_update_customer(request, user_id):
    try:
        profile = CustomerProfile.objects.get(cust_id=user_id)
    except CustomerProfile.DoesNotExist:
        return Response({"error": "Profile not found"}, status=404)

    for field in ["gender", "age", "province", "religion", "work_type", "work_sector", "tenure"]:
        if field in request.data:
            setattr(profile, field, request.data[field])

    profile.save()

    # Log
    AuditLogs.objects.create(
        admin_user_id=0,   # istersen burada admin id ekle
        action="ADMIN_UPDATE_CUSTOMER",
        table_name="CustomerProfile",
        row_pk=user_id,
        description=f"Admin updated customer #{user_id}"
    )

    return Response({"status": "success"})

@api_view(["DELETE"])
def admin_delete_customer(request, user_id):
    try:
        Users.objects.get(user_id=user_id).delete()
        CustomerProfile.objects.filter(cust_id=user_id).delete()
        CustomerActivity.objects.filter(cust_id=user_id).delete()
        CustomerTimeSeriesSummary.objects.filter(cust_id=user_id).delete()
    except:
        return Response({"error": "User not found"}, status=404)

    AuditLogs.objects.create(
        admin_user_id=0,
        action="ADMIN_DELETE_CUSTOMER",
        table_name="ALL",
        row_pk=user_id,
        description=f"Admin deleted customer #{user_id}"
    )

    return Response({"status": "success"})


@api_view(["GET"])
def admin_logs(request):
    logs = AuditLogs.objects.order_by("-created_at").values()
    return Response(list(logs))

# ==========================
# CHURN MODEL LOAD (GLOBAL)
# ==========================

MODEL_PATH = os.path.join(
    settings.BASE_DIR,
    "api",
    "model",
    "churn_model.cbm"
)

churn_model = CatBoostClassifier()
churn_model.load_model(MODEL_PATH)

@api_view(["POST"])
def predict_churn(request, user_id):
    try:
        summary = CustomerTimeSeriesSummary.objects.get(cust_id=user_id)
    except CustomerTimeSeriesSummary.DoesNotExist:
        return Response({"error": "Feature data not found"}, status=404)

    # --- Feature vector ---
    X = pd.DataFrame([{
        "mobile_eft_all_cnt_trend": summary.mobile_eft_all_cnt_trend,
        "cc_transaction_all_cnt_trend": summary.cc_transaction_all_cnt_trend,
        "mobile_eft_all_amt_mean": summary.mobile_eft_all_amt_mean,
        "cc_transaction_all_amt_mean": summary.cc_transaction_all_amt_mean,
        "active_product_category_nbr_mean": summary.active_product_category_nbr_mean,
        "months_since_last_txn": summary.months_since_last_txn,
        "mobile_to_card_ratio_amt": summary.mobile_to_card_ratio_amt,
        "mobile_eft_all_cnt_trend_3m": summary.mobile_eft_all_cnt_trend_3m,
        "cc_transaction_all_cnt_trend_3m": summary.cc_transaction_all_cnt_trend_3m,
        "mobile_eft_all_cnt_mean_3m": summary.mobile_eft_all_cnt_mean_3m,
    }])

    churn_prob = churn_model.predict_proba(X)[0][1]
    churn_pct = round(churn_prob *100, 2)

    if churn_pct >= 60:
        risk = "HIGH"
        churn_label = 1
    elif churn_pct >= 30:
        risk = "MEDIUM"
        churn_label = 1
    else:
        risk = "LOW"
        churn_label = 0


    ref_date = summary.ref_date

    # --- Churn Label Update ---
    CustomerChurnLabel.objects.update_or_create(
        cust_id=user_id,
        ref_date=ref_date,
        defaults={"churn": churn_label}
    )

    # --- Churn Request Log ---
    ChurnScoringRequests.objects.update_or_create(
        cust_id=user_id,
        defaults={"ref_date": ref_date}
    )

    # --- Audit Log ---
    AuditLogs.objects.create(
        admin_user_id=0,
        action="CHURN_PREDICTION",
        table_name="customer_churn_label",
        row_pk=user_id,
        description=f"Admin churn prediction for customer #{user_id} | Risk={risk}"
    )

    return Response({
        "churn_probability": churn_pct,
        "risk": risk,
        "label": churn_label,
        "ref_date": str(ref_date)
    })


