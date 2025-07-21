//
//  Detail.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

struct Detail: View {
    @EnvironmentObject private var coordinator: TabCoordinator
    
    @ObservedObject var tab: Tab
    
    @State var popoverBack = false
    @State var popoverForward = false
    
    var inactive = false
    
    @Namespace private var titlenamespace
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(tab: tab)
                .frame(height: 40 - tab.progress * 30)
                //                    .frame(height: 40 - tab.progress * 20)
                .simultaneousGesture(TapGesture(count: 1).onEnded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popoverBack = false
                        popoverForward = false
                    }
                })
            
            let footerHeight = UIApplication.shared.safeAreaBottomInset + 40
            GeometryReader { geo in
                Group {
                    if let thumbnail = tab.thumbnail, coordinator.isDragging || inactive {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                            .contentShape(.rect)
                            .blur(radius: 1)
                    } else {
                        WebView(webView: tab.webView)
                            .ignoresSafeArea()
                            .clipped()
                            .contentShape(.rect)
                    }
                }
                .offset(y: tab.progress * 10)
                .frame(height: geo.size.height + tab.progress * footerHeight)
            }
                //            .frame(height: UIScreen.main.bounds.size.height - combinedHeight + tab.progress * combinedHeight)
            
            BottomToolbar(tab: tab, popoverBack: $popoverBack, popoverForward: $popoverForward)
                .offset(y: tab.progress * (40 + UIApplication.shared.safeAreaBottomInset))
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
    }
}

#Preview {
    let tab = Tab.fake
    Detail(tab: tab)
        .environmentObject(TabCoordinator.init())
}
