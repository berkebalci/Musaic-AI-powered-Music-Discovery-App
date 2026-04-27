//
//  AudioPlayerViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import SwiftUI
import Combine

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

    private var timer: Timer?

    // MARK: - User Intents

    @MainActor
    func play(song: Song) {
        if currentSong?.id == song.id {
            togglePlayback()
            return
        }
        currentSong = song
        progress = 0
        duration = Double(song.durationInSeconds > 0 ? min(song.durationInSeconds, 30) : 30)
        isPlaying = true
        startSimulation()
    }

    @MainActor
    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startSimulation()
        } else {
            stopSimulation()
        }
    }

    @MainActor
    func pause() {
        isPlaying = false
        stopSimulation()
    }

    @MainActor
    func stop() {
        isPlaying = false
        progress = 0
        currentSong = nil
        stopSimulation()
    }

    // MARK: - Simulated Playback

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
