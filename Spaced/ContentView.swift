//
//  ContentView.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    var coordinator: TabCoordinator = .init()
    
    var body: some View {
        NavigationStack {
            TabGrid()
                .environment(coordinator)
                .allowsHitTesting(coordinator.selectedTab == nil)
        }
        .overlay {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
                .opacity(coordinator.animateView ? 1 : 0)
        }
        .overlay {
            if coordinator.selectedTab != nil {
                Detail()
                    .environment(coordinator)
                    .allowsHitTesting(coordinator.showDetailView)
            }
        }
        .overlayPreferenceValue(HeroKey.self) { value in
            if let selectedTab = coordinator.selectedTab,
               let sAnchor = value[selectedTab.id + "SOURCE"],
               let dAnchor = value[selectedTab.id + "DEST"] {
                HeroLayer(
                    tab: selectedTab,
                    sAnchor: sAnchor,
                    dAnchor: dAnchor
                )
                    .environment(coordinator)
            }
        }
    }
}

#Preview {
    ContentView()
}
