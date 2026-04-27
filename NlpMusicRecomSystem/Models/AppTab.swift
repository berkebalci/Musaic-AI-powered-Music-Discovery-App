//
//  AppTab.swift
//  NlpMusicRecomSystem
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case discovery
    case yourMusic
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .discovery: return "Discovery"
        case .yourMusic: return "Your Music"
        case .profile: return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .discovery: return "safari.fill"
        case .yourMusic: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}
