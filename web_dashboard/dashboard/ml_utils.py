import os
from catboost import CatBoostClassifier
from django.conf import settings

# Dosyanın tam yolunu klasör yapına göre güncelliyoruz
MODEL_PATH = os.path.join(settings.BASE_DIR, "ml_models", "churn_model.cbm")

model = CatBoostClassifier()

if os.path.exists(MODEL_PATH):
    model.load_model(MODEL_PATH)
    print(f"✅ Başarılı: Model yüklendi -> {MODEL_PATH}")
else:
    print(f"❌ HATA: Model dosyası bulunamadı! Yol: {MODEL_PATH}")

def get_real_prediction(stats):
    # Modelin beklediği liste
    input_features = [
        float(stats.mobile_eft_all_cnt_trend),
        float(stats.cc_transaction_all_cnt_trend),
        float(stats.mobile_eft_all_amt_mean),
        float(stats.cc_transaction_all_amt_mean),
        float(stats.active_product_category_nbr_mean),
        float(stats.months_since_last_txn),
        float(stats.mobile_to_card_ratio_amt),
        float(stats.mobile_eft_all_cnt_trend_3m),
        float(stats.cc_transaction_all_cnt_trend_3m),
        float(stats.mobile_eft_all_cnt_mean_3m)
    ]

    # --- DEBUG SATIRI: Terminalde bu çıktıya bak ---
    print(f"\n>>> MODEL INPUT (55 Müşteri Verisi): {input_features}")
    
    # Olasılık tahmini
    prediction_proba = model.predict_proba([input_features])[0][1]
    
    print(f">>> RAW PROBABILITY: {prediction_proba}\n")
    
    return float(prediction_proba)