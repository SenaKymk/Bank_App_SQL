from django.urls import path
from . import views

urlpatterns = [
    # Ana Dashboard
    path("", views.dashboard_view, name="dashboard"),
    
    # Müşteri Yönetimi
    path("customers/", views.customer_list_view, name="customer_list"),
    path("customers/<int:cust_id>/", views.customer_detail_view, name="customer_detail"),
    path("customers/<int:cust_id>/edit/", views.customer_edit_view, name="customer_edit"),
    path("customers/<int:cust_id>/delete/", views.customer_delete_view, name="customer_delete"),
    
    # Analitik İşlemler (AI Model Entegrasyonu)
    # Bu URL hem butona basınca çalışır hem de Flutter'dan GET isteği atılabilir.
    path("customers/<int:cust_id>/predict/", views.customer_predict_view, name="customer_predict"),
    path("batch-prediction/", views.batch_prediction_view, name="batch_prediction"),
    
    # Veri Raporlama (Dışa Aktarma)
    path("export-report/", views.export_report_view, name="export_report"),
]