//
//  Detail.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

struct Detail: View {
    @Environment(TabCoordinator.self) private var coordinator
    
    var body: some View {
        
        GeometryReader {
            let size = $0.size
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(coordinator.tabs) { tab in
                        TabView(tab, size: size)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: .init(get: {
                return coordinator.detailScrollPosition
            }, set: {
                coordinator.detailScrollPosition = $0
            }))
            .onChange(of: coordinator.detailScrollPosition) { oldValue, newValue in
                coordinator.didDetailPageChanged()
            }
        }
        .opacity(coordinator.showDetailView ? 1 : 0)
        .onAppear {
            coordinator.toggleView(show: true)
        }
    }
    
    @State var popoverBack = false
    @State var popoverForward = false
    
    @ViewBuilder
    func TabView(_ tab: Tab, size: CGSize) -> some View {
        VStack(spacing: 0) {
            SearchBar(tab: tab)
                .simultaneousGesture(TapGesture(count: 1).onEnded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popoverBack = false
                        popoverForward = false
                    }
                })
            
            if let thumbnail = tab.thumbnail, !coordinator.showDetailView {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .contentShape(.rect)
            } else {
                WebView(webView: tab.webView)
//                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .contentShape(.rect)
            }
            
            BottomToolbar(tab: tab, popoverBack: $popoverBack, popoverForward: $popoverForward)
        }
        .ignoresSafeArea()
        .frame(width: size.width, height: size.height)
        .simultaneousGesture(TapGesture(count: 1).onEnded {
            withAnimation(.easeOut(duration: 0.15)) {
                popoverBack = false
                popoverForward = false
            }
        })
        .background {
            if let selectedTab = coordinator.selectedTab {
                Rectangle()
                    .fill(.clear)
                    .anchorPreference(key: HeroKey.self, value: .bounds) { anchor in
                        return [ selectedTab.id + "DEST" : anchor ]
                    }
            }
        }
//        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    ContentView()
}
