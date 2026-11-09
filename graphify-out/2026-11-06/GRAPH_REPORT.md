# Graph Report - NlpMusicRecomSystem  (2026-10-08)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 584 nodes · 1091 edges · 29 communities (25 shown, 4 thin omitted)
- Extraction: 88% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 134 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ee15e963`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Song
- APIError
- AudioPlayerViewModel
- AuthViewModel
- SwiftUI
- DIContainer
- DiscoveryState
- AppTab
- LandingHomeView
- ChatViewModel
- FirebaseAuthService
- Decodable
- LikedSongItemDTO
- DiscoveryContainerView
- SwipeCardView
- AlbumArtPlaceholder
- ChatInputBarView
- NlpMusicRecomSystemUITests
- FlowLayout
- .sendMessage
- View
- Theme
- DiscoveryLandingView
- APIEnvironment
- ChatBubbleView
- ChatSongCardView
- NlpMusicRecomSystemTests.swift
- SongRowView

## God Nodes (most connected - your core abstractions)
1. `Song` - 49 edges
2. `AudioPlayerViewModel` - 36 edges
3. `DiscoveryViewModel` - 32 edges
4. `Theme` - 25 edges
5. `AuthViewModel` - 19 edges
6. `FirebaseAuthService` - 17 edges
7. `SwipeCardView` - 17 edges
8. `ChatViewModel` - 17 edges
9. `AppTab` - 16 edges
10. `ChatMessage` - 16 edges

## Surprising Connections (you probably didn't know these)
- `.currentIndex` --references--> `Song`  [INFERRED]
  NlpMusicRecomSystem/ViewModels/DiscoveryViewModel.swift → NlpMusicRecomSystem/Models/Song.swift
- `.visibleCards` --references--> `Song`  [INFERRED]
  NlpMusicRecomSystem/ViewModels/DiscoveryViewModel.swift → NlpMusicRecomSystem/Models/Song.swift
- `.body` --calls--> `AnimatedSparkle`  [INFERRED]
  NlpMusicRecomSystem/Views/Discovery/MoodInputView.swift → NlpMusicRecomSystem/DesignSystem/Components/AnimatedSparkle.swift
- `.body` --calls--> `GradientBackground`  [INFERRED]
  NlpMusicRecomSystem/Views/Discovery/DiscoveryLandingView.swift → NlpMusicRecomSystem/DesignSystem/Components/GradientBackground.swift
- `.filteredFavorites` --references--> `Song`  [INFERRED]
  NlpMusicRecomSystem/ViewModels/FavoritesViewModel.swift → NlpMusicRecomSystem/Models/Song.swift

## Import Cycles
- None detected.

## Communities (29 total, 4 thin omitted)

### Community 0 - "Song"
Cohesion: 0.05
Nodes (19): Song, .artworkURL, .durationString, APIRecommendationService, MockFavoritesService, MockRecommendationService, AppleMusicServiceProtocol, FavoritesServiceProtocol (+11 more)

### Community 1 - "APIError"
Cohesion: 0.07
Nodes (15): APIClient, APIClientProtocol, APIError, authenticationRequired, decodingFailed, .errorDescription, httpError, invalidResponse (+7 more)

### Community 2 - "AudioPlayerViewModel"
Cohesion: 0.09
Nodes (12): AudioPlayerViewModel, .progressFraction, DiscoveryViewModel, .currentIndex, .currentSong, .visibleCards, CardStackView, .body (+4 more)

### Community 3 - "AuthViewModel"
Cohesion: 0.08
Nodes (19): AuthViewModel, Mode, signIn, signUp, AuthTextField, .body, ErrorBanner, .body (+11 more)

### Community 4 - "SwiftUI"
Cohesion: 0.09
Nodes (11): AuthenticationServices, AVFoundation, Combine, FirebaseAuth, FirebaseCore, Foundation, MusicKit, GlassmorphicCard (+3 more)

### Community 5 - "DIContainer"
Cohesion: 0.09
Nodes (9): DIContainer, NlpMusicRecomSystemApp, .body, MockChatService, MockFeedbackService, ChatServiceProtocol, FeedbackServiceProtocol, RecommendationServiceProtocol (+1 more)

### Community 6 - "DiscoveryState"
Cohesion: 0.08
Nodes (13): MoodVector, .dominantMood, .normalized, UserInteraction, MockNLPService, NLPServiceProtocol, DiscoveryState, empty (+5 more)

### Community 7 - "AppTab"
Cohesion: 0.08
Nodes (15): AppTab, chat, discovery, home, .iconName, .id, .title, yourMusic (+7 more)

### Community 8 - "LandingHomeView"
Cohesion: 0.09
Nodes (12): .moodPresetChips, ActionButtonsView, .body, MoodChipView, .body, ScaleButtonStyle, LandingHomeView, .body (+4 more)

### Community 9 - "ChatViewModel"
Cohesion: 0.14
Nodes (5): ChatMessage, ChatViewModel, HomeView, .moodInputCard, .moodPresetChips

### Community 10 - "FirebaseAuthService"
Cohesion: 0.11
Nodes (5): FirebaseAuthService, .currentUser, .currentUserPublisher, AuthServiceProtocol, AuthUser

### Community 11 - "Decodable"
Cohesion: 0.14
Nodes (6): FavoriteSongDTO, FavoritesResponseDTO, HealthResponseDTO, .isHealthy, RecommendResponseDTO, SongDTO

### Community 12 - "LikedSongItemDTO"
Cohesion: 0.16
Nodes (4): RecommendRequestDTO, BatchSwipeRequestDTO, BatchSwipeResponseDTO, LikedSongItemDTO

### Community 13 - "DiscoveryContainerView"
Cohesion: 0.15
Nodes (7): LoadingView, DiscoveryContainerView, .body, .emptyStateView, .topBar, MoodInputView, .body

### Community 14 - "SwipeCardView"
Cohesion: 0.16
Nodes (6): SwipeCardView, .body, .dragGesture, .dragProgress, .isSwipingRight, .swipeOverlay

### Community 15 - "AlbumArtPlaceholder"
Cohesion: 0.15
Nodes (6): AlbumArtPlaceholder, .body, .computedCornerRadius, .gradient, Color, .cardContent

### Community 16 - "ChatInputBarView"
Cohesion: 0.14
Nodes (8): ChatInputBarView, .body, .inputBarBackground, MoodChatView, .body, .chatBackground, MiniPlayerView, .body

### Community 17 - "NlpMusicRecomSystemUITests"
Cohesion: 0.15
Nodes (4): NlpMusicRecomSystemUITests, NlpMusicRecomSystemUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, XCTest

### Community 20 - "View"
Cohesion: 0.24
Nodes (4): DiscoverySwipeView, .audioProgressBar, HeroBannerView, .body

### Community 21 - "Theme"
Cohesion: 0.22
Nodes (7): AnimatedSparkle, .body, GradientBackground, .body, Theme, .body, .body

### Community 22 - "DiscoveryLandingView"
Cohesion: 0.24
Nodes (4): DiscoveryLandingView, .body, .featuredCardStack, .mainFeaturedCard

### Community 23 - "APIEnvironment"
Cohesion: 0.22
Nodes (7): APIEnvironment, .baseURL, .chatURL, .favoritesURL, .healthURL, .recommendURL, .swipeURL

### Community 24 - "ChatBubbleView"
Cohesion: 0.29
Nodes (6): ChatBubbleView, .bubbleBackground, .bubbleOverlay, .typingIndicator, TypingDot, .body

### Community 25 - "ChatSongCardView"
Cohesion: 0.29
Nodes (6): .body, ChatSongCardView, .body, .isCurrentSong, NowPlayingBars, .body

### Community 26 - "NlpMusicRecomSystemTests.swift"
Cohesion: 0.40
Nodes (3): NlpMusicRecomSystem, NlpMusicRecomSystemTests, Testing

## Knowledge Gaps
- **62 isolated node(s):** `.artworkURL`, `.durationString`, `.emptyState`, `.header`, `.searchBar` (+57 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 192 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Song` connect `Song` to `APIError`, `AudioPlayerViewModel`, `DiscoveryState`, `LandingHomeView`, `ChatViewModel`, `Decodable`, `SwipeCardView`, `View`, `ChatSongCardView`, `SongRowView`?**
  _High betweenness centrality (0.219) - this node is a cross-community bridge._
