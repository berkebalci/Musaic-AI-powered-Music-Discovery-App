# Musaic — AI-Powered Music Discovery App

> **Proje Türü:** iOS Native Uygulama (Swift / SwiftUI)
> **Mimari:** MVVM + Protocol-Oriented Dependency Injection
> **Backend:** FastAPI (Python) — Sunucu taraflı NLP + Öneri Motoru
> **Oluşturulma Tarihi:** 8 Nisan 2026
> **Platform:** iOS 16+
> **Proje Yolu:** `NlpMusicRecomSystem/`

---

## 1. Projenin Fikri ve Vizyonu

### 1.1. Problem Tanımı
Kullanıcılar müzik dinlerken genellikle "ne dinleyeceğini bilmeme" ya da "o anki ruh haline uygun müzik bulamama" problemiyle karşılaşırlar. Mevcut müzik platformları (Spotify, Apple Music vb.) kullanıcı geçmişine dayalı öneri sunar; ancak anlık duygu durumunu anlayarak buna göre kişiselleştirilmiş müzik önerisi yapan bir sistem bulunmamaktadır.

### 1.2. Çözüm: Musaic
**Musaic**, kullanıcının **doğal dilde (Türkçe/İngilizce) yazdığı ruh hali metinlerini** yapay zeka ile analiz ederek, bu duygu durumuna en uygun şarkıları öneren bir iOS uygulamasıdır.

**Temel değer önerileri:**
- 🧠 **NLP ile duygu analizi:** "Gece yolda gidiyormuş gibi hissediyorum" gibi cümleler 9 boyutlu bir mood vektörüne dönüştürülür
- 🎵 **Kişiselleştirilmiş öneri:** Bu vektör, ~114.000 şarkılık bir veritabanında cosine similarity ile eşleştirilir
- 💬 **Konuşarak keşif:** AI chatbot ile sohbet ederek müzik zevkini kademeli olarak rafine etme
- 👆 **Tinder-tarzı swipe:** Şarkıları sağa/sola kaydırarak beğeni bildirim, sistem bu geribildirimi öğrenir
- 🎧 **Apple Music entegrasyonu:** Önerilen şarkıların 30 saniyelik preview'ları doğrudan uygulamada çalınır

### 1.3. Kullanıcı Akışı (End-to-End)

```
[Kullanıcı Giriş Yapar (Firebase Auth)]
          │
          ▼
[Ana Sayfa (LandingHomeView)]
     ┌────┴────┐
     │         │
     ▼         ▼
[Discovery]  [Chat with AI]
     │              │
     ▼              ▼
[Mood Metni Gir] [AI ile Sohbet Et]
     │              │
     ▼              ▼
[/api/chat → NLP → 9D Vektör]
     │              │
     ▼              ▼
[/api/recommend → Cosine Similarity → Şarkı Listesi]
     │              │
     ▼              ▼
[Apple Music API → Artwork + Preview URL Enrichment]
     │              │
     ▼              ▼
[Swipe Kartları]  [Chat İçi Şarkı Önerisi]
     │
     ▼
[Beğen/Beğenme → /api/swipe → Vektör Güncelleme + Firestore Kayıt]
     │
     ▼
[Favoriler Listesi (/api/favorites)]
```

---

## 2. Teknik Mimari

