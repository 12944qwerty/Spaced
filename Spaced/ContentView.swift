//
//  ContentView.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var coordinator: TabCoordinator = .init()
    
    @Namespace var tabTransition
    
    @State var offset: CGFloat = 0
    
    @State var scrollPosition: String? = nil
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabGrid(namespace: tabTransition)
                .environmentObject(coordinator)
                .navigationDestination(for: Tab.self) { tab in
                    TabScroller(tab)
                        .environmentObject(coordinator)
                        .navigationBarBackButtonHidden(true)
                        .navigationTransition(.zoom(sourceID: tab.id, in: tabTransition))
                        .navigationAllowDismissalGestures(.none)
                }
        }
        .preferredColorScheme(.dark)
        .onChange(of: coordinator.tabs, perform: { _ in coordinator.addDefaultTab() })
        .onAppear(perform: coordinator.addDefaultTab)
        .onChange(of: scrollPosition) { val in
            coordinator.prevTab?.getThumbnail()
            coordinator.prevTab = coordinator.tabs.first(where: { $0.id == val })
        }
    }
    
    @ViewBuilder
    private func TabScroller(_ tabSelected: Tab) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(coordinator.tabs) { tab in
                        Detail(tab: tab, inactive: scrollPosition != tab.id)
                    }
                    .frame(width: UIScreen.main.bounds.size.width)
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollPosition)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .onAppear {
                scrollPosition = tabSelected.id
                proxy.scrollTo(tabSelected.id)
            }
        }
    }
        
}

#Preview {
    ContentView()
}
