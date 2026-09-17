import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA

print("📊 Tez grafikleri hazırlanıyor, lütfen bekleyin...")

# 1. Verileri Yükle
df = pd.read_csv('models/df_clean.csv')
X_scaled = np.load('models/X_scaled.npy')

features = ['danceability', 'energy', 'valence', 'tempo', 
            'acousticness', 'instrumentalness', 'speechiness', 'loudness', 'liveness']

# Yüksek çözünürlük ayarı (Akademik tezler için 300 dpi idealdir)
sns.set_theme(style="whitegrid")

# ---------------------------------------------------------
# GRAFİK 1: ÖZNİTELİK DAĞILIM GRAFİKLERİ (HİSTOGRAMLAR)
# ---------------------------------------------------------
print("1/3: Histogramlar çiziliyor...")
plt.figure(figsize=(15, 10))
for i, col in enumerate(features):
    plt.subplot(3, 3, i+1)
    sns.histplot(df[col], bins=30, kde=True, color='teal')
    plt.title(f'{col.capitalize()} Dağılımı', fontsize=12, fontweight='bold')
    plt.xlabel('Değer')
    plt.ylabel('Frekans')

plt.tight_layout()
plt.savefig('tez_grafik_1_dagilim.png', dpi=300)
plt.close()

# ---------------------------------------------------------
# GRAFİK 2: KORELASYON ISI HARİTASI (HEATMAP)
# ---------------------------------------------------------
print("2/3: Isı Haritası çiziliyor...")
plt.figure(figsize=(10, 8))
corr_matrix = df[features].corr()
sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
plt.title('Akustik Özellikler Arası Korelasyon Isı Haritası', fontsize=14, fontweight='bold', pad=20)
plt.tight_layout()
plt.savefig('tez_grafik_2_korelasyon.png', dpi=300)
plt.close()

# ---------------------------------------------------------
# GRAFİK 3: VEKTÖR UZAYI VE ÖNERİ SİMÜLASYONU (PCA SCATTER PLOT)
# ---------------------------------------------------------
print("3/3: Vektör Uzayı Kümelenmesi çiziliyor...")
# 9 boyutu insan gözünün görebilmesi için PCA ile 2 boyuta indirgiyoruz
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled)

# Örnek bir hedef vektör (Hüzünlü/Akustik Mod) ve en yakın 15 şarkıyı bulalım
hedef_vektor = np.array([0.25, 0.20, 0.10, 0.30, 0.85, 0.15, 0.05, 0.25, 0.15])
mesafeler = np.linalg.norm(X_scaled - hedef_vektor, axis=1)
en_yakin_15_idx = mesafeler.argsort()[:15]

# Hedef vektörü de 2 boyuta indirge
hedef_pca = pca.transform([hedef_vektor])

plt.figure(figsize=(12, 8))
# Arka plandaki tüm 88.000 şarkı
plt.scatter(X_pca[:, 0], X_pca[:, 1], alpha=0.05, color='gray', s=5, label='Veri Setindeki Şarkılar')

# Seçilen ilk 15 şarkı
plt.scatter(X_pca[en_yakin_15_idx, 0], X_pca[en_yakin_15_idx, 1], 
            color='limegreen', s=100, edgecolor='black', zorder=5, label='Önerilen En İyi 15 Şarkı')

# Gemini'den gelen hedef vektör
plt.scatter(hedef_pca[:, 0], hedef_pca[:, 1], 
            color='red', marker='*', s=400, edgecolor='black', zorder=10, label='Hedef Vektör (Kullanıcı İsteği)')

plt.title('PCA ile Boyut İndirgeme ve Öklid Mesafe Simülasyonu', fontsize=14, fontweight='bold')
plt.xlabel('Temel Bileşen 1 (PCA 1)')
plt.ylabel('Temel Bileşen 2 (PCA 2)')
plt.legend()
plt.tight_layout()
plt.savefig('tez_grafik_3_vektor_uzayi.png', dpi=300)
plt.close()

print("✅ BÜTÜN GRAFİKLER BAŞARIYLA KAYDEDİLDİ!")