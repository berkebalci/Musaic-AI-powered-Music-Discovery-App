# Musaic Backend Integration Guide for iOS Agent

Bu doküman, iOS uygulamasını (Swift) geliştirecek olan AI Agent için hazırlanmıştır. Backend'in (FastAPI + PyTorch) nasıl çalıştığını, mimari kararları ve iOS tarafının üstlenmesi gereken görevleri detaylandırır.

> [!IMPORTANT]
> **Mimari Felsefe: Client-Led State Management**
> Backend tamamen "stateless" çalışacak şekilde tasarlanmıştır. Bu, kullanıcının o anki ruh hali (session) ve kalıcı müzik profili (mood vector) gibi durumların (state) **iOS tarafında lokal olarak (örn: UserDefaults, CoreData, SwiftData) saklanması gerektiği** anlamına gelir. Backend, Firestore'u okuma/yazma maliyetlerini düşürmek için sadece hesaplama motoru olarak davranır.

---

## 1. Temel Konsept: 9 Boyutlu Müzik Vektörü

Sistemin kalbinde, her şarkıyı ve kullanıcının müzik zevkini temsil eden 9 boyutlu bir özellik vektörü yatar.
Vektör dizilimi **KESİNLİKLE** aşağıdaki sırayla olmalıdır. Tüm değerler `[0.0, 1.0]` aralığındadır.

`[danceability, energy, valence, tempo, acousticness, instrumentalness, speechiness, loudness, liveness]`

iOS tarafı, varsayılan bir kullanıcı için `[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]` gibi nötr bir vektörle başlamalıdır.

---

## 2. iOS Tarafında Tutulması Gereken State'ler

iOS uygulamasının kendi lokal hafızasında tutması ve API isteklerine eklemesi gereken 2 temel vektör vardır:

1.  **`current_mood_vector` (Kalıcı Profil Vektörü)**
    *   Kullanıcının genel müzik zevkini yansıtır.
    *   Kullanıcı şarkıları kaydırdıkça (swipe - like/dislike) evrilir.
    *   İlk başta nötrdür (örn. hepsi 0.5).
2.  **`current_session_vector` (Geçici Chat Vektörü)**
    *   Kullanıcının Chat ekranındaki *anlık* ruh halini yansıtır.
    *   Chat'e her mesaj atıldığında güncellenir (Kümülatif evrilme).
    *   Kullanıcı Chat'ten çıkıp tamamen farklı bir moda girmek istediğinde bu vektör sıfırlanabilir.

---

## 3. Kimlik Doğrulama (Authentication)

Tüm endpoint'ler Firebase Authentication kullanır. iOS tarafı, kullanıcının güncel Firebase ID Token'ını almalı ve HTTP isteklerinin `Header` kısmına eklemelidir.

