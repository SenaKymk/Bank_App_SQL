from django.db import models

# Ana Müşteri Tablosu
class Customer(models.Model):
    cust_id = models.IntegerField(unique=True, primary_key=True)
    gender = models.CharField(max_length=10)
    age = models.IntegerField()
    province = models.CharField(max_length=100)
    work_sector = models.CharField(max_length=100, null=True, blank=True)
    tenure = models.IntegerField()
    risk_score = models.IntegerField(default=0)
    churn_prob = models.FloatField(default=0.0)
    churn_risk = models.CharField(max_length=10, default="Low")

    def __str__(self):
        return f"Müşteri {self.cust_id}"

# Müşteri Aktiviteleri
class CustomerActivity(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='activities')
    activity_date = models.DateField()
    # CSV'ye uygun hale getirildi
    mobile_eft_all_cnt = models.FloatField(default=0)
    active_product_category_nbr = models.IntegerField(default=0)
    mobile_eft_all_amt = models.FloatField(default=0)
    cc_transaction_all_amt = models.FloatField(default=0)
    cc_transaction_all_cnt = models.FloatField(default=0)

# Zaman Serisi Özeti (ML Modelinin Beslendiği Tablo)
class TimeSeriesSummary(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    month_ref = models.DateField()
    
    # ML Feature Sütunları (Eksik olanlar eklendi)
    mobile_eft_all_cnt_trend = models.FloatField(default=0.0)
    cc_transaction_all_cnt_trend = models.FloatField(default=0.0)
    mobile_eft_all_amt_mean = models.FloatField(default=0.0)
    cc_transaction_all_amt_mean = models.FloatField(default=0.0)
    active_product_category_nbr_mean = models.FloatField(default=0.0)
    months_since_last_txn = models.FloatField(default=0.0)
    mobile_to_card_ratio_amt = models.FloatField(default=0.0)
    mobile_eft_all_cnt_trend_3m = models.FloatField(default=0.0)
    cc_transaction_all_cnt_trend_3m = models.FloatField(default=0.0)
    mobile_eft_all_cnt_mean_3m = models.FloatField(default=0.0)

# Denetim Kayıtları
class AuditLog(models.Model):
    action_type = models.CharField(max_length=50)
    done_by = models.CharField(max_length=100)
    action_date = models.DateTimeField(auto_now_add=True)
    table_affected = models.CharField(max_length=50)
    description = models.TextField(null=True, blank=True)