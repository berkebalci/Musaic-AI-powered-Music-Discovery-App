import os
import json
import google.generativeai as genai
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Firebase ve Güvenlik modülleri
from firebase_admin import firestore
from auth import verify_token
from recommend import RecommendationEngine

# Gizli şifreleri yükle
load_dotenv()

# --- GEMINI AYARLARI (GÜVENLİ) ---
GEMINI_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_KEY:
    raise ValueError("Gemini API anahtarı bulunamadı! Lütfen .env dosyanı kontrol et.")
genai.configure(api_key=GEMINI_KEY)

# --- UYGULAMA VE MOTOR BAŞLATMA ---
app = FastAPI()
engine = RecommendationEngine()

# Firestore Veritabanı Bağlantısı
db = firestore.client()

# CORS Ayarları
origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── VERİ MODELLERİ ──────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str

class RecommendRequest(BaseModel):
    mood_vector: List[float]
    n: int = 15

class LikedSongItem(BaseModel):
    """
    iOS tarafından gelen bir şarkının detayları.
    SwipeRequest içinde kullanılır.
    """
    song_id: int
    title: str
    artist: str
    album_art: Optional[str] = ""
    apple_music_id: Optional[str] = ""

class SwipeItem(BaseModel):
    song_id: int
    action: str  # "like" veya "dislike"

class BatchSwipeRequest(BaseModel):
    """
    iOS, tüm swipe oturumu bitince bu isteği tek seferinde gönderir.
    liked_songs: "like" aksiyonu alan şarkıların tam detayları (Firestore'a yazılacak)
    disliked_song_ids: "dislike" aksiyonu alan şarkıların sadece ID'leri (vektör için yeterli)
    current_mood_vector: Güncellenecek vektörün mevcut hali
    """
    liked_songs: List[LikedSongItem]
    disliked_song_ids: List[int]
    current_mood_vector: List[float]


# ── ENDPOINT'LER ─────────────────────────────────────────────────────────────

@app.get("/health")
def health_check():
    return {"status": "ok", "api_secure": True, "architecture": "subcollection_with_isolated_vector"}