### 2.1. Katmanlı Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                       │
│  Views (SwiftUI)                                                │
│  ├── RootView          → Auth state router                      │
│  ├── MainTabView       → Tab-based navigation controller        │
│  ├── LandingHomeView   → Hero banner + CTA + öneriler           │
│  ├── MoodChatView      → AI chatbot arayüzü                     │
│  ├── DiscoveryViews    → Mood input + Swipe kartları             │
│  ├── FavoritesView     → Beğenilen şarkılar listesi             │
│  ├── LoginView/SignUp  → Kimlik doğrulama formları               │
│  └── ProfileView       → Kullanıcı profili + çıkış              │
├─────────────────────────────────────────────────────────────────┤
│                        VIEWMODEL LAYER                          │
│  (MVVM — @MainActor, ObservableObject)                          │
│  ├── AuthViewModel           → Login/SignUp state yönetimi      │
│  ├── ChatViewModel           → Chat mesajları + session vektörü │
│  ├── DiscoveryViewModel      → Swipe oturumu + mood analizi     │
│  ├── FavoritesViewModel      → Favori listesi + Apple Music     │
│  └── AudioPlayerViewModel    → AVPlayer + 30s preview playback  │
├─────────────────────────────────────────────────────────────────┤
│                        SERVICE LAYER                            │
│  Protocols (Abstraction)     │  Implementations                 │
│  ├── RecommendationService   │  ├── APIRecommendationService    │
│  ├── ChatServiceProtocol     │  ├── APIChatService              │
│  ├── FeedbackServiceProtocol │  ├── APIFeedbackService          │
│  ├── FavoritesServiceProto   │  ├── APIFavoritesService         │
│  ├── AuthServiceProtocol     │  ├── FirebaseAuthService         │
│  ├── AppleMusicServiceProto  │  ├── AppleMusicService           │
│  └── NLPServiceProtocol      │  └── MockNLPService              │
│                              │                                  │
│  Mock Implementations        │  (UI geliştirme için)            │
│  ├── MockChatService         │                                  │
│  ├── MockRecommendationSvc   │                                  │
│  ├── MockFavoritesService    │                                  │
│  └── MockFeedbackService     │                                  │
├─────────────────────────────────────────────────────────────────┤
│                        NETWORKING LAYER                         │
│  ├── APIClient          → Generic POST/GET, auth token inject   │
│  ├── APIEnvironment     → URL endpoint tanımları                │
│  └── DTOs               → Request/Response veri transfer objeleri│
│      ├── ChatRequestDTO / ChatResponseDTO                       │
│      ├── RecommendRequestDTO / RecommendResponseDTO             │
│      ├── BatchSwipeRequestDTO / BatchSwipeResponseDTO           │
│      ├── FavoritesResponseDTO                                   │
│      └── HealthResponseDTO                                      │
├─────────────────────────────────────────────────────────────────┤
│                        DI CONTAINER                             │
│  DIContainer.swift                                              │
│  ├── .live()   → Gerçek API servisleri (production)             │
│  └── .mock()   → Mock servisleri (UI development)               │
├─────────────────────────────────────────────────────────────────┤
│                        EXTERNAL SERVICES                        │
│  ├── Firebase Authentication  → Email/Password auth             │
│  ├── Firebase Firestore       → Favori şarkı storage (sunucu)   │
│  ├── Apple MusicKit           → Katalog arama + preview URLs    │
│  └── FastAPI Backend          → NLP + Recommendation Engine     │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2. Dependency Injection Sistemi

Uygulama, saf Swift ile yazılmış bir **manual DI container** kullanır (3rd-party kütüphane yok):

```swift
// Üretim ortamı — gerçek API bağlantıları
let container = DIContainer.live()

// Geliştirme ortamı — mock verilerle çalışma
let container = DIContainer.mock()
```

**Nasıl çalışır:**
1. `DIContainer` tüm servis instance'larını tutar
2. `NlpMusicRecomSystemApp.init()` içinde `.live()` ile oluşturulur
3. `RootView` → `MainTabView` → her bir `View` zincirine enjekte edilir
4. ViewModeller servisleri initializer aracılığıyla alır (constructor injection)
5. Protocol-oriented olduğu için test ve mock desteği doğaldır

---

## 3. Veri Modelleri

### 3.1. Song (Domain Model)
Uygulamanın ana veri birimi. Hem API'den gelen ham veriyi hem de Apple Music ile zenginleştirilmiş metadatayı tutar.

| Alan | Tür | Açıklama |
|------|------|----------|
| `id` | `Int` | API'den gelen benzersiz şarkı kimliği (`song_id`) |
| `title` | `String` | Şarkı adı |
| `artistName` | `String` | Sanatçı adı |
| `genre` | `String` | Tür (opsiyonel) |
| `imageUrl` | `String?` | Albüm kapağı URL'si |
| `popularity` | `Int?` | Popülerlik skoru (0-100) |
| `score` | `Double?` | Cosine similarity match skoru |
| `appleMusicId` | `String?` | Apple Music katalog ID'si |
| `durationInMillis` | `Int?` | Süre (milisaniye) |
| `previewURL` | `URL?` | 30 saniyelik önizleme URL'si |

