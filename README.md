# Musaic — AI-Powered Music Discovery App

> **An iOS native application that analyzes your mood through natural language and recommends music that matches how you feel — powered by NLP, a custom PyTorch recommendation engine, and Apple Music.**

<br/>

## 📱 Overview

Musaic bridges the gap between how you **feel** and what you **hear**. Instead of relying on past listening history, Musaic interprets what you write — in Turkish or English — and translates your emotional state into a personalized music feed in real time.

**Example:** A user types *"I feel like driving at night"* — Musaic detects the mood, maps it to a 9-dimensional audio feature vector, and surfaces tracks with matching energy, acousticness, and tempo.

<br/>

## ✨ Features

- 🎙️ **Natural Language Mood Input** — Describe how you feel in your own words
- 🃏 **Swipe-Based Discovery** — Tinder-style card interface to explore recommendations
- ❤️ **Favorites Library** — Save liked tracks, accessible offline
- 🔄 **Adaptive Learning** — The more you swipe, the more personalized the feed becomes
- 🎵 **Apple Music Integration** — Stream full songs directly inside the app via MusicKit
- 🔒 **Firebase Authentication** — Secure sign-up / sign-in with email & password

<br/>

## 🏗️ Architecture

### iOS (SwiftUI)
```
MVVM + Protocol-Oriented Dependency Injection
│
├── Views/           → SwiftUI screens (Chat, Discovery, Favorites, Home, Auth)
├── ViewModels/      → Business logic, state management
├── Services/        → API, Firebase Auth, Apple Music (protocol-based, mockable)
├── Models/          → Data types (Song, MoodVector, ChatMessage, ...)
├── Networking/      → Generic APIClient (URLSession + async/await)
├── DI/              → DIContainer — single source of truth for dependencies
└── DesignSystem/    → Reusable components, theme, animations
```

**Key Design Decisions:**
- **Client-Led State Management** — The backend is fully stateless. The mood vector and liked count are stored locally on the device (UserDefaults) and sent with each request. This eliminates database round-trips on the `/api/chat` endpoint.
- **Protocol-Oriented Services** — Every service has a protocol and a mock implementation, enabling testability without a running backend.

### Backend (FastAPI + PyTorch)
```
backend/
├── api.py           → FastAPI app, all endpoints, rate limiter
├── auth.py          → Firebase Admin SDK token verification
├── recommend.py     → PyTorch recommendation engine + Euclidean similarity
├── model.py         → Neural network model definition
├── models/          → Pre-trained weights (model.pt), scaler, dataset
├── dataset.csv      → Raw music dataset (~105K tracks)
└── requirements_core.txt
```

**Endpoints:**

| Method | Endpoint | Description | Rate Limit |
|--------|----------|-------------|------------|
| `POST` | `/api/chat` | NLP mood analysis via Gemini → mood vector | 20 req/min |
| `POST` | `/api/recommend` | Retrieve personalized song recommendations | — |
| `POST` | `/api/swipe` | Submit swipe feedback, update profile vector | 20 req/min |
| `GET`  | `/api/favorites` | Fetch saved favorites (paginated) | — |
| `GET`  | `/health` | Server health check | — |

### Data Flow
```
[User types mood]
      ↓
[iOS → POST /api/chat]
      ↓
[Gemini LLM → 9D audio feature vector]
      ↓
[iOS stores vector locally]
      ↓
[iOS → POST /api/recommend + vector]
      ↓
[PyTorch engine → Euclidean distance → top-N songs]
      ↓
[Apple Music API → stream matched tracks]
      ↓
[User swipes → POST /api/swipe → profile vector updated]
```

<br/>

## 🧠 Recommendation Engine

The engine operates on a **9-dimensional audio feature vector**:

```
[danceability, energy, valence, tempo, acousticness,
 instrumentalness, speechiness, loudness, liveness]
```

- **Cold Start** (`liked_count ≤ 5`): Recommendations are driven 100% by the Gemini-generated mood vector.
- **Mature User** (`liked_count > 5`): A weighted blend of the current mood (75%) and the accumulated user profile (25%) is used.
- **Swipe Feedback**: Each like/dislike updates the persistent profile vector in Firestore via Exponential Moving Average (EMA), gradually personalizing results over time.

<br/>

## 🔒 Security

| Layer | Mechanism |
|-------|-----------|
| Authentication | Firebase Auth (email/password, ID token per request) |
| API Authorization | Firebase Admin SDK token verification on every endpoint |
| Firestore Access | Direct client access **disabled** (`allow read, write: if false`) — only the backend Admin SDK can read/write |
| Rate Limiting | Dual-layer: IP-based (slowapi) + UID-based (sliding window) — 20 req/min on sensitive endpoints |
| Secrets | All keys managed via environment variables / `.gitignore`-protected local files |

<br/>

## 🚀 Getting Started

### Prerequisites
- Xcode 15+, iOS 16+, Swift 5.9+
- Python 3.10+
- A Firebase project with **Firestore** and **Authentication** enabled
- A Google Gemini API key
- An Apple Developer account with MusicKit entitlement

### iOS Setup

```bash
git clone https://github.com/berkebalci/Musaic-AI-powered-Music-Discovery-App.git
cd Musaic-AI-powered-Music-Discovery-App
```

1. Copy the Firebase config template and fill in your own values:
   ```bash
   cp NlpMusicRecomSystem/GoogleService-Info.plist.example \
      NlpMusicRecomSystem/GoogleService-Info.plist
   # Edit GoogleService-Info.plist with your Firebase project values
   ```
2. Create `NlpMusicRecomSystem/Configuration/Secrets.xcconfig` and add:
   ```
   API_BASE_URL = https://your-backend-url.com
   ```
3. Open `NlpMusicRecomSystem.xcodeproj` in Xcode, select your team, and run.

### Backend Setup

```bash
cd backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements_core.txt

# Set up environment variables
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

# Place your Firebase service account key
# (Download from Firebase Console → Project Settings → Service Accounts)
cp ~/Downloads/your-firebase-adminsdk.json firebase-key.json

# Run the server
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

> ⚠️ **Never commit** `firebase-key.json`, `.env`, or `GoogleService-Info.plist`. These are protected by `.gitignore`.

<br/>

## 📊 Dataset

The recommendation engine is trained on a dataset of ~105,000 tracks spanning multiple genres, each annotated with Spotify audio features. Pre-trained model weights (`models/model.pt`) and the feature scaler (`models/scaler.pkl`) are included in the repository.

<br/>

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| iOS | Swift 5.9, SwiftUI, MusicKit, Combine |
| Backend | Python 3.10, FastAPI, Uvicorn |
| AI / NLP | Google Gemini API (`gemini-2.5-flash`) |
| ML Engine | PyTorch, Euclidean Similarity |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Rate Limiting | slowapi (IP) + custom sliding window (UID) |

<br/>

## 👥 Contributors

| Name | Role |
|------|------|
| [Berke Balcı](https://github.com/berkebalci) | iOS Development, Architecture, API Integration |
| [İlayda](https://github.com/ilaydabaran32) | Backend (FastAPI), PyTorch Model, Recommendation Engine |

<br/>

## 📄 License

This project was developed as a graduation thesis. All rights reserved.