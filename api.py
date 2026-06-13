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

# --- GEMINI AYARLARI ---
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


# ── SABİTLER ─────────────────────────────────────────────────────────────────

# Cold start eşiği: bu sayıya eşit veya altındaki kullanıcılar yeni kullanıcıdır.
COLD_START_THRESHOLD = 5

# Olgun kullanıcı için chat ve önceki session vektörü ağırlıkları.
W_CHAT = 0.75
W_PREVIOUS = 0.25


# ── YARDIMCI FONKSİYONLAR ────────────────────────────────────────────────────

def clamp_vector(v: List[float]) -> List[float]:
    """
    Vektördeki her değeri [0.0, 1.0] aralığına sıkıştırır
    ve 4 ondalık basamağa yuvarlar.
    """
    return [round(min(1.0, max(0.0, x)), 4) for x in v]


def interpolate_vectors(
    raw_chat_vector: List[float],
    current_session_vector: List[float],
    liked_count: int
) -> List[float]:
    """
    liked_count değerine göre harmanlama stratejisini belirler:

    Cold Start  (liked_count <= 5): Tamamen anlık mesaja odaklan.
        session_vector = raw_chat_vector

    Olgun kullanıcı (liked_count > 5): Anlık mesajı önceki session ile harmanlara.
        V_session[i] = (raw_chat_vector[i] * 0.75) + (current_session_vector[i] * 0.25)
    """
    expected_dim = 9

    # Boyut uyumsuzluğuna karşı güvenlik: her iki vektörü de 9 boyuta normalize et.
    # Kısa vektörler 0.5 ile doldurulur, uzun vektörler kırpılır.
    def normalize_dim(v: List[float]) -> List[float]:
        if len(v) == expected_dim:
            return v
        padded = (v + [0.5] * expected_dim)[:expected_dim]
        return padded

    raw = normalize_dim(raw_chat_vector)
    current = normalize_dim(current_session_vector)

    if liked_count <= COLD_START_THRESHOLD:
        # Cold start — geçmiş session'a bakma, sadece Gemini çıktısını döndür.
        return clamp_vector(raw)

    # Olgun kullanıcı — kümülatif evrilme uygula.
    blended = [
        (raw[i] * W_CHAT) + (current[i] * W_PREVIOUS)
        for i in range(expected_dim)
    ]
    return clamp_vector(blended)


# ── VERİ MODELLERİ ───────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str
    # iOS'un o an bellekte tuttuğu dinamik session vektörü.
    # Cold start kullanıcısında bu değer [0.5]*9 gibi nötr bir başlangıç olabilir.
    current_session_vector: List[float]
    # iOS'un lokalinde tuttuğu toplam beğeni sayısı.
    # Her swipe oturumu sonrası /api/swipe response'undan güncel tutulur.
    # API'nin Firestore'a sorgu atmasına gerek kalmaz → gerçek anlamda Stateless.
    liked_count: int = 0

class RecommendRequest(BaseModel):
    mood_vector: List[float]
    n: int = 15

class LikedSongItem(BaseModel):
    song_id: int
    title: str
    artist: str
    album_art: Optional[str] = ""
    apple_music_id: Optional[str] = ""

class BatchSwipeRequest(BaseModel):
    # "like" alan şarkıların tam detayları → likedSongs subcollection'a yazılır.
    liked_songs: List[LikedSongItem]
    # "dislike" alan şarkıların ID'leri → vektör güncellemesinde kullanılır,
    # Firestore'a yazılmaz.
    disliked_song_ids: List[int]
    # iOS'un lokalinde tuttuğu kalıcı profil vektörü.
    # Swipe'lar bu vektör üzerine işlenir ve güncellenen hali Firestore'a yazılır.
    current_mood_vector: List[float]
    # iOS'un swipe oturumuna girmeden önceki toplam beğeni sayısı.
    # API bunu liked_songs sayısıyla toplayıp yeni liked_count olarak döndürür.
    # Böylece /api/chat gerçek anlamda Stateless kalır.
    liked_count: int = 0


# ── ENDPOINT'LER ─────────────────────────────────────────────────────────────

