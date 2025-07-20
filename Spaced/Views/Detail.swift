//
//  Detail.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

struct Detail: View {
    @Environment(TabCoordinator.self) private var coordinator
    
    @ObservedObject var tab: Tab
    
    @State var popoverBack = false
    @State var popoverForward = false
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(tab: tab)
                .frame(height: 40)
                .simultaneousGesture(TapGesture(count: 1).onEnded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popoverBack = false
                        popoverForward = false
                    }
                })
            
            if let thumbnail = tab.thumbnail, false {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .frame(maxHeight: .infinity)
                    .contentShape(.rect)
            } else {
                WebView(webView: tab.webView)
                    .frame(maxHeight: .infinity)
                    .clipped()
                    .contentShape(.rect)
            }
            
            BottomToolbar(tab: tab, popoverBack: $popoverBack, popoverForward: $popoverForward)
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) {
            Group {
                if popoverBack {
                    HistoryOverlay(
                        direction: .back,
                        items: tab.webView.backForwardList.backList,
                        back: $popoverBack,
                        forward: $popoverForward
                    ) { item in
                        tab.webView.go(to: item)
                    }
                    .offset(x: 30, y: -43)
                }
                
                if popoverForward {
                    HistoryOverlay(
                        direction: .forward,
                        items: tab.webView.backForwardList.forwardList,
                        back: $popoverBack,
                        forward: $popoverForward
                    ) { item in
                        tab.webView.go(to: item)
                    }
                    .offset(x: 100, y: -43)
                }
            }
        }
        .simultaneousGesture(TapGesture(count: 1).onEnded {
            withAnimation(.easeOut(duration: 0.15)) {
                popoverBack = false
                popoverForward = false
            }
        })
        .onAppear {
            coordinator.selectedTab = tab
            coordinator.prevTab = tab
        }
        .onDisappear {
            coordinator.selectedTab = nil
        }
    }
}

#Preview {
    Detail(tab: Tab.fake)
        .environment(TabCoordinator.init())
}
