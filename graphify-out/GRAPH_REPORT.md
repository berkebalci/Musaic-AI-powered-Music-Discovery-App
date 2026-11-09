# Graph Report - NlpMusicRecomSystem  (2026-11-06)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 672 nodes · 1206 edges · 36 communities (24 shown, 12 thin omitted)
- Extraction: 87% EXTRACTED · 13% INFERRED · 0% AMBIGUOUS · INFERRED: 151 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c85807e8`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- APIError
- DiscoveryViewModel
- AuthViewModel
- LikedSongItemDTO
- Foundation
- LandingHomeView
- ChatMessage
- AppTab
- DiscoveryState
- Song
- ProfileView
- FirebaseAuthService
- APIRecommendationService
- SwipeCardView
- View
- NlpMusicRecomSystemUITests
- AlbumArtPlaceholder
- FlowLayout
- GradientBackground
- Theme
- APIEnvironment
- ChatBubbleView
- ChatSongCardView
- RecommendedSectionView
- ChatInputBarView
- .isWithinPast
- SongRowView
- GlassmorphicCard
- NlpMusicRecomSystemTests.swift

## God Nodes (most connected - your core abstractions)
1. `DiscoveryViewModel` - 34 edges
2. `Song` - 31 edges
3. `AudioPlayerViewModel` - 28 edges
4. `Theme` - 26 edges
5. `FirebaseAuthService` - 25 edges
6. `AuthViewModel` - 24 edges
7. `FavoritesViewModel` - 19 edges
8. `ProfileView` - 18 edges
9. `SwipeCardView` - 17 edges
10. `AppTab` - 17 edges

## Surprising Connections (you probably didn't know these)
- `.favoritesSection` --calls--> `RecommendedSectionView`  [INFERRED]
  NlpMusicRecomSystem/Views/Profile/ProfileView.swift → NlpMusicRecomSystem/Views/Home/RecommendedSectionView.swift
- `.body` --calls--> `DiscoveryContainerView`  [INFERRED]
  NlpMusicRecomSystem/Views/MainTabView.swift → NlpMusicRecomSystem/Views/Discovery/DiscoveryContainerView.swift
- `.body` --calls--> `ActionButtonsView`  [INFERRED]
  NlpMusicRecomSystem/Views/Discovery/DiscoverySwipeView.swift → NlpMusicRecomSystem/Views/Discovery/Components/ActionButtonsView.swift
- `.moodPresetChips` --calls--> `MoodChipView`  [INFERRED]
  NlpMusicRecomSystem/Views/Chat/MoodChatView.swift → NlpMusicRecomSystem/Views/Discovery/Components/MoodChipView.swift
- `.moodPresetChips` --calls--> `MoodChipView`  [INFERRED]
  NlpMusicRecomSystem/Views/Discovery/MoodInputView.swift → NlpMusicRecomSystem/Views/Discovery/Components/MoodChipView.swift

## Import Cycles
- None detected.

## Communities (36 total, 12 thin omitted)

### Community 0 - "APIError"
Cohesion: 0.05
Nodes (23): APIClient, APIClientProtocol, APIError, authenticationRequired, autherizationFailed, decodingFailed, .errorDescription, httpError (+15 more)

### Community 1 - "DiscoveryViewModel"
Cohesion: 0.06
Nodes (16): AudioPlayerViewModel, .progressFraction, DiscoveryViewModel, .currentSong, CardStackView, .body, DiscoveryContainerView, .body (+8 more)

### Community 2 - "AuthViewModel"
Cohesion: 0.06
Nodes (17): AuthServiceProtocol, AuthViewModel, Mode, signIn, signUp, AuthTextField, .body, ErrorBanner (+9 more)

### Community 3 - "LikedSongItemDTO"
Cohesion: 0.06
Nodes (11): ChatRequestDTO, ChatResponseDTO, FavoriteSongDTO, FavoritesResponseDTO, HealthResponseDTO, .isHealthy, RecommendResponseDTO, SongDTO (+3 more)

### Community 4 - "Foundation"
Cohesion: 0.06
Nodes (20): AuthenticationServices, AVFoundation, Combine, CryptoKit, FirebaseAuth, FirebaseCore, Foundation, MusicKit (+12 more)

### Community 5 - "LandingHomeView"
Cohesion: 0.06
Nodes (14): DIContainer, MockChatService, MockFeedbackService, MockRecommendationService, ChatServiceProtocol, FavoritesServiceProtocol, FeedbackServiceProtocol, RecommendationResult (+6 more)

### Community 6 - "ChatMessage"
Cohesion: 0.09
Nodes (13): AnimatedSparkle, .body, ChatMessage, ChatViewModel, MoodChatView, .body, .chatBackground, .moodPresetChips (+5 more)

### Community 7 - "AppTab"
Cohesion: 0.07
Nodes (18): AppTab, chat, discovery, home, .iconName, .id, profile, .title (+10 more)

### Community 8 - "DiscoveryState"
Cohesion: 0.07
Nodes (14): MoodVector, .dominantMood, .normalized, UserInteraction, MockNLPService, AuthUser, NLPServiceProtocol, DiscoveryState (+6 more)

### Community 9 - "Song"
Cohesion: 0.10
Nodes (8): Song, .artworkURL, .durationString, MockFavoritesService, .currentIndex, .visibleCards, FavoritesViewModel, .filteredFavorites

### Community 10 - "ProfileView"
Cohesion: 0.08
Nodes (15): ActionButtonsView, .body, MoodChipView, .body, ScaleButtonStyle, .startDiscoveringButton, .ctaButtons, ProfileView (+7 more)

### Community 11 - "FirebaseAuthService"
Cohesion: 0.12
Nodes (3): FirebaseAuthService, .currentUser, .currentUserPublisher

### Community 13 - "SwipeCardView"
Cohesion: 0.16
Nodes (6): SwipeCardView, .body, .dragGesture, .dragProgress, .isSwipingRight, .swipeOverlay

### Community 14 - "View"
Cohesion: 0.21
Nodes (5): DiscoveryLandingView, .featuredCardStack, .mainFeaturedCard, HeroBannerView, .body

### Community 15 - "NlpMusicRecomSystemUITests"
Cohesion: 0.15
Nodes (4): NlpMusicRecomSystemUITests, NlpMusicRecomSystemUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, XCTest

### Community 16 - "AlbumArtPlaceholder"
Cohesion: 0.17
Nodes (5): AlbumArtPlaceholder, .body, .computedCornerRadius, .gradient, Color

### Community 18 - "GradientBackground"
Cohesion: 0.22
Nodes (7): GradientBackground, .body, MiniPlayerView, .body, .body, .body, .body

### Community 19 - "Theme"
Cohesion: 0.20
Nodes (4): Theme, LoadingView, .body, .cardContent

### Community 20 - "APIEnvironment"
Cohesion: 0.22
Nodes (7): APIEnvironment, .baseURL, .chatURL, .favoritesURL, .healthURL, .recommendURL, .swipeURL

### Community 21 - "ChatBubbleView"
Cohesion: 0.29
Nodes (6): ChatBubbleView, .bubbleBackground, .bubbleOverlay, .typingIndicator, TypingDot, .body

### Community 22 - "ChatSongCardView"
Cohesion: 0.29
Nodes (6): .body, ChatSongCardView, .body, .isCurrentSong, NowPlayingBars, .body

### Community 24 - "ChatInputBarView"
Cohesion: 0.29
Nodes (3): ChatInputBarView, .body, .inputBarBackground

### Community 26 - "SongRowView"
Cohesion: 0.33
Nodes (3): SongRowView, .body, .songList

### Community 28 - "NlpMusicRecomSystemTests.swift"
Cohesion: 0.40
Nodes (3): NlpMusicRecomSystem, NlpMusicRecomSystemTests, Testing

## Knowledge Gaps
- **74 isolated node(s):** `AppLinks`, `authenticationRequired`, `autherizationFailed`, `.errorDescription`, `invalidResponse` (+69 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 230 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Foundation` connect `Foundation` to `APIError`, `LikedSongItemDTO`, `LandingHomeView`, `ChatMessage`, `AppTab`, `DiscoveryState`, `Song`, `APIRecommendationService`, `APIEnvironment`, `.isWithinPast`?**
  _High betweenness centrality (0.228) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `DiscoveryViewModel` (e.g. with `.body` and `.moodInputCard`) actually correct?**
  _`DiscoveryViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppLinks`, `authenticationRequired`, `autherizationFailed` to the rest of the system?**
  _74 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `APIError` be split into smaller, more focused modules?**
  _Cohesion score 0.05081967213114754 - nodes in this community are weakly interconnected._
- **Why does `SwiftUI` connect `Foundation` to `APIError`, `DiscoveryViewModel`, `AuthViewModel`, `LandingHomeView`, `ChatMessage`, `AppTab`, `ProfileView`, `SwipeCardView`, `View`, `AlbumArtPlaceholder`, `FlowLayout`, `GradientBackground`, `Theme`, `ChatBubbleView`, `ChatSongCardView`, `RecommendedSectionView`, `ChatInputBarView`, `SongRowView`, `GlassmorphicCard`?**
  _High betweenness centrality (0.120) - this node is a cross-community bridge._
- **Are the 8 inferred relationships involving `Song` (e.g. with `.getRecommendations()` and `.currentIndex`) actually correct?**
  _`Song` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Should `DiscoveryViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.06271186440677966 - nodes in this community are weakly interconnected._