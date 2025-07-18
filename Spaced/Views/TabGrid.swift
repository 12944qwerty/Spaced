//
//  TabGrid.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

struct TabGrid: View {
    @Environment(TabCoordinator.self) private var coordinator
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2), spacing: 30) {
                ForEach(coordinator.tabs) { tab in
                    GridTabView(tab)
                        .onTapGesture {
                            coordinator.selectedTab = tab
                        }
                }
            }
            .padding(30)
        }
//        .ignoresSafeArea()
//        .padding(.top, UIApplication.shared.safeAreaTopInset)
    }
    
    @ViewBuilder
    func GridTabView(_ tab: Tab) -> some View {
        GeometryReader {
            let size = $0.size
            
            Rectangle()
                .fill(.clear)
                .anchorPreference(key: HeroKey.self, value: .bounds) { anchor in
                    return [tab.id + "SOURCE": anchor]
                }
            
            VStack(spacing: 0) {
                HStack {
                    Text(tab.title ?? tab.url.host() ?? "")
                        .padding(5)
                }
                .frame(width: size.width, height: 40)
                .background(.thinMaterial)
                
                if let thumbnail = tab.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: 160, alignment: .top)
                        .clipped()
                        .opacity(coordinator.selectedTab?.id == tab.id ? 0 : 1)
                } else {
                    Rectangle()
                        .fill(.thinMaterial)
                        .background(.tertiary)
                        .overlay {
                            ProgressView()
                        }
                        .opacity(coordinator.selectedTab?.id == tab.id ? 0 : 1)
                }
            }
            .frame(width: size.width, height: 200)
        
        }
        .frame(height: 200)
        .contentShape(.rect)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}