@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "architecture": "client_led_state_management",
        "chat_stateless": True,
        "vector_owner": "iOS_local_storage",
    }


# ── 1. CHAT ENDPOINT (Stateless — Firestore okuma/yazma YOK) ─────────────────
#
# Çalışma prensibi:
#   a) Gemini, kullanıcının mesajından 9 boyutlu raw_chat_vector üretir.
#   b) iOS'tan gelen liked_count ile cold start / olgun kullanıcı belirlenir.
#      → Firestore'a hiç sorgu atılmaz; iOS bu sayıyı lokalinde zaten biliyor.
#   c) Harmanlama kuralına göre yeni session_vector hesaplanır.
#   d) session_vector KESİNLİKLE Firestore'a yazılmaz; sadece iOS'a döndürülür.
#      iOS bu vektörü lokalinde günceller ve bir sonraki chat mesajında
#      current_session_vector olarak geri gönderir (kümülatif evrilme).
#
# Firestore maliyeti: SIFIR (gerçek anlamda Stateless).
@app.post("/api/chat")
def chat(request: ChatRequest, user_uid: str = Depends(verify_token)):
    print(f"\n--- [1] CHAT (Stateless) — Kullanıcı: {user_uid} ---")
    print(f" ⏱️ DEDEKTİF 1: iOS'tan istek ulaştı. Gelen mesaj: '{request.message}'")

    # ── a) Gemini ile raw_chat_vector üret ──────────────────────────────────
    raw_chat_vector = [0.5] * 9  # varsayılan fallback
    reply_text = "Bağlantıda bir sorun var ama senin için genel bir ritim hazırladım."

    try:
        model = genai.GenerativeModel('gemini-2.5-flash')
        prompt = f"""
        Kullanıcı: "{request.message}"
        Senden tam olarak şu formatta bir JSON istiyorum.
        {{
            "reply": "Kullanıcıya vereceğin empatik, kısa Türkçe cevap",
            "vector": [danceability, energy, valence, tempo, acousticness, instrumentalness, speechiness, loudness, liveness]
        }}
        Kurallar:
        - Vektördeki sayıların sırası YUKARIDAKİ İSİM SIRASIYLA BİREBİR AYNI olmalıdır.
        - Tüm değerler KESİNLİKLE 0.0 ile 1.0 arasında olmalı.
        - tempo (BPM) değerini de 0.0 ile 1.0 arasında ölçekle (0.0 = 60 BPM, 1.0 = 180 BPM).
        - loudness değerini de 0.0 ile 1.0 arasında ölçekle.
        SADECE JSON DÖNDÜR. Başka hiçbir şey yazma.
        """
        
        print(" ⏱️ DEDEKTİF 2: Gemini'ye soru gönderiliyor, bekliyoruz...")
        cevap = model.generate_content(prompt)
        print(" ⏱️ DEDEKTİF 3: Gemini'den cevap BAŞARIYLA geldi!")
        
        gelen_metin = cevap.text.replace("```json", "").replace("```", "").strip()
        veri = json.loads(gelen_metin)
        raw_chat_vector = veri.get('vector', raw_chat_vector)
        reply_text = veri.get('reply', reply_text)
        print(f"  ✓ Gemini raw_chat_vector üretildi")

    except Exception as e:
        print(f"  ✗ DEDEKTİF 3 (HATA): Gemini tarafında sorun çıktı (nötr vektör kullanılıyor): {e}")

    # ── b) iOS'tan gelen liked_count ile kullanıcı tipini belirle ───────────
    liked_count = request.liked_count
    # NOT: COLD_START_THRESHOLD değişkeninin kodun üst kısımlarında tanımlı olduğunu varsayıyorum.
    print(f"  ✓ liked_count = {liked_count}")

    # ── c) Harmanlama — kümülatif session_vector hesapla ────────────────────
    session_vector = interpolate_vectors(
        raw_chat_vector=raw_chat_vector,
        current_session_vector=request.current_session_vector,
        liked_count=liked_count,
    )
    print(f"  ✓ session_vector hesaplandı")

    print(" ⏱️ DEDEKTİF 4: Her şey tamam, iOS'a yanıt dönülüyor!")
    # ── d) Sadece response dön — Firestore'a hiçbir şey yazılmaz ────────────
    return {
        "reply": reply_text,
        "vector": session_vector,  # iOS bunu lokalinde saklar, bir sonraki çağrıda gönderir.
    }