### 3.2. MoodVector (9 Boyutlu Duygu Vektörü)
Backend'deki Gemini modeli tarafından üretilen, kullanıcının ruh halini 9 Spotify audio feature boyutunda temsil eden vektör.

| Boyut | Aralık | Açıklama |
|-------|--------|----------|
| `danceability` | 0.0–1.0 | Dans edilebilirlik |
| `energy` | 0.0–1.0 | Enerji yoğunluğu |
| `valence` | 0.0–1.0 | Pozitiflik (0=üzgün, 1=mutlu) |
| `tempo` | 0.0–1.0 | Normalize tempo (60-180 BPM) |
| `acousticness` | 0.0–1.0 | Akustik olma olasılığı |
| `instrumentalness` | 0.0–1.0 | Enstrümantal olma oranı |
| `speechiness` | 0.0–1.0 | Konuşma oranı |
| `loudness` | 0.0–1.0 | Normalize ses yüksekliği |
| `liveness` | 0.0–1.0 | Canlı kayıt olasılığı |

**Dominant mood etiketleri** vektörden otomatik türetilir:
- `valence < 0.3 && energy < 0.4` → **Melancholic**
- `energy > 0.7 && danceability > 0.6` → **Energetic**
- `acousticness > 0.7 && energy < 0.4` → **Chill**
- `valence > 0.6 && energy > 0.5` → **Upbeat**
- `instrumentalness > 0.7` → **Atmospheric**
- Diğer → **Balanced**

### 3.3. ChatMessage
AI sohbet mesajlarını temsil eder.

| Alan | Tür | Açıklama |
|------|------|----------|
| `id` | `UUID` | Benzersiz mesaj kimliği |
| `content` | `String` | Mesaj metni |
| `isFromUser` | `Bool` | Kullanıcıdan mı (true) yoksa AI'dan mı (false) |
| `timestamp` | `Date` | Mesaj zamanı |
| `suggestedSongs` | `[Song]` | AI yanıtına gömülü şarkı önerileri |
| `isLoading` | `Bool` | Typing indicator gösterimi |

### 3.4. UserInteraction
Kullanıcının swipe aksiyonlarını kaydeder.

| Alan | Tür | Açıklama |
|------|------|----------|
| `songId` | `Int` | Etkileşilen şarkı ID'si |
| `action` | `String` | `"like"` veya `"dislike"` |
| `timestamp` | `Date` | Etkileşim zamanı |

---

## 4. API Endpoint'leri ve Veri Akışı

Backend, FastAPI (Python) tabanlı bir sunucudur. Tüm endpoint'ler `Authorization: Bearer <Firebase ID Token>` header'ı gerektirir.

### 4.1. `POST /api/chat` — NLP Mood Analizi

**İstek:**
```json
{
  "message": "Gece yolda gidiyormuş gibi hissediyorum",
  "current_session_vector": [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
}
```

**Yanıt:**
```json
{
  "reply": "I can sense that midnight drive feeling...",
  "vector": [0.5, 0.5, 0.4, 0.55, 0.3, 0.4, 0.1, 0.5, 0.1]
}
```

**İşleyiş:**
1. Kullanıcının doğal dil mesajı ve mevcut session vektörü sunucuya gönderilir
2. Sunucudaki Gemini modeli mesajı analiz ederek 9D mood vektörü üretir
3. Session vektörü kümülatif olarak güncellenir (önceki bağlam korunur)
4. Hem doğal dil yanıtı hem de güncel vektör döner

### 4.2. `POST /api/recommend` — Şarkı Önerisi

**İstek:**
```json
{
  "mood_vector": [0.5, 0.5, 0.4, 0.55, 0.3, 0.4, 0.1, 0.5, 0.1],
  "n": 15
}
```

**Yanıt:**
```json
{
  "mode": "cosine",
  "feed": [
    {
      "song_id": 42,
      "track_name": "After Hours",
      "artists": "The Weeknd",
      "track_genre": "Alternative R&B",
      "popularity": 85,
      "match_score": 0.95,
      "image_url": null
    }
  ]
}
```

