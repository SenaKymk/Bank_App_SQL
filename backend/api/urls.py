from django.urls import path
from .views import (
    login,
    register,
    customer_trend,
    customer_monthly_timeseries,
    get_customer_profile,
    admin_logs,
    update_customer_profile,
    get_customer_months,
    get_monthly_usage,
    admin_customer_list,
    admin_customer_detail,
    admin_update_customer,
    admin_delete_customer,
    predict_churn,
)

urlpatterns = [
    path('login/', login),
    path("register/", register),
    path('customer_trend/<int:cust_id>/',customer_trend),
    path('customer_profile/<int:user_id>/', get_customer_profile , name="customer_profile"),
    path('customer_profile/<int:user_id>/update/', update_customer_profile , name="customer_profile_update"),
    path("customer_months/<int:user_id>/", get_customer_months),
    path("customer_monthly_usage/<int:user_id>/", get_monthly_usage),
    path("api/customer_monthly_timeseries/<int:user_id>/", customer_monthly_timeseries),
    path("admin/logs/", admin_logs),
    path("admin/customers/", admin_customer_list),
    path("admin/customer/<int:user_id>/", admin_customer_detail),
    path("admin/customer/<int:user_id>/update/", admin_update_customer),
    path("admin/delete/<int:user_id>/", admin_delete_customer, name="admin_delete_customer"),
    path("admin/predict/<int:user_id>/", predict_churn),









]