- **Are the 5 inferred relationships involving `Song` (e.g. with `.currentIndex` and `.removeTopCard()`) actually correct?**
  _`Song` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.artworkURL`, `.durationString`, `.emptyState` to the rest of the system?**
  _62 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Song` be split into smaller, more focused modules?**
  _Cohesion score 0.052600818234950324 - nodes in this community are weakly interconnected._
- **Why does `Foundation` connect `SwiftUI` to `Song`, `APIError`, `DIContainer`, `DiscoveryState`, `AppTab`, `ChatViewModel`, `FirebaseAuthService`, `Decodable`, `LikedSongItemDTO`, `.sendMessage`, `APIEnvironment`?**
  _High betweenness centrality (0.188) - this node is a cross-community bridge._
- **Should `APIError` be split into smaller, more focused modules?**
  _Cohesion score 0.07215541165587419 - nodes in this community are weakly interconnected._
- **Why does `SwiftUI` connect `SwiftUI` to `Song`, `AuthViewModel`, `AppTab`, `LandingHomeView`, `ChatViewModel`, `DiscoveryContainerView`, `SwipeCardView`, `AlbumArtPlaceholder`, `ChatInputBarView`, `FlowLayout`, `View`, `Theme`, `DiscoveryLandingView`, `ChatBubbleView`, `ChatSongCardView`, `SongRowView`?**
  _High betweenness centrality (0.116) - this node is a cross-community bridge._