**İşleyiş:**
1. Mood vektörü sunucuya gönderilir
2. Sunucudaki Recommendation Engine, ~114K şarkılık veritabanında cosine similarity hesaplar
3. En yüksek match score'a sahip N şarkı döner
4. İstemci tarafında Apple Music API ile artwork/preview URL zenginleştirmesi yapılır

### 4.3. `POST /api/swipe` — Beğeni Geribildirimi

**İstek:**
```json
{
  "liked_songs": [
    {
      "song_id": 42,
      "title": "After Hours",
      "artist": "The Weeknd",
      "album_art": "https://...",
      "apple_music_id": "12345"
    }
  ],
  "disliked_song_ids": [10, 15, 23],
  "current_mood_vector": [0.5, 0.5, 0.4, ...]
}
```

**Yanıt:**
```json
{
  "status": "ok",
  "new_vector": [0.48, 0.52, 0.38, ...],
  "message": "Swipe session processed"
}
```

**İşleyiş:**
1. Tüm swipe oturumu tek bir batch request ile gönderilir
2. Beğenilen şarkılar Firestore'a kaydedilir (favorites olur)
3. Beğeni/beğenmeme verileriyle mood vektörü sunucu tarafında güncellenir
4. Güncellenen vektör istemciye dönerek gelecek önerileri iyileştirir

### 4.4. `GET /api/favorites` — Favori Listesi

**Yanıt:**
```json
{
  "favorites": [
    {
      "song_id": "42",
      "title": "After Hours",
      "artist": "The Weeknd",
      "album_art": "https://...",
      "apple_music_id": "12345",
      "added_at": "2026-06-19T12:00:00Z"
    }
  ],
  "has_more": false
}
```

### 4.5. `GET /health` — Sunucu Sağlık Kontrolü

**Yanıt:**
```json
{
  "status": "ok",
  "api_secure": true
}
```

---

## 5. Temel Akışların Detaylı Analizi

### 5.1. Discovery (Keşif) Akışı

```
DiscoveryContainerView
  │
  ├── [landing] → DiscoveryLandingView
  │     ├── "Start Discovering" → fetchSongsWithDefaultMood()
  │     └── "Describe Your Mood" → MoodInputView
  │
  ├── [moodInput] → MoodInputView
  │     ├── Preset mood chip'leri (ör: "Midnight drive")
  │     └── Serbest metin girişi → analyzeMoodAndFetchSongs()
  │
  ├── [loading] → LoadingView (animasyonlu bekleme)
  │
  ├── [swipeCards] → DiscoverySwipeView
  │     ├── CardStackView → Tinder-tarzı kart yığını
  │     ├── ActionButtonsView → Dislike / Play / Like butonları
  │     ├── Sola kaydır → swipeLeft() → dislikedSongIds'e ekle
  │     ├── Sağa kaydır → swipeRight() → likedSongs'a ekle
  │     └── Tüm kartlar bitti → submitSwipeSession() → /api/swipe
  │
  ├── [empty] → "All caught up!" + "New Mood" butonu
  └── [error] → Hata mesajı + "Try Again" butonu
```

**State machine** (`DiscoveryState` enum):
- `.landing` → `.moodInput` → `.loading` → `.swipeCards` → `.empty`
- `.error(String)` herhangi bir aşamadan tetiklenebilir

### 5.2. Chat (AI Sohbet) Akışı

```
HomeView
  └── NavigationLink → MoodChatView
       │
       ├── AI selamlama mesajı gösterilir
       ├── Mood preset chip'leri sunulur
       │
       ├── Kullanıcı mesaj yazar
       │     ├── Mesaj messages dizisine eklenir
       │     ├── Typing indicator gösterilir
       │     ├── /api/chat → session vektörü güncellenir
       │     ├── /api/recommend → vektörle şarkı önerileri çekilir
       │     └── AI yanıtı + şarkı önerileri birlikte gösterilir
       │
       └── Session vektörü her mesajda kümülatif olarak evrilir
           (Önceki konuşma bağlamı korunur)
```

