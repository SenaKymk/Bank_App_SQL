# Create your models here.
from django.db import models

class Users(models.Model):
    user_id = models.AutoField(primary_key=True)   # AutoField DEĞİL!
    username = models.CharField(max_length=255)
    password = models.CharField(max_length=255)      # STRING olarak tutuyoruz
    role = models.CharField(max_length=50)
    created_at = models.DateField(auto_now_add=True)


    class Meta:
        db_table = "users"

class AuditLogs(models.Model):
    log_id = models.AutoField(primary_key=True)
    admin_user_id = models.IntegerField()
    action = models.CharField(max_length=255)
    table_name = models.CharField(max_length=255)
    row_pk = models.IntegerField()
    description = models.TextField(null=True, blank=True)
    created_at = models.DateField(auto_now_add=True)

    class Meta:
        db_table = 'audit_logs'


class ChurnScoringRequests(models.Model):
    cust_id = models.IntegerField(primary_key=True)
    ref_date = models.DateField()

    class Meta:
        db_table = 'churn_scoring_requests'


class CustomerActivity(models.Model):
    cust_id = models.IntegerField()
    date = models.DateField()
    mobile_eft_all_cnt = models.IntegerField()
    active_product_category_nbr = models.IntegerField()
    mobile_eft_all_amt = models.FloatField()
    cc_transaction_all_amt = models.FloatField()
    cc_transaction_all_cnt = models.IntegerField()

    class Meta:
        db_table = 'customer_activity'


class CustomerChurnLabel(models.Model):
    cust_id = models.IntegerField()
    ref_date = models.DateField()
    churn = models.IntegerField()

    class Meta:
        db_table = 'customer_churn_label'


class CustomerProfile(models.Model):
    cust_id = models.IntegerField(primary_key=True)
    gender = models.CharField(max_length=20)
    age = models.IntegerField()
    province = models.CharField(max_length=100)
    religion = models.CharField(max_length=100)
    work_type = models.CharField(max_length=100)
    work_sector = models.CharField(max_length=100)
    tenure = models.IntegerField()

    class Meta:
        db_table = 'customer_profile'


class CustomerTimeSeriesSummary(models.Model):
    cust_id = models.IntegerField()
    ref_date = models.DateField()

    mobile_eft_all_cnt_trend = models.FloatField()
    cc_transaction_all_cnt_trend = models.FloatField()
    mobile_eft_all_amt_mean = models.FloatField()
    cc_transaction_all_amt_mean = models.FloatField()
    months_since_last_txn = models.IntegerField()
    is_inactive_3m = models.IntegerField()
    active_product_category_nbr_last = models.IntegerField()
    mobile_to_card_ratio_amt = models.FloatField()

    # ---- CORRECTED FIELDS ----
    mobile_eft_all_cnt_mean = models.FloatField()
    active_product_category_nbr_mean = models.FloatField()
    
    mobile_eft_all_amt_mean_all = models.FloatField()        # FIXED
    cc_transaction_all_amt_mean_all = models.FloatField()    # FIXED

    # 3-month metrics
    mobile_eft_all_cnt_trend_3m = models.FloatField()
    cc_transaction_all_cnt_trend_3m = models.FloatField()
    mobile_eft_all_cnt_mean_3m = models.FloatField()
    cc_transaction_all_cnt_mean_3m = models.FloatField()
    active_product_category_nbr_mean_3m = models.IntegerField()
    mobile_eft_all_amt_mean_3m = models.FloatField()
    cc_transaction_all_amt_mean_3m = models.FloatField()

    class Meta:
        db_table = 'customer_time_series_summary'

