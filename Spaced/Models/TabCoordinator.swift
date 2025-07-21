//
//  TabCoordinator.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

class TabCoordinator: ObservableObject {
    @Published var tabs: [Tab] = []
    
    @Published var path = NavigationPath()
    
    @Published var selectedTab: Tab?
    @Published var prevTab: Tab?
    
    @Published var isDragging = false
    
    @Published var detailScrollPosition: String?
    
    func close(tab: Tab) {
        withAnimation(.snappy(duration: 0.3)) {
            tabs.removeAll(where: { $0.id == tab.id })
        }
        
        if prevTab == tab {
            prevTab = tabs.last
        }
    }
    
    @discardableResult func addTab() -> Tab {
        let tab = Tab(initialURL: URL(string: "https://google.com")!)
        
        detailScrollPosition = tab.id
        
        withAnimation(.snappy(duration: 0.3)) {
            tabs.append(tab)
        }
        
        return tab
    }
    
    @discardableResult func newTab() -> Tab {
        let tab = addTab()
        
        self.path.append(tab)
        selectedTab = tab
        prevTab = tab
        
        return tab
    }
    
    func addDefaultTab() {
        if tabs.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                let tab = self.addTab()
                self.prevTab = tab
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.path.append(tab)
                }
            }
        }
    }
    
    func previousTab(_ tab: Tab) -> Tab? {
        guard let ind = tabs.firstIndex(of: tab) else { return nil }
        if ind == 0 {
            return nil
        }
        return tabs[ind - 1]
    }
    
    func followingTab(_ tab: Tab) -> Tab? {
        guard let ind = tabs.firstIndex(of: tab) else { return nil }
        if ind == tabs.count - 1 {
            return nil
        }
        return tabs[ind + 1]
    }
    
    func changeTab(_ tab: Tab) {
        self.path.removeLast()
        self.path.append(tab)
        prevTab = tab
        selectedTab = tab
    }
}

#Preview {
    ContentView()
}