# ── 2. RECOMMEND ENDPOINT ─────────────────────────────────────────────────────
#
# userVectors'dan kalıcı profil vektörünü okur (1 read).
# likedSongs subcollection'dan ID listesini çeker.
# Motoru çalıştırarak öneri üretir.
@app.post("/api/recommend")
def get_custom_recommendations(request: RecommendRequest, user_uid: str = Depends(verify_token)):
    print(f"\n--- [2] RECOMMEND — Kullanıcı: {user_uid} ---")

    # ── Kalıcı profil vektörünü oku: userVectors/{userId} → 1 read ──────────
    vector_ref = db.collection('userVectors').document(user_uid)
    vector_doc = vector_ref.get()

    db_vector = request.mood_vector  # fallback: iOS'tan gelen anlık vektörü kullan
    if vector_doc.exists:
        db_vector = vector_doc.to_dict().get('vector', request.mood_vector)
        print(f"  ✓ Kalıcı profil vektörü Firestore'dan okundu")
    else:
        print(f"  ✓ Profil vektörü yok, iOS session vektörü kullanılıyor (fallback)")

    # ── Beğenilen şarkı ID'lerini çek: subcollection stream ─────────────────
    liked_songs_ref = db.collection('users').document(user_uid).collection('likedSongs')
    liked_indices = [int(doc.id) for doc in liked_songs_ref.stream()]
    print(f"  ✓ {len(liked_indices)} beğenilen şarkı ID'si çekildi")

    # ── Öneri motorunu çalıştır ──────────────────────────────────────────────
    result = engine.recommend(
        mood_vector=db_vector,
        liked_indices=liked_indices,
        disliked_indices=[],  # dislike'lar sadece vektörü etkiler, burada gerekmez
        n=request.n
    )
    return result


