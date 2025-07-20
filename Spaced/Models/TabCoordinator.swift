//
//  TabCoordinator.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

@Observable
class TabCoordinator {
    var tabs: [Tab] = []
    
    var path = NavigationPath()
    
    var selectedTab: Tab?
    var prevTab: Tab?
    
    var detailScrollPosition: String?
    
    func close(tab: Tab) {
        tabs.removeAll(where: { $0.id == tab.id })
    }
    
    func addTab() -> Tab {
        let tab = Tab(initialURL: URL(string: "https://google.com")!)
        
        detailScrollPosition = tab.id
        
        tabs.append(tab)
        
        return tab
    }
    
    func addDefaultTab() {
        if tabs.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let tab = self.addTab()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.path.append(tab)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