**Kümülatif evrim mekanizması:**
1. Oturum başında vektör `[0.5, 0.5, ..., 0.5]` (nötr)
2. Her mesajda güncel vektör backend'e gönderilir
3. Backend, hem yeni mesajı hem önceki vektörü dikkate alarak güncel vektörü döner
4. Böylece "önce hüzünlü, sonra biraz daha enerjik" gibi doğal duygu geçişleri yakalanır

### 5.3. Kimlik Doğrulama Akışı

```
RootView (Auth state observer)
  │
  ├── currentUser == nil → LoginView / SignUpView
  │     ├── Firebase email/password auth
  │     ├── Doğrulama kuralları (email format, şifre uzunluğu)
  │     └── Hata kodlarına göre Türkçe/İngilizce mesajlar
  │
  └── currentUser != nil → MainTabView
        └── Her API isteğinde Firebase ID token otomatik eklenir
```

**Token yönetimi:**
- `FirebaseAuthService.getIDToken()` her API isteğinde çağrılır
- Token süresi dolmuşsa Firebase otomatik yeniler
- `APIClient.authTokenProvider` closure'ı ile token enjekte edilir
- Race condition koruması: Auth state senkronizasyonu için 0.5s bekleme

### 5.4. Apple Music Zenginleştirme Akışı

```
API'den gelen şarkı listesi (title + artist)
  │
  ▼
TaskGroup ile paralel Apple Music arama
  │
  ├── MusicCatalogSearchRequest(term: "title artist", types: [Song])
  │
  ▼
Her şarkı için zenginleştirme:
  ├── appleMusicId → Katalog ID'si
  ├── title/artistName → Apple Music'ten düzeltilmiş versiyon
  ├── artwork URL (600x600) → Yüksek çözünürlüklü albüm kapağı
  ├── durationInMillis → Şarkı süresi
  └── previewURL → 30 saniyelik önizleme URL'si
```

### 5.5. Ses Çalma Mekanizması

`AudioPlayerViewModel` iki modda çalışır:

1. **Gerçek çalma (AVPlayer):** Apple Music preview URL'si varsa `AVPlayer` ile 30s preview çalar
2. **Simülasyon modu:** Preview URL yoksa progress bar'ı timer ile ilerletir (görsel geri bildirim)

```
play(song:)
  ├── Aynı şarkı → togglePlayback()
  └── Yeni şarkı
       ├── previewURL var → AVPlayer ile çal
       │     ├── Periodic time observer (0.1s aralıkla progress güncelle)
       │     └── End observer (şarkı bitince sıfırla)
       └── previewURL yok → Simülasyon başlat (Timer ile)
```

---

## 6. Dosya Yapısı ve Sorumluluklar

