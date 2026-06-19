import torch
import torch.nn as nn

class MusicRecommendationModel(nn.Module):
    def __init__(self, sarki_sayisi, embedding_dim=32):
        super().__init__()
        
        # Her şarkı için gizli vektör
        self.sarki_embedding = nn.Embedding(sarki_sayisi, embedding_dim)
        
        # Audio features için katmanlar
        self.audio_katman = nn.Sequential(
            nn.Linear(9, 64),
            nn.ReLU(),
            nn.Linear(64, embedding_dim)
        )
        
        # Son tahmin katmanı
        self.tahmin_katman = nn.Sequential(
            nn.Linear(embedding_dim * 2, 64),
            nn.ReLU(),
            nn.Linear(64, 1),
            nn.Sigmoid()  # 0-1 arası skor

        )
    
    
    def forward(self, sarki_id, audio_features):
        # Şarkının gizli vektörü
        sarki_vec = self.sarki_embedding(sarki_id)
        
        # Audio features'tan vektör
        audio_vec = self.audio_katman(audio_features)
        
        # İkisini birleştir
        combined = torch.cat([sarki_vec, audio_vec], dim=1)
        
        # Skor hesapla
        skor = self.tahmin_katman(combined)
        return skor