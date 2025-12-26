from django.contrib import admin
from .models import Customer, CustomerActivity, TimeSeriesSummary, AuditLog

# Müşteri detay sayfasında aktiviteleri alt liste olarak görmek için
class CustomerActivityInline(admin.TabularInline):
    model = CustomerActivity
    extra = 0
    # Eski activity_type silindi, yerine CSV'deki gerçek sütunlardan birkaçı eklendi
    fields = ('activity_date', 'mobile_eft_all_cnt', 'cc_transaction_all_cnt', 'active_product_category_nbr')
    readonly_fields = ('activity_date',)

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    # list_display: Tablo listesinde görünecek sütunlar
    list_display = ('cust_id', 'province', 'age', 'work_sector', 'tenure', 'churn_risk', 'risk_score')
    list_filter = ('churn_risk', 'province', 'gender')
    search_fields = ('cust_id', 'province')
    inlines = [CustomerActivityInline]

@admin.register(CustomerActivity)
class CustomerActivityAdmin(admin.ModelAdmin):
    # Yeni modeldeki alanlar eklendi
    list_display = ('customer', 'activity_date', 'mobile_eft_all_cnt', 'cc_transaction_all_cnt', 'active_product_category_nbr')
    list_filter = ('activity_date',)

@admin.register(TimeSeriesSummary)
class TimeSeriesSummaryAdmin(admin.ModelAdmin):
    # ML Feature'larının birkaçını listeye ekleyelim
    list_display = ('customer', 'month_ref', 'mobile_eft_all_cnt_trend', 'cc_transaction_all_cnt_trend', 'months_since_last_txn')
    list_filter = ('month_ref',)
    search_fields = ('customer__cust_id',)

@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ('action_type', 'done_by', 'action_date', 'table_affected')
    readonly_fields = ('action_date',)