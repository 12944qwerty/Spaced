//
//  OpenedTab.swift
//  Spaced
//
//  Created by Krish Shah on 7/14/25.
//

import SwiftUI
import WebKit
import Combine

struct OpenedTab: View {
    @ObservedObject var tab: TabState
    @StateObject var tabManager = TabManager.shared
    
    @State var current_url = ""
    
    @State var popoverBack = false
    @State var popoverForward = false
    
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(tab: tab)
                .simultaneousGesture(TapGesture().onEnded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popoverBack = false
                        popoverForward = false
                    }
                })
            
            ZStack(alignment: .bottomLeading) {
                Color(uiColor: tab.webView.underPageBackgroundColor)
                
                if tab.useThumbnail {
                    if let thumbnail = tab.thumbnail {
                        Image(uiImage: thumbnail)
                    } else {
                        ProgressView()
                    }
                } else {
                    WebView(webView: tab.webView)
                        .id(tab.id)
                }
                
                if popoverBack {
                    HistoryOverlay(
                        direction: .back,
                        items: tab.webView.backForwardList.backList,
                        back: $popoverBack,
                        forward: $popoverForward
                    ) { item in
                        tab.webView.go(to: item)
                    }
                    .offset(x: 35)
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
                    .offset(x: 105)
                }
                    
            }
            
            BottomToolbar(
                tab: tab,
                popoverBack: $popoverBack,
                popoverForward: $popoverForward
            )
        }
        .simultaneousGesture(TapGesture(count: 1).onEnded {
            withAnimation(.easeOut(duration: 0.15)) {
                popoverBack = false
                popoverForward = false
            }
        })
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.tab.useThumbnail = false
            }
        }
//        .onReceive(tabManager.selectedTab?.$url) { url in
//            self.current_url = url.absoluteString
//        }
    }
}

#Preview {
    TabGrid()
}
