import os
import csv
import django
import sys

# Django ayarlarını yükle
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings') 
django.setup()

from dashboard.models import Customer, TimeSeriesSummary

def load_data():
    base_path = os.path.dirname(os.path.abspath(__file__))
    
    # 1. Müşteri Profillerini Yükle
    profile_path = os.path.join(base_path, 'customer_profile.csv')
    print("Müşteri profilleri yükleniyor...")
    with open(profile_path, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Sütun isimlerindeki olası boşlukları temizle
            row = {k.strip(): v for k, v in row.items()}
            Customer.objects.update_or_create(
                cust_id=row['cust_id'],
                defaults={
                    'gender': row.get('gender', 'Unknown'),
                    'age': int(row.get('age', 0)),
                    'province': row.get('province', 'Unknown'),
                    'work_sector': row.get('work_sector', 'Other'),
                    'tenure': int(row.get('tenure', 0)),
                    'risk_score': 0,
                    'churn_risk': 'Low'
                }
            )
    print("✅ 1. Adım Tamam: 55 Müşteri MySQL'e eklendi.")
    
    # 2. ML Verilerini (Zaman Serisi Özeti) Yükle
    summary_path = os.path.join(base_path, 'customer_time_series_summary.csv')
    print("ML verileri yükleniyor...")
    with open(summary_path, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        count = 0
        for row in reader:
            row = {k.strip(): v for k, v in row.items()} # Sütunları temizle
            try:
                customer = Customer.objects.get(cust_id=row['cust_id'])
                TimeSeriesSummary.objects.update_or_create(
                    customer=customer,
                    month_ref=row['ref_date'],
                    defaults={
                        'mobile_eft_all_cnt_trend': float(row.get('mobile_eft_all_cnt_trend', 0)),
                        'cc_transaction_all_cnt_trend': float(row.get('cc_transaction_all_cnt_trend', 0)),
                        'mobile_eft_all_amt_mean': float(row.get('mobile_eft_all_amt_mean', 0)),
                        'cc_transaction_all_amt_mean': float(row.get('cc_transaction_all_amt_mean', 0)),
                        'active_product_category_nbr_mean': float(row.get('active_product_category_nbr_mean', 0)),
                        'months_since_last_txn': float(row.get('months_since_last_txn', 0)),
                        'mobile_to_card_ratio_amt': float(row.get('mobile_to_card_ratio_amt', 0)),
                        'mobile_eft_all_cnt_trend_3m': float(row.get('mobile_eft_all_cnt_trend_3m', 0)),
                        'cc_transaction_all_cnt_trend_3m': float(row.get('cc_transaction_all_cnt_trend_3m', 0)),
                        'mobile_eft_all_cnt_mean_3m': float(row.get('mobile_eft_all_cnt_mean_3m', 0)),
                    }
                )
                count += 1
            except Exception as e:
                continue
    print(f"✅ 2. Adım Tamam: {count} adet ML verisi MySQL'e eklendi.")
    print("\n[BAŞARILI] Tüm veriler MySQL'de! Paneli açabilirsin.")

if __name__ == "__main__":
    load_data()