```
NlpMusicRecomSystem/
├── NlpMusicRecomSystemApp.swift   ← @main entry point, Firebase init
├── AppDelegate.swift              ← UIKit delegate (minimal)
├── GoogleService-Info.plist       ← Firebase konfigürasyonu
├── Info.plist                     ← API_BASE_URL referansı
│
├── Configuration/
│   ├── Secrets.xcconfig           ← API_BASE_URL (git-ignored)
│   └── AppleMusicToken.swift      ← Apple Music developer token
│
├── Models/
│   ├── Song.swift                 ← Ana domain model (şarkı)
│   ├── ChatMessage.swift          ← Sohbet mesajı modeli
│   ├── MoodVector.swift           ← 9D duygu vektörü
│   ├── UserInteraction.swift      ← Swipe etkileşimi
│   └── AppTab.swift               ← Tab bar enum'u
│
├── ViewModels/
│   ├── AuthViewModel.swift        ← Login/SignUp iş mantığı
│   ├── ChatViewModel.swift        ← AI chat + session yönetimi
│   ├── DiscoveryViewModel.swift   ← Swipe + mood analiz state machine
│   ├── FavoritesViewModel.swift   ← Favori listesi + enrichment
│   └── AudioPlayerViewModel.swift ← AVPlayer + simülasyon
│
├── Views/
│   ├── RootView.swift             ← Auth-gated root router
│   ├── MainTabView.swift          ← Tab navigation controller
│   ├── Auth/
│   │   ├── LoginView.swift        ← Giriş ekranı
│   │   ├── SignUpView.swift       ← Kayıt ekranı
│   │   └── AuthComponents.swift   ← Ortak UI bileşenleri
│   ├── Home/
│   │   ├── LandingHomeView.swift  ← Ana sayfa (hero + CTA)
│   │   ├── HomeView.swift         ← Chat hub ekranı
│   │   ├── HeroBannerView.swift   ← Animasyonlu banner
│   │   └── RecommendedSectionView.swift ← Öneri carousel'i
│   ├── Chat/
│   │   ├── MoodChatView.swift     ← AI sohbet ekranı
│   │   └── Components/            ← ChatBubbleView, InputBar vb.
│   ├── Discovery/
│   │   ├── DiscoveryContainerView.swift  ← State-driven container
│   │   ├── DiscoveryLandingView.swift    ← Keşif giriş ekranı
│   │   ├── DiscoverySwipeView.swift      ← Tinder-tarzı swipe
│   │   ├── MoodInputView.swift           ← Mood metin girişi
│   │   └── Components/                   ← CardStack, ActionButtons
│   ├── Favorites/
│   │   ├── FavoritesView.swift    ← Favoriler listesi
│   │   └── Components/            ← MiniPlayer vb.
│   ├── Profile/
│   │   └── ProfileView.swift      ← Profil + çıkış
│   └── Common/
│       ├── CustomTabBar.swift     ← Özel tab bar
│       ├── FlowLayout.swift       ← Dinamik chip layout
│       └── LoadingView.swift      ← Animasyonlu yükleme
│
├── Services/
│   ├── Protocols/                 ← Soyut servis kontratları
│   │   ├── RecommendationServiceProtocol.swift
│   │   ├── ChatServiceProtocol.swift
│   │   ├── FeedbackServiceProtocol.swift
│   │   ├── FavoritesServiceProtocol.swift
│   │   ├── AuthServiceProtocol.swift
│   │   ├── AppleMusicServiceProtocol.swift
│   │   └── NLPServiceProtocol.swift
│   ├── API/                       ← Gerçek API implementasyonları
│   │   ├── APIRecommendationService.swift
│   │   ├── APIChatService.swift
│   │   ├── APIFeedbackService.swift
│   │   ├── APIFavoritesService.swift
│   │   ├── FirebaseAuthService.swift
│   │   ├── AppleMusicService.swift
│   │   └── APIHealthService.swift
│   └── Mock/                      ← Test/UI geliştirme mock'ları
│       ├── MockChatService.swift
│       ├── MockRecommendationService.swift
│       ├── MockFavoritesService.swift
│       ├── MockFeedbackService.swift
│       └── MockNLPService.swift
│
├── Networking/
│   ├── APIClient.swift            ← Generic HTTP istemci
│   ├── APIEnvironment.swift       ← Endpoint URL tanımları
│   └── DTOs/                      ← Data Transfer Objects
│       ├── ChatRequestDTO.swift
│       ├── RecommendRequestDTO.swift
│       ├── RecommendResponseDTO.swift
│       ├── SwipeRequestDTO.swift
│       ├── FavoritesResponseDTO.swift
│       └── HealthResponseDTO.swift
│
├── DI/
│   └── DIContainer.swift          ← Dependency injection container
│
├── DesignSystem/
│   ├── Theme.swift                ← Renk, font, boyut token'ları
│   └── Components/
│       ├── GlassmorphicCard.swift ← Cam efektli kart bileşeni
│       ├── GradientBackground.swift ← Gradient arkaplan
│       ├── AlbumArtPlaceholder.swift ← Placeholder gradient
│       └── AnimatedSparkle.swift  ← Parlama animasyonu
│
└── Extensions/
    └── Color+Hex.swift            ← Hex renk kodu desteği
```

---

## 7. Tasarım Sistemi

### 7.1. Renk Paleti

