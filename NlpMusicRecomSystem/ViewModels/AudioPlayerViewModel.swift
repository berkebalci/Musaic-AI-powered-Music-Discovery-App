//
//  AudioPlayerViewModel.swift
//  NlpMusicRecomSystem
//
//  Plays 30-second Apple Music preview clips using AVPlayer.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

final class AudioPlayerViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0
    @Published var duration: Double = 30.0

    var progressFraction: Double {
        guard duration > 0 else { return 0 }
        return min(progress / duration, 1.0)
    }

    // MARK: - Private

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var itemEndObserver: NSObjectProtocol?

    // MARK: - Init / Deinit

    init() {
        configureAudioSession()
    }

    deinit {
        removeObservers()
        player?.pause()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("⚠️ AudioSession configuration error: \(error)")
        }
    }

    // MARK: - User Intents

    @MainActor
    func play(song: Song) {
        // Same song – just toggle
        if currentSong?.id == song.id {
            togglePlayback()
            return
        }

        // New song
        stop()
        currentSong = song
        progress = 0
        duration = 30.0

        guard let previewURL = song.previewURL else {
            print("⚠️ No preview URL for \"\(song.title)\" – falling back to simulation")
            isPlaying = true
            startSimulation()
            return
        }

        print("▶️ Playing preview: \(previewURL.absoluteString)")

        let playerItem = AVPlayerItem(url: previewURL)
        player = AVPlayer(playerItem: playerItem)
        addObservers()
        player?.play()
        isPlaying = true
    }

    @MainActor
    func togglePlayback() {
        if isPlaying {
            player?.pause()
            stopSimulation()
        } else {
            if player != nil {
                player?.play()
            } else {
                startSimulation()
            }
        }
        isPlaying.toggle()
    }

    @MainActor
    func pause() {
        player?.pause()
        stopSimulation()
        isPlaying = false
    }

    @MainActor
    func stop() {
        print("stop metodu calisti")
        player?.pause()
        removeObservers()
        player = nil
        stopSimulation()
        isPlaying = false
        progress = 0
        currentSong = nil
    }

    // MARK: - AVPlayer Observers

    private func addObservers() {
        // Periodic time observer – update progress every 0.1s
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let currentTime = time.seconds
            if let itemDuration = self.player?.currentItem?.duration.seconds,
               itemDuration.isFinite {
                self.duration = itemDuration
            }
            self.progress = currentTime
        }

        // End-of-item observer – reset when preview finishes
        itemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.isPlaying = false
                self.progress = 0
                self.player?.seek(to: .zero)
            }
        }
    }

    private func removeObservers() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        timeObserver = nil

        if let itemEndObserver {
            NotificationCenter.default.removeObserver(itemEndObserver)
        }
        itemEndObserver = nil
    }

    // MARK: - Fallback Simulation (when no preview URL available)

    private var timer: Timer?

    private func startSimulation() {
        stopSimulation()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.progress < self.duration {
                    self.progress += 0.1
                } else {
                    self.progress = 0
                    self.isPlaying = false
                    self.stopSimulation()
                }
            }
        }
    }

    private func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
}