# ── 3. SWIPE ENDPOINT (Batch Discovery & Profile Write) ──────────────────────
#
# Kullanıcı ister Discovery ister Chat modunda swipe etsin,
# oturum bittiğinde tek seferinde çağrılır.
#
# İşlem akışı:
#   a) liked_songs → likedSongs subcollection'a batch write (idempotent, ID = song_id).
#   b) iOS'tan gelen current_mood_vector (kalıcı profil) + swipe aksiyonları
#      → engine.update_batch_mood_vector → new_profile_vector.
#      Fallback: profil yoksa (ilk oturum) current_mood_vector doğrudan kullanılır.
#   c) new_profile_vector clamp + round uygulanır, kirli veri Firestore'a gitmez.
#   d) new_profile_vector → userVectors/{user_uid} (1 write).
#   e) new_profile_vector + güncel liked_count iOS'a döndürülür.
#      iOS lokalini günceller; bir sonraki /api/chat çağrısında liked_count gönderir.
#
# Firestore maliyeti: N write (likedSongs) + 1 write (userVectors).
@app.post("/api/swipe")
def swipe_batch(request: BatchSwipeRequest, user_uid: str = Depends(verify_token)):
    print(f"\n--- [3] SWIPE — Kullanıcı: {user_uid} ---")
    print(f"  ✓ {len(request.liked_songs)} beğeni, {len(request.disliked_song_ids)} beğenmeme")

    # ── a) Beğenilen şarkıları likedSongs subcollection'a batch write ────────
    # Document ID = song_id → aynı şarkı tekrar beğenilse bile set() idempotent çalışır.
    if request.liked_songs:
        liked_songs_col = (
            db.collection('users')
              .document(user_uid)
              .collection('likedSongs')
        )
        batch = db.batch()
        for song in request.liked_songs:
            song_ref = liked_songs_col.document(str(song.song_id))
            batch.set(song_ref, {
                'title':        song.title,
                'artist':       song.artist,
                'albumArt':     song.album_art,
                'appleMusicId': song.apple_music_id,
                'addedAt':      firestore.SERVER_TIMESTAMP,
            })
        batch.commit()
        print(f"  ✓ {len(request.liked_songs)} şarkı likedSongs'a yazıldı")
    else:
        print(f"  ✓ Beğenilen şarkı yok, likedSongs yazma atlandı")

    # ── b) Kalıcı profil vektörünü swipe aksiyonlarına göre güncelle ─────────
    liked_ids = [song.song_id for song in request.liked_songs]

    # Fallback: current_mood_vector boş veya geçersizse (ilk oturum) nötr vektör ata.
    current_vector = request.current_mood_vector
    if not current_vector or len(current_vector) != 9:
        print(f"  ⚠ current_mood_vector geçersiz, nötr vektör (fallback) kullanılıyor")
        current_vector = [0.5] * 9

    try:
        raw_profile_vector = engine.update_batch_mood_vector(
            current_vector=current_vector,
            liked_ids=liked_ids,
            disliked_ids=request.disliked_song_ids
        )
    except Exception as e:
        # Motor çökerse mevcut vektörü koru, Firestore'a kirli veri gitmesin.
        print(f"  ✗ update_batch_mood_vector hatası (mevcut vektör korunuyor): {e}")
        raw_profile_vector = current_vector

    # ── c) Talimat gereği: clamp [0.0, 1.0] ve round(4) uygula ─────────────
    # Motordan 1.2 veya -0.1 gibi sınır dışı değer gelse bile Firestore'a temiz veri gider.
    new_profile_vector = clamp_vector(raw_profile_vector)

    # ── d) Güncellenmiş kalıcı profili Firestore'a yaz: userVectors/{uid} ────
    vector_ref = db.collection('userVectors').document(user_uid)
    vector_ref.set({
        'vector':    new_profile_vector,
        'updatedAt': firestore.SERVER_TIMESTAMP,
    })
    print(f"  ✓ new_profile_vector userVectors'a yazıldı")

    # ── e) iOS'a dön: profil vektörü + güncel liked_count ────────────────────
    # iOS liked_count'u lokalinde günceller ve bir sonraki /api/chat çağrısında gönderir.
    # Böylece chat endpoint'i gerçek anlamda Stateless kalır.
    new_liked_count = request.liked_count + len(request.liked_songs)

    return {
        "status":             "success",
        "new_profile_vector": new_profile_vector,
        "liked_count":        new_liked_count,  # iOS bunu lokalinde saklar
    }


# ── 4. FAVORİLER ENDPOINT ────────────────────────────────────────────────────
#
# likedSongs subcollection'ını addedAt'e göre ters sırada döndürür.
# Pagination: her çağrıda `limit` kadar şarkı gelir.
# Bir sonraki sayfa için last_song_id query parametresi kullanılır.
@app.get("/api/favorites")
def get_favorites(
    user_uid: str = Depends(verify_token),
    limit: int = 20,
    last_song_id: Optional[str] = None
):
    print(f"\n--- [4] FAVORİLER — Kullanıcı: {user_uid} ---")

    liked_songs_ref = (
        db.collection('users')
          .document(user_uid)
          .collection('likedSongs')
          .order_by('addedAt', direction=firestore.Query.DESCENDING)
          .limit(limit)
    )

    # Sayfalama: cursor olarak son dökümanı kullan.
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

    favorites_list = [
        {
            "song_id":       doc.id,
            "title":         doc.to_dict().get('title', 'Bilinmeyen Şarkı'),
            "artist":        doc.to_dict().get('artist', 'Bilinmeyen Sanatçı'),
            "album_art":     doc.to_dict().get('albumArt', ''),
            "apple_music_id": doc.to_dict().get('appleMusicId', ''),
            "added_at":      doc.to_dict().get('addedAt'),
        }
        for doc in liked_songs_ref.stream()
    ]

    print(f"  ✓ {len(favorites_list)} şarkı döndürüldü")
    return {
        "favorites": favorites_list,
        "has_more": len(favorites_list) == limit,
    }