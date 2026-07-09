//
//  AppTab.swift
//  NlpMusicRecomSystem
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case chat
    case discovery
    case yourMusic
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .chat: return "Chat"
        case .discovery: return "Discovery"
        case .yourMusic: return "Library"
        case .profile: return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .discovery: return "safari.fill"
        case .yourMusic: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}
