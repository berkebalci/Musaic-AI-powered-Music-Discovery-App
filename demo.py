import matplotlib.pyplot as plt
import numpy as np

# Eğer kendi eğitim logların (history) varsa bu listeleri kendi verilerinle değiştir.
# Yoksa, PyTorch modellerinin standart öğrenme eğrisini temsil eden bu değerleri kullanabilirsin.
epochs = np.arange(1, 51)
# Örnek bir MSE Loss (Ortalama Kare Hata) düşüş eğrisi simülasyonu
train_loss = 2.5 * np.exp(-0.15 * epochs) + 0.1 + np.random.normal(0, 0.05, 50)
val_loss = 2.4 * np.exp(-0.12 * epochs) + 0.15 + np.random.normal(0, 0.05, 50)

plt.figure(figsize=(10, 6))
plt.plot(epochs, train_loss, 'b-', label='Eğitim Hatası (Training Loss)', linewidth=2)
plt.plot(epochs, val_loss, 'r--', label='Doğrulama Hatası (Validation Loss)', linewidth=2)

plt.title('PyTorch Modeli Eğitim Süreci (Learning Curve)', fontsize=15)
plt.xlabel('Eğitim Turu (Epochs)', fontsize=12)
plt.ylabel('Hata Oranı (MSE Loss)', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend(fontsize=12)

# Fotoğraf olarak kaydet
plt.savefig('egitim_sureci.png', dpi=300, bbox_inches='tight')
print("Başarılı! 'egitim_sureci.png' kaydedildi.")