| Token | Hex Kodu | Kullanım |
|-------|----------|----------|
| `primary` | `#5856D6` | Ana aksyon rengi (Vibrant Indigo) |
| `background` | `#000000` | OLED optimize siyah arkaplan |
| `secondaryBg` | `#1C1C1E` | Kart ve input arkaplanları |
| `tertiaryBg` | `#2C2C2E` | Seçili satır, yükseltilmiş yüzeyler |
| `accentTeal` | `#4B8EFF` | Birincil konteyner rengi |
| `accentPurple` | `#C2C1FF` | İkincil vurgu |
| `accentPink` | `#FFB595` | Üçüncül vurgu / hata |

### 7.2. Tipografi (HIG Uyumlu)

| Token | Boyut | Ağırlık | Kullanım |
|-------|-------|---------|----------|
| `largeTitleFont` | 34pt | Bold | Ekran başlıkları |
| `titleFont` | 28pt | Bold | Bölüm başlıkları |
| `headlineFont` | 17pt | Semibold | Kart başlıkları |
| `bodyFont` | 17pt | Regular | Gövde metni |
| `captionFont` | 13pt | Regular | Metadata, zaman damgaları |
| `chipFont` | 13pt | Medium | Chip etiketleri |

### 7.3. Tasarım Bileşenleri

- **GlassmorphicCard:** Yarı saydam cam efektli kart (dark theme uyumlu)
- **GradientBackground:** Uygulama genelinde kullanılan gradient arkaplan
- **AlbumArtPlaceholder:** Albüm kapağı olmayan şarkılar için benzersiz gradient placeholder
- **AnimatedSparkle:** AI etkileşimlerinde kullanılan parlama efekti
- **CustomTabBar:** 5 sekme (Home, Chat, Discovery, Library, Profile) ile özel tab bar
- **FlowLayout:** Mood chip'leri için dinamik wrap layout

---

## 8. Kullanılan Teknolojiler ve Frameworkler

### iOS Tarafı
| Teknoloji | Versiyon/Detay | Kullanım Amacı |
|-----------|----------------|----------------|
| **Swift** | 5.9+ | Ana programlama dili |
| **SwiftUI** | iOS 16+ | Deklaratif UI framework |
| **Combine** | Apple | Reaktif state yönetimi (auth publisher) |
| **MusicKit** | Apple | Apple Music katalog arama + preview |
| **AVFoundation** | Apple | 30s preview ses çalma |
| **Firebase Auth** | Google | Email/password kimlik doğrulama |
| **Firebase Core** | Google | Firebase altyapısı |
| **URLSession** | Apple | HTTP networking (3rd-party yok) |

### Backend Tarafı (Sunucu)
| Teknoloji | Kullanım Amacı |
|-----------|----------------|
| **FastAPI** (Python) | REST API sunucusu |
| **Google Gemini** | NLP duygu analizi (doğal dil → 9D vektör) |
| **Firebase Admin SDK** | Token doğrulama + Firestore erişimi |
| **Firestore** | Favori şarkı depolama (kullanıcı bazlı) |
| **Cosine Similarity** | Vektör-şarkı eşleştirme (~114K şarkı DB) |

### Önemli Tasarım Kararları
- **3rd-party HTTP kütüphanesi yok:** URLSession + async/await ile sade networking
- **3rd-party DI framework yok:** Manuel container ile basit, anlaşılır injection
- **3rd-party state management yok:** SwiftUI native `@StateObject`, `@Published`, `@State`
- **Snake_case ↔ camelCase otomatik dönüşüm:** `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase`

---

## 9. Güvenlik Modeli

```
[Kullanıcı] → [Firebase Auth] → [ID Token]
                                      │
                                      ▼
                              [APIClient.authTokenProvider]
                                      │
                                      ▼
                              [Authorization: Bearer <token>]
                                      │
                                      ▼
                              [FastAPI Backend]
                                      │
                              [Firebase Admin SDK ile doğrulama]
                                      │
                                      ▼
                              [Kullanıcı UID ile Firestore erişimi]
```

- API_BASE_URL `Secrets.xcconfig` dosyasında tutulur (.gitignore ile korunur)
- Firebase konfigürasyonu `GoogleService-Info.plist` ile sağlanır
- Tüm API istekleri `Authorization: Bearer` header'ı taşır
- 401/403 yanıtları `APIError.authenticationRequired` olarak yakalanır

---

## 10. Öne Çıkan Teknik Detaylar

