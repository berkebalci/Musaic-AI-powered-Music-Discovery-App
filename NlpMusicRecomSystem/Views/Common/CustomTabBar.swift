//
//  CustomTabBar.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct CustomTabBar: View {

    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(tabBarBackground)
    }

    // MARK: - Sub-views

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        Circle()
                            .fill(Theme.accentCyan.opacity(0.15))
                            .frame(width: 44, height: 44)
                    }

                    Image(systemName: tab.iconName)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? Theme.tabBarActive : Theme.tabBarInactive)
                }
                .frame(height: 44)

                Text(tab.title)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? Theme.tabBarActive : Theme.tabBarInactive)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var tabBarBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .fill(Theme.tabBarBackground)
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Theme.cardBorder)
                    .frame(height: 0.5)
            }
            .ignoresSafeArea(.container, edges: .bottom)
    }
}
