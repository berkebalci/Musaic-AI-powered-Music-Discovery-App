# Musaic — Tez Raporu Diyagramları (PDF Uyumlu)

> Her diyagram ayrı ayrı [mermaid.live](https://mermaid.live) üzerinden PNG/SVG olarak export edilebilir.
> Diyagramlar sadeleştirilmiş ve PDF'te okunabilir boyutta tasarlanmıştır.

---

## 1. UML Sınıf Diyagramları

### 1.1. MVVM Katmanları — View ve ViewModel İlişkileri

```mermaid
classDiagram
    direction LR

    class RootView {
        +container: DIContainer
        +body: some View
    }

    class MainTabView {
        +selectedTab: AppTab
        +body: some View
    }

    class AuthViewModel {
        +email: String
        +password: String
        +isLoading: Bool
        +signIn()
        +signUp()
    }

    class ChatViewModel {
        +messages: ChatMessage[]
        +inputText: String
        +isAITyping: Bool
        +sendMessage()
        +resetSession()
    }

    class DiscoveryViewModel {
        +moodText: String
        +state: DiscoveryState
        +cards: Song[]
        +swipeRight()
        +swipeLeft()
    }

    class FavoritesViewModel {
        +favorites: Song[]
        +searchText: String
        +loadFavorites()
    }

    class AudioPlayerViewModel {
        +currentSong: Song?
        +isPlaying: Bool
        +progress: Double
        +play()
        +stop()
    }

    RootView --> MainTabView
    RootView --> AuthViewModel
    MainTabView --> ChatViewModel
    MainTabView --> DiscoveryViewModel
    MainTabView --> FavoritesViewModel
    MainTabView --> AudioPlayerViewModel
```

### 1.2. Domain Modelleri

```mermaid
classDiagram
    direction TB

    class Song {
        +id: Int
        +title: String
        +artistName: String
        +genre: String
        +imageUrl: String?
        +popularity: Int?
        +score: Double?
        +appleMusicId: String?
        +previewURL: URL?
    }

    class ChatMessage {
        +id: UUID
        +content: String
        +isFromUser: Bool
        +timestamp: Date
        +suggestedSongs: Song[]
        +isLoading: Bool
    }

    class MoodVector {
        +danceability: Double
        +energy: Double
        +valence: Double
        +tempo: Double
        +acousticness: Double
        +instrumentalness: Double
        +speechiness: Double
        +loudness: Double
        +liveness: Double
        +dominantMood: String
    }

    class UserInteraction {
        +songId: Int
        +action: String
        +timestamp: Date
    }

    ChatMessage --> Song : suggestedSongs
    UserInteraction --> Song : references
```

### 1.3. Servis Protokolleri ve Implementasyonları

```mermaid
classDiagram
    direction TB

    class AuthServiceProtocol {
        <<interface>>
        +signIn(email, password)
        +signUp(email, password)
        +signOut()
        +getIDToken() String
    }

    class RecommendationServiceProtocol {
        <<interface>>
        +getRecommendations(moodText)
        +getRecommendations(vector, count)
    }

    class ChatServiceProtocol {
        <<interface>>
        +sendMessage(message, sessionVector)
    }

    class FeedbackServiceProtocol {
        <<interface>>
        +submitSwipeSession(liked, disliked, vector)
    }

    class FavoritesServiceProtocol {
        <<interface>>
        +fetchFavorites() Song[]
    }

    class FirebaseAuthService
    class APIRecommendationService
    class APIChatService
    class APIFeedbackService
    class APIFavoritesService

    FirebaseAuthService ..|> AuthServiceProtocol
    APIRecommendationService ..|> RecommendationServiceProtocol
    APIChatService ..|> ChatServiceProtocol
    APIFeedbackService ..|> FeedbackServiceProtocol
    APIFavoritesService ..|> FavoritesServiceProtocol
```

### 1.4. Networking Katmanı

```mermaid
classDiagram
    direction TB

    class APIClient {
        -session: URLSession
        -authTokenProvider: Closure
        +post(url, body, responseType)
        +get(url, responseType)
    }

    class APIEnvironment {
        <<enumeration>>
        +baseURL$
        +chatURL$
        +recommendURL$
        +swipeURL$
        +favoritesURL$
        +healthURL$
    }

    class DIContainer {
        +recommendationService
        +favoritesService
        +feedbackService
        +authService
        +chatService
        +live()$ DIContainer
        +mock()$ DIContainer
    }

    APIClient --> APIEnvironment : reads URLs
    DIContainer --> APIClient : creates
    DIContainer --> FirebaseAuthService : creates
    DIContainer --> APIRecommendationService : creates
    DIContainer --> APIChatService : creates

    class FirebaseAuthService
    class APIRecommendationService
    class APIChatService
```

---

## 2. Sequence (Sıralama) Diyagramları

### 2.1. Kimlik Doğrulama Akışı

```mermaid
sequenceDiagram
    actor User as Kullanıcı
    participant View as LoginView
    participant VM as AuthViewModel
    participant Auth as Firebase Auth

    User->>View: Email ve şifre girer
    User->>View: Sign In butonuna basar

    View->>VM: signIn()
    VM->>VM: Doğrulama kontrolü

    VM->>Auth: signIn(email, password)

    alt Başarılı
        Auth-->>VM: Giriş onaylandı
        Note over VM: Auth state değişir
        Note over View: RootView → MainTabView geçişi
    else Başarısız
        Auth-->>VM: Hata döner
        VM-->>View: Hata mesajı gösterilir
    end
```

### 2.2. Mood Analizi ve Şarkı Önerisi Akışı

```mermaid
sequenceDiagram
    actor User as Kullanıcı
    participant View as DiscoveryView
    participant VM as DiscoveryVM
    participant API as FastAPI Backend
    participant AM as Apple Music

    User->>View: Mood metni girer
    View->>VM: analyzeMoodAndFetchSongs()

    rect rgb(60, 60, 90)
        Note right of VM: Aşama 1 — NLP Analizi
        VM->>API: POST /api/chat (mesaj + vektör)
        API->>API: Gemini ile NLP analizi
        API-->>VM: AI yanıtı + 9D mood vektörü
    end

    rect rgb(60, 90, 60)
        Note right of VM: Aşama 2 — Şarkı Önerisi
        VM->>API: POST /api/recommend (vektör, n=15)
        API->>API: Cosine similarity hesaplama
        API-->>VM: 15 şarkı listesi
    end

    rect rgb(90, 60, 60)
        Note right of VM: Aşama 3 — Zenginleştirme
        VM->>AM: Paralel arama (artwork + preview)
        AM-->>VM: Albüm kapağı + 30s preview URL
    end

    VM-->>View: Swipe kartları gösterilir
    View-->>User: Kartları kaydırmaya başlar
```

### 2.3. Swipe Geribildirimi Akışı

```mermaid
sequenceDiagram
    actor User as Kullanıcı
    participant View as SwipeView
    participant VM as DiscoveryVM
    participant Player as AudioPlayer
    participant API as FastAPI Backend

    loop Her kart için
        View-->>User: Şarkı kartı gösterilir
        VM->>Player: preview çal

        alt Sağa kaydır
            User->>View: Beğen
            View->>VM: swipeRight(song)
            VM->>VM: likedSongs'a ekle
        else Sola kaydır
            User->>View: Beğenme
            View->>VM: swipeLeft(song)
            VM->>VM: dislikedSongIds'e ekle
        end
    end

    Note over VM: Tüm kartlar bitti

    VM->>API: POST /api/swipe (batch gönderim)
    API->>API: Firestore'a kaydet + vektör güncelle
    API-->>VM: Güncellenmiş mood vektörü
    VM-->>View: "All caught up!" gösterilir
```

### 2.4. AI Chat Akışı

```mermaid
sequenceDiagram
    actor User as Kullanıcı
    participant View as MoodChatView
    participant VM as ChatViewModel
    participant Chat as /api/chat
    participant Rec as /api/recommend
    participant Player as AudioPlayer

    Note over VM: sessionVector = [0.5, ..., 0.5]

    VM-->>View: AI selamlama mesajı

    User->>View: Mood mesajı yazar
    View->>VM: sendMessage()
    VM-->>View: Typing indicator

    VM->>Chat: POST (mesaj + sessionVector)
    Chat-->>VM: AI yanıtı + güncel vektör
    VM->>VM: sessionVector güncellenir

    VM->>Rec: POST (güncel vektör, n=5)
    Rec-->>VM: 5 şarkı önerisi

    VM-->>View: AI mesajı + şarkı kartları

    User->>View: Şarkıya dokunur
    View->>Player: play(song)
    Player-->>User: 30s preview çalar

    Note over VM: Sonraki mesajda vektör<br/>kümülatif olarak evrilir
```

---

## 3. Akış Diyagramları (Flowcharts)

### 3.1. Genel Uygulama Akışı

```mermaid
flowchart TD
    A([Uygulama Baslar]) --> B[Firebase Yapilandirilir]
    B --> C{Kullanici Giris Yapmis Mi?}

    C -->|Hayir| D[Login ve Kayit Ekrani]
    D --> E[Email ve Sifre ile Giris]
    E --> F{Basarili Mi?}
    F -->|Hayir| D
    F -->|Evet| C

    C -->|Evet| G[Ana Ekran ve Alt Navigasyon]

    G --> H[Ana Sayfa]
    G --> I[Yapay Zeka ile Sohbet]
    G --> J[Muzik Kesfi ve Swipe]
    G --> K[Favori Sarkilar]
    G --> L[Kullanici Profili]

    H --> H1[Hero Banner ve Oneriler]
    I --> I1[Sohbet ve Oneri Listesi]
    J --> J1[Duygu Analizi ve Kartlar]
    K --> K1[Begenilenler Listesi]
    L --> L1[Profil Yonetimi ve Cikis]
```

### 3.2. Discovery Detaylı Akışı

```mermaid
flowchart TD
    A([Discovery Açılır]) --> B{Nasıl başlamak\nistiyorsun?}

    B -->|Direkt başla| C[Varsayılan vektörle\nşarkı getir]
    B -->|Mood tanımla| D[Mood metin girişi]

    D --> E[Preset seç veya\nserbest metin yaz]
    E --> F[POST /api/chat\nNLP Analizi]

    C --> G[POST /api/recommend]
    F --> G

    G --> H[Apple Music\nZenginleştirme]
    H --> I{Şarkı bulundu mu?}

    I -->|Hayır| J[Boş sonuç ekranı]
    I -->|Hata| K[Hata ekranı]
    I -->|Evet| L[Swipe Kartları]

    L --> M{Kaydır}
    M -->|Sağa| N[Beğenilenlere ekle]
    M -->|Sola| O[Beğenmeyenlere ekle]

    N --> P{Kart kaldı mı?}
    O --> P

    P -->|Evet| L
    P -->|Hayır| Q[POST /api/swipe\nToplu gönderim]
    Q --> R[Mood vektörü güncellenir]
    R --> J

    J --> S{Tekrar dene?}
    K --> S
    S -->|Evet| A
```

### 3.3. API İstek Akışı

```mermaid
flowchart TD
    A([API İsteği]) --> B[URLRequest oluştur]
    B --> C[Firebase ID Token al]

    C --> D{Token alındı mı?}
    D -->|Hayır| E[❌ Auth Hatası]
    D -->|Evet| F[Authorization header ekle]

    F --> G[HTTP isteği gönder]
    G --> H{Yanıt durumu?}

    H -->|200-299| I[JSON Decode]
    H -->|401-403| J[❌ Yetki Hatası]
    H -->|Diğer 4xx/5xx| K[❌ Sunucu Hatası]
    H -->|Ağ yok| L[❌ Bağlantı Hatası]

    I --> M{Decode başarılı?}
    M -->|Evet| N[✅ Yanıt döner]
    M -->|Hayır| O[❌ Decode Hatası]
```

---

## 4. State (Durum) Diyagramı — Discovery Modülü

```mermaid
stateDiagram-v2
    [*] --> Landing

    Landing --> Loading : Direkt başla
    Landing --> MoodInput : Mood tanımla

    MoodInput --> Loading : Gönder

    Loading --> SwipeCards : Şarkılar yüklendi
    Loading --> Empty : Şarkı yok
    Loading --> Error : Hata oluştu

    SwipeCards --> SwipeCards : Kaydır
    SwipeCards --> Empty : Tüm kartlar bitti

    Empty --> Landing : Yeni mood
    Error --> Landing : Tekrar dene
```

---

## 5. Component (Bileşen) Diyagramı — Katmanlar

```mermaid
flowchart TB
    %% Layer 1: Presentation Layer
    subgraph Layer1["🖥️ PRESENTATION LAYER (SwiftUI)"]
        direction LR
        Views["<b>Views</b><br/>• RootView<br/>• MainTabView<br/>• LandingHomeView<br/>• MoodChatView<br/>• DiscoveryViews<br/>• FavoritesView<br/>• LoginView/SignUp<br/>• ProfileView"]
    end

    %% Layer 2: ViewModel Layer
    subgraph Layer2["⚙️ VIEWMODEL LAYER (MVVM — @MainActor, ObservableObject)"]
        direction LR
        VMs["<b>ViewModels</b><br/>• AuthViewModel<br/>• ChatViewModel<br/>• DiscoveryViewModel<br/>• FavoritesViewModel<br/>• AudioPlayerViewModel"]
    end

    %% Layer 3: Service Layer
    subgraph Layer3["🔌 SERVICE LAYER (Protocol-Oriented Abstraction)"]
        direction TB
        subgraph Protocols["📜 Protocols (Abstraction)"]
            P1["RecommendationServiceProtocol"]
            P2["ChatServiceProtocol"]
            P3["FeedbackServiceProtocol"]
            P4["FavoritesServiceProto"]
            P5["AuthServiceProtocol"]
            P6["AppleMusicServiceProto"]
            P7["NLPServiceProtocol"]
        end
        subgraph Impls["📦 Implementations (Production)"]
            I1["APIRecommendationService"]
            I2["APIChatService"]
            I3["APIFeedbackService"]
            I4["APIFavoritesService"]
            I5["FirebaseAuthService"]
            I6["AppleMusicService"]
        end
        subgraph Mocks["🧪 Mock Implementations (UI Dev)"]
            M1["MockChatService"]
            M2["MockRecommendationSvc"]
            M3["MockFavoritesService"]
            M4["MockFeedbackService"]
        end
        
        Protocols -.-> Impls
        Protocols -.-> Mocks
    end

    %% Layer 4: Networking Layer
    subgraph Layer4["🌐 NETWORKING LAYER"]
        direction TB
        Client["APIClient (Generic POST/GET, Auth Token Injection)"]
        Env["APIEnvironment (URL Endpoint Definitions)"]
        subgraph DTOs["✉️ DTOs (Request/Response Data Transfer Objects)"]
            D1["ChatRequestDTO / ChatResponseDTO"]
            D2["RecommendRequestDTO / RecommendResponseDTO"]
            D3["BatchSwipeRequestDTO / BatchSwipeResponseDTO"]
            D4["FavoritesResponseDTO"]
            D5["HealthResponseDTO"]
        end
        Client --> DTOs
        Env --> Client
    end

    %% Layer 5: DI Container
    subgraph Layer5["🏗️ DI CONTAINER"]
        direction LR
        DI["DIContainer.swift<br/>• <b>.live()</b> → Production API Services<br/>• <b>.mock()</b> → UI Development Mock Services"]
    end

    %% Layer 6: External Services
    subgraph Layer6["☁️ EXTERNAL SERVICES"]
        direction LR
        E1["Firebase Authentication"]
        E2["Firebase Firestore"]
        E3["Apple MusicKit"]
        E4["FastAPI Backend"]
    end

    %% Connect layers
    Layer1 --> Layer2
    Layer2 --> Layer5
    Layer5 --> Layer3
    Layer3 --> Layer4
    Layer4 --> Layer6

    %% Styling
    style Layer1 fill:#1a1c23,stroke:#707b93,stroke-width:2px,color:#fff
    style Layer2 fill:#1f2335,stroke:#bb9af7,stroke-width:2px,color:#fff
    style Layer3 fill:#1f2335,stroke:#7aa2f7,stroke-width:2px,color:#fff
    style Layer4 fill:#1f2335,stroke:#2ac3de,stroke-width:2px,color:#fff
    style Layer5 fill:#1a1c23,stroke:#ff9e64,stroke-width:2px,color:#fff
    style Layer6 fill:#1a1c23,stroke:#9ece6a,stroke-width:2px,color:#fff

    style Protocols fill:#24283b,stroke:#565f89,stroke-width:1px,color:#cfc9c2
    style Impls fill:#24283b,stroke:#2ac3de,stroke-width:1px,color:#cfc9c2
    style Mocks fill:#24283b,stroke:#ff9e64,stroke-width:1px,color:#cfc9c2
    style DTOs fill:#24283b,stroke:#565f89,stroke-width:1px,color:#cfc9c2
```
