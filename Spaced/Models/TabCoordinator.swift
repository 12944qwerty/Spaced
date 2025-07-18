//
//  TabCoordinator.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

@Observable
class TabCoordinator {
    var tabs: [Tab] = [Tab(initialURL: URL(string: "https://google.com")!)]
    
    var selectedTab: Tab?
    
    var animateView = false
    var showDetailView = false
    
    var detailScrollPosition: String?
    
    func didDetailPageChanged() {
        if let updatedTab = tabs.first(where: { $0.id == detailScrollPosition }) {
            selectedTab = updatedTab
        }
    }
    
    func toggleView(show: Bool) {
        if show {
            detailScrollPosition = selectedTab?.id
            withAnimation(.spring(duration: 0.4), completionCriteria: .removed) {
                animateView = true
            } completion: {
                self.showDetailView = true
            }
        } else {
            showDetailView = false
            withAnimation(.spring(duration: 0.4), completionCriteria: .removed) {
                animateView = false
            } completion: {
                self.resetAnimationProperties()
            }
        }
    }
    
    func resetAnimationProperties() {
        selectedTab = nil
        detailScrollPosition = nil
    }
    
    func close(tab: Tab) {
        
    }
    
    func addTab() {
        let tab = Tab(initialURL: URL(string: "https://google.com")!)
        
        detailScrollPosition = tab.id
        
        tabs.append(tab)
    }
}

#Preview {
    ContentView()
}