### 10.1. Kümülatif Session Vektörü (Chat)
Chat'te her mesajda vektör sunucuya gönderilir ve backend tarafından evrilir. Bu sayede:
- "Bugün üzgünüm" → "Ama biraz dans edebilecek bir şey" geçişi doğal olarak yakalanır
- Oturum sıfırlandığında vektör `[0.5, ..., 0.5]`'e döner

### 10.2. Batch Swipe Gönderimi
Swipe aksiyonları tek tek değil, tüm kartlar bittiğinde tek bir batch olarak gönderilir:
- Network trafiğini azaltır
- Sunucu tarafında atomik işlem sağlar
- `isSubmitting` flag'i ile yarış durumu koruması

### 10.3. Paralel Apple Music Enrichment
`TaskGroup` kullanılarak tüm şarkılar paralel olarak Apple Music API'den zenginleştirilir:
- Artwork (600x600 yüksek çözünürlük)
- 30s preview URL
- Doğru başlık/sanatçı bilgisi
- Şarkı süresi

### 10.4. AVPlayer Fallback Mekanizması
Preview URL bulunmayan şarkılar için `Timer` tabanlı simülasyon modu devreye girer. Bu sayede kullanıcı deneyimi kesintisiz devam eder.

---

## 11. Test Altyapısı

Projede test klasörleri mevcuttur:
- `NlpMusicRecomSystemTests/` — Unit test hedefi
- `NlpMusicRecomSystemUITests/` — UI test hedefi

Mock servisler test edilebilirlik için hazırlanmıştır:
- `MockChatService` — Gecikme simülasyonu + rastgele yanıtlar
- `MockRecommendationService` — Sabit şarkı kataloğu
- `MockNLPService` — Keyword-based mock mood analizi
- `MockFeedbackService` — No-op swipe handler
- `MockFavoritesService` — Boş favori listesi

---

## 12. Gelecek Potansiyeli ve Geliştirme Alanları

| Alan | Mevcut Durum | Potansiyel İyileştirme |
|------|-------------|----------------------|
| **Backend NLP** | Gemini API | Fine-tuned model ile daha hassas mood analizi |
| **Öneri Motoru** | Cosine similarity | Collaborative filtering / hibrit model |
| **Müzik Çalma** | 30s preview | Apple Music subscription ile tam şarkı |
| **Sosyal Özellik** | Yok | Paylaşılan playlistler, mood haritası |
| **Offline Destek** | Yok | Core Data ile yerel cache |
| **Çoklu Dil** | EN/TR karışık | Localization altyapısı |
| **Analytics** | Debug print | Firebase Analytics entegrasyonu |
| **Onboarding** | Yok | İlk kullanım deneyimi wizard'ı |
| **Widget** | Yok | iOS widget ile anlık mood önerisi |
| **watchOS** | Yok | Apple Watch companion app |

---

## 13. Projeyi Çalıştırma Gereksinimleri

1. **Xcode 15+** (Swift 5.9)
2. **iOS 16+** hedef cihaz/simülatör
3. **Apple Developer hesabı** (MusicKit entitlements için)
4. **Firebase projesi** (GoogleService-Info.plist)
5. **FastAPI backend** çalışıyor olmalı
6. `Configuration/Secrets.xcconfig` dosyasında `API_BASE_URL` ayarlanmalı

```
// Yerel geliştirme:
API_BASE_URL = http:/$()/localhost:8000

// Uzak sunucu:
API_BASE_URL = https:/$()/your-server.com
```

---

## 14. Özet

**Musaic**, doğal dil işleme (NLP) ve müzik öneri sistemlerini birleştiren, modern iOS mimari kalıplarını (MVVM, Protocol-Oriented DI, Swift Concurrency) uygulayan ve Apple ekosistemiyle (MusicKit, AVFoundation, Firebase) entegre çalışan kapsamlı bir iOS uygulamasıdır.

Projenin ayırt edici özelliği, kullanıcının **duygu durumunu doğal dilde ifade etmesine** izin vererek bunu **9 boyutlu bir müzikal profil vektörüne** dönüştürmesi ve bu vektörü **kümülatif olarak rafine ederek** giderek daha isabetli öneriler sunmasıdır.