```http
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

---

## 4. API Endpoint Detayları ve Swift Modelleri İçin Referans

Tüm endpointler `POST` veya `GET` metodları ile çalışır ve JSON döner.

### 4.1. Chat Endpoint (`POST /api/chat`)
Kullanıcı AI ile sohbet ettiğinde çağrılır. "Kümülatif evrilme" destekler.

*   **Request Body (JSON):**
    ```json
    {
      "message": "Biraz daha tempolu olsun",
      "current_session_vector": [0.5, 0.6, 0.4, 0.8, 0.5, 0.5, 0.5, 0.5, 0.5] // iOS'taki anlık session vektörü
    }
    ```
*   **Response (JSON):**
    ```json
    {
      "reply": "Hemen tempoyu artırıyorum!",
      "vector": [0.55, 0.65, 0.45, 0.9, 0.4, 0.5, 0.4, 0.6, 0.5] // Harmanlanmış YENİ vektör
    }
    ```
*   **iOS Aksiyonu:** Gelen bu `vector` değerini al, lokaldeki `current_session_vector`'ün üzerine yaz. Bir sonraki mesaja bu yeni vektörü gönder. (Böylece AI, kullanıcının daha önce ne konuştuğunu hatırlar).

### 4.2. Recommend Endpoint (`POST /api/recommend`)
Kullanıcıya Discovery ekranı için yeni şarkılar önermek istendiğinde çağrılır. PyTorch motoru çalışır.

*   **Request Body:**
    ```json
    {
      "mood_vector": [0.5, 0.6, 0.4, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5], // iOS'taki kalıcı 'current_mood_vector' (veya Chat'ten gelen anlık vektör)
      "n": 15 // İstenen şarkı sayısı
    }
    ```
*   **Response:**
    ```json
    {
      "feed": [
        {
          "song_id": 1234,
          "track_name": "Blinding Lights",
          "artists": "The Weeknd",
          "match_score": 98.5
        }
      ]
    }
    ```

### 4.3. Swipe Endpoint (`POST /api/swipe`)
Kullanıcı Discovery ekranında kaydırma (swipe) oturumunu *tamamladığında* (veya kartlar bittiğinde/ekrandan çıktığında) **batch (toplu) olarak tek seferde** çağrılır. Her swipe için ayrı istek ATILMAMALIDIR.

*   **Request Body:**
    ```json
    {
      "liked_songs": [
        {
          "song_id": 1234,
          "title": "Blinding Lights",
          "artist": "The Weeknd",
          "album_art": "https://...",
          "apple_music_id": "1499385848"
        }
      ],
      "disliked_song_ids": [5678, 9012],
      "current_mood_vector": [0.5, 0.6, 0.4, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5] // iOS'taki mevcut KALICI profil vektörü
    }
    ```
*   **Response:**
    ```json
    {
      "status": "success",
      "new_profile_vector": [0.52, 0.61, 0.39, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5] // EMA ile güncellenmiş YENİ kalıcı vektör
    }
    ```
*   **iOS Aksiyonu:** Gelen `new_profile_vector` değerini al ve lokaldeki kalıcı profil vektörü (`current_mood_vector`) olarak kaydet. (Aynı zamanda bu vektör Firestore'a backend tarafından yedeklenmiştir).

### 4.4. Favorites Endpoint (`GET /api/favorites`)
Beğenilen şarkıları listeler. Pagination (sayfalama) destekler.

*   **Query Parameters:**
    *   `limit`: Getirilecek şarkı sayısı (default 20).
    *   `last_song_id`: Sayfalama için, bir önceki sayfadaki SON şarkının `song_id`'si. İlk sayfa için boş gönderilir.
*   **Response:**
    ```json
    {
      "favorites": [
        {
          "song_id": "1234",
          "title": "Blinding Lights",
          "artist": "The Weeknd",
          "album_art": "https://...",
          "apple_music_id": "1499385848",
          "added_at": "2024-03-24T12:00:00Z"
        }
      ],
      "has_more": true // Sonraki sayfa olup olmadığı
    }
    ```

---

## 5. iOS Tarafı İçin Kritik İpuçları (Agent'ın Dikkatine)

1.  **Sık Sık Model Güncelleme:** Uygulama açılışında, kullanıcının cihaz değiştirmesi veya silip tekrar yüklemesi ihtimaline karşı `current_mood_vector` değerini Firestore'dan (veya swipe sonrası endpoint dönüşünden) eşitleyecek bir mekanizma ekleyin.
2.  **UI Akışı:** Chat ekranından doğrudan Discovery/Swipe akışına geçiş olacaksa, Chat'in ürettiği `vector` değerini Recommend endpoint'ine `mood_vector` olarak geçin. Böylece öneriler anlık isteğe göre daralır.
3.  **Network Hataları:** Firebase Token'ı süresi dolarsa (genelde 1 saat) API 401 dönecektir. iOS SDK'sındaki `Auth.auth().currentUser?.getIDTokenForcingRefresh(true)` fonksiyonunu kullanarak token'ı yenileyip isteği tekrar eden (retry) bir interceptor/middleware yazmanız önerilir.
4.  **Fallback Mekanizmaları:** AI chat bir sebepten 0.5'lik boş vektör dönerse (exception durumu), uygulamanın çökmemesi için bu durumu tolere edecek varsayılan UI tepkileri tasarlayın.