# --- 1. CHAT ENDPOINT ---
# Kullanıcının ruh halini analiz eder, mood vektörünü üretir.
# Vektörü Firestore'a yazmaz — bu işi swipe endpoint'i üstlenir.
# Böylece her chat mesajında gereksiz bir Firestore write'ından kaçınılır.
@app.post("/api/chat")
def chat(request: ChatRequest, user_uid: str = Depends(verify_token)):
    print(f"\n--- [1] CHAT İSTEĞİ GELDİ (Kullanıcı: {user_uid}) ---")
    try:
        model = genai.GenerativeModel('gemini-2.5-flash')
        prompt = f"""
        Kullanıcı: "{request.message}"
        Senden tam olarak şu formatta bir JSON istiyorum.
        {{
            "reply": "Kullanıcıya vereceğin empatik cevap",
            "vector": [danceability, energy, valence, tempo, acousticness, instrumentalness, speechiness, loudness, liveness]
        }}
        Kurallar:
        - Vektördeki sayıların sırası YUKARIDAKİ İSİM SIRASIYLA BİREBİR AYNI olmalıdır.
        - Tüm değerler KESİNLİKLE 0.0 ile 1.0 arasında olmalı.
        - tempo (BPM) değerini de 0.0 ile 1.0 arasında ölçekle (0.0 = 60 BPM, 1.0 = 180 BPM).
        - loudness değerini de 0.0 ile 1.0 arasında ölçekle.
        SADECE JSON DÖNDÜR.
        """

        cevap = model.generate_content(prompt)
        gelen_metin = cevap.text.replace("```json", "").replace("```", "").strip()
        veri = json.loads(gelen_metin)

        # Vektörü sadece response olarak döndürüyoruz.
        # Firestore'a yazma işlemi swipe oturumu bitince yapılacak.
        return {
            "reply": veri.get('reply'),
            "vector": veri.get('vector')
        }

    except Exception as e:
        print(f"Gemini Hatası: {e}")
        return {
            "reply": "Bağlantıda bir sorun var ama senin için genel bir ritim hazırladım.",
            "vector": [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
        }


# --- 2. RECOMMEND ENDPOINT ---
# userVectors koleksiyonundan sadece vektörü okur (1 read).
# Beğenilen şarkı ID'leri için likedSongs subcollection'ını sorgular.
# İki ayrı koleksiyon olduğu için vektör, profil detaylarıyla birlikte gelmez.
@app.post("/api/recommend")
def get_custom_recommendations(request: RecommendRequest, user_uid: str = Depends(verify_token)):
    print(f"\n--- [2] ÖNERİ İSTEĞİ GELDİ (Kullanıcı: {user_uid}) ---")

    # ── Vektörü oku: userVectors/{userId} → 1 read ──────────────────────────
    vector_ref = db.collection('userVectors').document(user_uid)
    vector_doc = vector_ref.get()

    db_vector = request.mood_vector  # fallback: istek içindeki vektörü kullan
    if vector_doc.exists:
        db_vector = vector_doc.to_dict().get('vector', request.mood_vector)

    # ── Beğenilen şarkı ID'lerini oku: subcollection → N read ───────────────
    # Sadece song_id alanını çekiyoruz (projeksiyon benzeri davranış için
    # Firestore'da alan filtreleme yok, ama document küçük olduğu için ucuz)
    liked_songs_ref = db.collection('users').document(user_uid).collection('likedSongs')
    liked_docs = liked_songs_ref.stream()
    liked_indices = [int(doc.id) for doc in liked_docs]

    # ── Öneri motorunu çalıştır ──────────────────────────────────────────────
    result = engine.recommend(
        mood_vector=db_vector,
        liked_indices=liked_indices,
        disliked_indices=[],  # dislike'lar Firestore'da tutulmuyor, sadece vektörü etkiliyor
        n=request.n
    )

    return result


# --- 3. SWIPE ENDPOINT ---
# iOS'tan swipe oturumu tamamen bitince çağrılır.
# İki bağımsız yazma işlemi yapar:
#   a) Her beğenilen şarkı → likedSongs subcollection'a ayrı document (N write)
#   b) Güncellenmiş vektör → userVectors/{userId} (1 write)
# dislike'lar Firestore'a yazılmaz; sadece vektör güncellemesinde kullanılır.
@app.post("/api/swipe")
def swipe_batch(request: BatchSwipeRequest, user_uid: str = Depends(verify_token)):
    print(f"\n--- [3] SWIPE İSTEĞİ GELDİ (Kullanıcı: {user_uid}) ---")
    print(f"  ✓ {len(request.liked_songs)} beğeni, {len(request.disliked_song_ids)} beğenmeme")

    # ── a) Beğenilen şarkıları likedSongs subcollection'a yaz ───────────────
    # Her şarkı kendi document'ı olur: likedSongs/{song_id}
    # Document ID olarak song_id kullanıyoruz → aynı şarkı iki kere eklenemez (idempotent)
    if request.liked_songs:
        liked_songs_col = db.collection('users').document(user_uid).collection('likedSongs')
        batch = db.batch()

        for song in request.liked_songs:
            song_doc_ref = liked_songs_col.document(str(song.song_id))
            batch.set(song_doc_ref, {
                'title': song.title,
                'artist': song.artist,
                'albumArt': song.album_art,
                'appleMusicId': song.apple_music_id,
                'addedAt': firestore.SERVER_TIMESTAMP,
            })

        batch.commit()
        print(f"  ✓ {len(request.liked_songs)} şarkı likedSongs'a yazıldı")

    # ── b) Vektörü güncelle ve userVectors'a yaz ────────────────────────────
    # Motor, beğeni ve beğenmeme ID'lerini kullanarak yeni vektörü hesaplar.
    liked_ids = [song.song_id for song in request.liked_songs]
    new_vector = engine.update_batch_mood_vector(
        current_vector=request.current_mood_vector,
        liked_ids=liked_ids,
        disliked_ids=request.disliked_song_ids
    )

    # userVectors/{userId} → 1 write, profil document'ından tamamen bağımsız
    vector_ref = db.collection('userVectors').document(user_uid)
    vector_ref.set({
        'vector': new_vector,
        'updatedAt': firestore.SERVER_TIMESTAMP,
    })
    print(f"  ✓ Yeni vektör userVectors'a yazıldı")

    return {
        "status": "success",
        "new_vector": new_vector,
        "message": "Şarkılar ve yapay zeka vektörü başarıyla güncellendi."
    }


# --- 4. FAVORİLER ENDPOINT ---
# likedSongs subcollection'ını okur.
# Sayfalama (pagination) destekli: her çağrıda 20 şarkı döner.
# last_song_id parametresiyle bir sonraki sayfa çekilebilir.
@app.get("/api/favorites")
def get_favorites(
    user_uid: str = Depends(verify_token),
    limit: int = 20,
    last_song_id: Optional[str] = None
):
    print(f"\n--- [4] FAVORİLER İSTEĞİ GELDİ (Kullanıcı: {user_uid}) ---")

    liked_songs_ref = (
        db.collection('users')
          .document(user_uid)
          .collection('likedSongs')
          .order_by('addedAt', direction=firestore.Query.DESCENDING)
          .limit(limit)
    )

    # Sayfalama: eğer last_song_id verilmişse o document'tan sonrasını getir
    if last_song_id:
        last_doc = (
            db.collection('users')
              .document(user_uid)
              .collection('likedSongs')
              .document(last_song_id)
              .get()
        )
        if last_doc.exists:
            liked_songs_ref = liked_songs_ref.start_after(last_doc)

    docs = liked_songs_ref.stream()

    favorites_list = []
    for doc in docs:
        data = doc.to_dict()
        favorites_list.append({
            "song_id": doc.id,
            "title": data.get('title', 'Bilinmeyen Şarkı'),
            "artist": data.get('artist', 'Bilinmeyen Sanatçı'),
            "album_art": data.get('albumArt', ''),
            "apple_music_id": data.get('appleMusicId', ''),
            "added_at": data.get('addedAt'),
        })

    print(f"  ✓ {len(favorites_list)} şarkı döndürüldü")
    return {
        "favorites": favorites_list,
        "has_more": len(favorites_list) == limit  # Sonraki sayfa var mı?
    }