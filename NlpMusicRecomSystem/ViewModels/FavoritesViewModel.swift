//
//  FavoritesViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import SwiftUI
import Combine
import MusicKit

@MainActor
final class FavoritesViewModel: ObservableObject {

    // MARK: - Published State

    @Published var favorites: [Song] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var filteredFavorites: [Song] {
        if searchText.isEmpty {
            return favorites
        }
        return favorites.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
            || $0.artistName.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Dependencies

    private let favoritesService: any FavoritesServiceProtocol
    private let appleMusicService: AppleMusicServiceProtocol

    // MARK: - Init

    init(
        favoritesService: any FavoritesServiceProtocol,
        appleMusicService: AppleMusicServiceProtocol
    ) {
        self.favoritesService = favoritesService
        self.appleMusicService = appleMusicService
    }

    // MARK: - Cache State

    /// `true` when `favorites` may be out of sync with the server (never loaded,
    /// last load failed, or a like was submitted since the last load).
    /// This single flag is what keeps GET /api/favorites calls to a minimum:
    /// both the Library and Profile tabs share this ViewModel instance.
    private var needsReload: Bool = true

    // MARK: - User Intents

    /// Called when the server-side favorites list has changed (e.g. a swipe session
    /// containing liked songs was submitted). The next screen that needs favorites
    /// will refetch; until then no network request is made.
    func markStale() {
        needsReload = true
    }

    /// Loads favorites only if the cache is missing or stale.
    /// Safe to call from every `.task` / `onAppear` — it is a no-op when nothing changed.
    func loadFavoritesIfNeeded() async {
        guard needsReload else { return }
        await loadFavorites()
    }

    /// Unconditionally refetches favorites from the server.
    func loadFavorites() async {
        guard !isLoading else { return }
        isLoading = true
        // Reset before the request so a markStale() arriving mid-flight is not lost.
        needsReload = false
        do {
            let rawFavorites = try await favoritesService.fetchFavorites()

            // Reuse songs that were already enriched, so only new songs hit Apple Music.
            let cachedById = Dictionary(favorites.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            let merged = rawFavorites.map { raw -> Song in
                if let cached = cachedById[raw.id], cached.appleMusicId != nil { return cached }
                return raw
            }
            // Show songs immediately (without preview URLs) while enrichment loads
            favorites = merged

            let songsToEnrich = merged.filter { $0.appleMusicId == nil }
            if !songsToEnrich.isEmpty {
                // Enrich with Apple Music metadata (artwork, preview URLs, duration)
                let enriched = await enrichWithAppleMusicData(songs: songsToEnrich)
                let enrichedById = Dictionary(enriched.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
                favorites = favorites.map { enrichedById[$0.id] ?? $0 }
            }
        } catch {
            print("[FavoritesVM] Error loading favorites: \(error)")
            // Let the next appearance retry.
            needsReload = true
        }
        isLoading = false
    }

    /// Plays a song via the audio player. If the song lacks a preview URL,
    /// enriches it from Apple Music first, then plays.
    func playSong(_ song: Song, audioPlayer: AudioPlayerViewModel) async {
        if song.previewURL != nil {
            audioPlayer.play(song: song)
            return
        }

        // Try to fetch preview URL on-demand for this specific song
        if let enrichedSong = await enrichSingleSong(song) {
            // Update the song in our favorites list
            if let index = favorites.firstIndex(where: { $0.id == song.id }) {
                favorites[index] = enrichedSong
            }
            audioPlayer.play(song: enrichedSong)
        } else {
            // Fallback: play with simulation
            audioPlayer.play(song: song)
        }
    }

    // MARK: - Apple Music Enrichment

    private func enrichWithAppleMusicData(songs: [Song]) async -> [Song] {
        var enrichedSongs = songs

        print("\n🎵 [Favorites] Apple Music API'den metadata çekiliyor...")

        await withTaskGroup(of: (Int, MusicKit.Song?).self) { group in
            for index in 0..<songs.count {
                let song = songs[index]
                group.addTask {
                    let amSong = try? await self.appleMusicService.searchSong(
                        title: song.title,
                        artist: song.artistName
                    )
                    return (index, amSong)
                }
            }

            for await (index, amSong) in group {
                if let amSong = amSong {
                    enrichedSongs[index].appleMusicId = amSong.id.rawValue
                    enrichedSongs[index].title = amSong.title
                    enrichedSongs[index].artistName = amSong.artistName
                    if let duration = amSong.duration {
                        enrichedSongs[index].durationInMillis = Int(duration * 1000)
                    }
                    if let artworkUrl = amSong.artwork?.url(width: 600, height: 600) {
                        enrichedSongs[index].imageUrl = artworkUrl.absoluteString
                    }
                    if let previewUrl = amSong.previewAssets?.first?.url {
                        enrichedSongs[index].previewURL = previewUrl
                    }
                }
            }
        }

        let previewCount = enrichedSongs.filter { $0.previewURL != nil }.count
        print("🟢 [Favorites] Apple Music enrichment complete.")
        print("   - 🎧 Preview URL bulunan: \(previewCount)/\(enrichedSongs.count)")
        return enrichedSongs
    }

    private func enrichSingleSong(_ song: Song) async -> Song? {
        guard let amSong = try? await appleMusicService.searchSong(
            title: song.title,
            artist: song.artistName
        ) else { return nil }

        var enriched = song
        enriched.appleMusicId = amSong.id.rawValue
        enriched.title = amSong.title
        enriched.artistName = amSong.artistName
        if let duration = amSong.duration {
            enriched.durationInMillis = Int(duration * 1000)
        }
        if let artworkUrl = amSong.artwork?.url(width: 600, height: 600) {
            enriched.imageUrl = artworkUrl.absoluteString
        }
        if let previewUrl = amSong.previewAssets?.first?.url {
            enriched.previewURL = previewUrl
        }
        return enriched
    }
}
