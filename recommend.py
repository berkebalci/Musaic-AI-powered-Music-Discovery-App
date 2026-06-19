import torch
import numpy as np
import pandas as pd
from model import MusicRecommendationModel

class RecommendationEngine:
    def __init__(self):
        print("Loading PyTorch model...")
        
        self.df = pd.read_csv('models/df_clean.csv')
        
        if 'song_id' not in self.df.columns:
            self.df['song_id'] = self.df.index
            
        self.X_scaled = np.load('models/X_scaled.npy')
        
        self.model = MusicRecommendationModel(sarki_sayisi=len(self.df))
        self.model.load_state_dict(
            torch.load('models/model.pt', map_location='cpu')
        )
        self.model.eval()
        
        self.features = [
            'danceability', 'energy', 'valence', 'tempo',
            'acousticness', 'instrumentalness',
            'speechiness', 'loudness', 'liveness'
        ]
        
        print(f"Ready — {len(self.df)} songs loaded with Deep Learning engine.")
        
        print("Caching PyTorch base scores...")
        self.cached_model_scores = self._get_model_scores()
        print("Base scores cached successfully.")
       

    def _get_model_scores(self):
        with torch.no_grad():
            all_indices = torch.arange(len(self.df))
            audio_features = torch.tensor(
                self.X_scaled, dtype=torch.float32
            )
            scores = self.model(all_indices, audio_features).squeeze()
            return scores.numpy()

    def _calculate_similarity(self, target_vector):
       # 1. Hedef vektör ile tüm şarkılar arasındaki gerçek mesafeyi ölç
        distances = np.linalg.norm(self.X_scaled - target_vector, axis=1)
        
        # DİNAMİK MİN-MAX ÖLÇEKLEME (Sabit bir üst sınır yerine veri setine göre esneme)
        min_dist = distances.min()
        max_dist = distances.max()
        
        # Eğer bir hata olur da tüm mesafeler aynı çıkarsa (Sıfıra bölünme hatasını engellemek için)
        if max_dist == min_dist:
            return np.ones_like(distances)
            
        # 3. En yakın şarkıyı 1.0 (%100), en uzak şarkıyı 0.0 (%0) olacak şekilde dağıt
        similarities = 1.0 - ((distances - min_dist) / (max_dist - min_dist))
        
        return similarities

    def update_batch_mood_vector(self, current_vector, liked_ids, disliked_ids, alpha=0.15, beta=0.05):
        """
        PyTorch X_scaled verilerini kullanarak EMA (Exponential Moving Average) 
        mantığıyla ruh hali vektörünü günceller.
        """
        current = np.array(current_vector)
        
        # --- BEĞENİLENLER (EMA ÇEKİM) ---
        if liked_ids:
            # Pandas index'lerini bulup Numpy array'inden vektörleri çekiyoruz
            liked_indices = self.df[self.df['song_id'].isin(liked_ids)].index
            if len(liked_indices) > 0:
                liked_vectors = self.X_scaled[liked_indices]
                liked_mean = np.mean(liked_vectors, axis=0)
                current = current + alpha * (liked_mean - current)
                
        # --- BEĞENİLMEYENLER (TERSİNE EMA ÇEKİM) ---
        if disliked_ids:
            disliked_indices = self.df[self.df['song_id'].isin(disliked_ids)].index
            if len(disliked_indices) > 0:
                disliked_vectors = self.X_scaled[disliked_indices]
                disliked_mean = np.mean(disliked_vectors, axis=0)
                inverse_target = 1.0 - disliked_mean
                current = current + beta * (inverse_target - current)
                
        current = np.clip(current, 0.0, 1.0)
        return current.tolist()

    def recommend(self, mood_vector=None, liked_indices=[], disliked_indices=[], n=15):
        # 1. PyTorch Modelinden Temel Skorları Al (Artık her istekte hesaplamıyor, hafızadan çekiyor!)
        scores = self.cached_model_scores.copy()
        
        # POPÜLERLİK VERİSİ
        popularity = self.df.get('popularity', pd.Series(np.zeros(len(self.df)))).values / 100.0
        
        # 2. Geçmiş Profil (Like > 5 ise) veya Başlangıç Durumu
        if len(liked_indices) >= 5:
            liked_idx = self.df[self.df['song_id'].isin(liked_indices)].index
            liked_vectors = self.X_scaled[liked_idx]
            user_profile = np.mean(liked_vectors, axis=0)
            
            profile_similarity = self._calculate_similarity(user_profile)
            scores = 0.5 * scores + 0.5 * profile_similarity
        else:
            scores = 0.7 * scores + 0.3 * popularity
            
        # Mood Vector Çarpanı
        if mood_vector is not None:
            mood_array = np.array(mood_vector)
            mood_similarity = self._calculate_similarity(mood_array)

            scores = 0.15 * scores + 0.85 * mood_similarity
       
        scores = scores * (1.0 + (popularity * 0.10))
            
        #Daha Önce Etkileşime Girilenleri (Like/Dislike) Filtrele
        excluded = set(liked_indices + disliked_indices)
        result_df = self.df.copy()
        result_df['final_score'] = scores
        result_df = result_df[~result_df['song_id'].isin(excluded)]

        
        # Filter songs with the exact same track name and artist (Single/Album duplicates)
        track_name_col = 'track_name' if 'track_name' in result_df.columns else 'name'
        artist_col = 'artists' if 'artists' in result_df.columns else 'artist'
        
        result_df = result_df.sort_values(by='final_score', ascending=False)
        result_df = result_df.drop_duplicates(subset=[track_name_col, artist_col], keep='first')

        # Sadece en iyi N taneyi değil, en iyi 100 şarkılık elit bir havuz oluştur
        top_pool = result_df.nlargest(100, 'final_score')
        
        # Havuzdan rastgele N (15) tane seç, ancak skoru/popülerliği yüksek olana torpil geç (weights)
        top_songs = top_pool.sample(n=min(n, len(top_pool)), weights='final_score')
        
        # Seçilen şarkıları API'den UI'a düzgün gitmesi için büyükten küçüğe tekrar sırala
        top_songs = top_songs.sort_values(by='final_score', ascending=False)
        
        # 7. JSON Formatına Çevir
        feed = []
        for _, row in top_songs.iterrows():
            # Popülerlik çarpanı skoru 1.0'ın üzerine taşıyabileceği için max 100 ile sınırlıyoruz
            match_percentage = min(100.0, round(float(row['final_score']) * 100, 1))
            
            feed.append({
                "song_id": int(row['song_id']),
                "track_name": str(row.get('track_name', row.get('name', 'Bilinmeyen Şarkı'))),
                "artists": str(row.get('artists', row.get('artist', 'Bilinmeyen Sanatçı'))),
                "match_score": match_percentage
            })
            
        return {"feed": feed}