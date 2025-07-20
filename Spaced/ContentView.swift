//
//  ContentView.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    @State var coordinator: TabCoordinator = .init()
    
    @State var previousPath = NavigationPath()
    
    @Namespace var tabTransition
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabGrid(namespace: tabTransition)
                .environment(coordinator)
                .navigationDestination(for: Tab.self) { tab in
                    Detail(tab: tab)
                        .environment(coordinator)
                        .navigationBarBackButtonHidden(true)
                        .navigationTransition(.zoom(sourceID: tab.id, in: tabTransition))
                        .navigationAllowDismissalGestures(.none)
                }
        }
        .preferredColorScheme(.dark)
        .onChange(of: coordinator.tabs, perform: { _ in coordinator.addDefaultTab() })
        .onAppear(perform: coordinator.addDefaultTab)
    }
}

#Preview {
    ContentView()
}
