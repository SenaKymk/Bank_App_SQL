from rest_framework.decorators import api_view
from rest_framework.response import Response
from datetime import date, datetime
from .models import (
    Users,
    CustomerProfile,
    CustomerActivity,
    CustomerTimeSeriesSummary,
    AuditLogs
)

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
