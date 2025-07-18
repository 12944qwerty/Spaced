//
//  HeroLayer.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

struct HeroLayer: View {
    @Environment(TabCoordinator.self) private var coordinator
    
    var tab: Tab
    var sAnchor: Anchor<CGRect>
    var dAnchor: Anchor<CGRect>
    
    var body: some View {
        GeometryReader { geo in
            let sRect = geo[sAnchor]
            let dRect = geo[dAnchor]
            let animateView = coordinator.animateView
            
            let viewSize: CGSize = .init(
                width: animateView ? dRect.width : sRect.width,
                height: animateView ? dRect.height : 200
            )
            let viewPosition: CGSize = .init(
                width: animateView ? dRect.minX : sRect.minX,
                height: animateView ? dRect.minY : sRect.minY
            )
            
            if !coordinator.showDetailView {
                VStack(spacing: 0) {
                    ZStack {
                        SearchBar(tab: tab)
                            .opacity(animateView ? 1 : 0)
                            .allowsHitTesting(false)
                        
                        HStack {
                            Text(tab.title ?? tab.url.host() ?? "")
                                .padding(5)
                        }
                        .frame(height: 40)
                        .background(.thickMaterial)
                        .opacity(animateView ? 0 : 1)
                    }
                    
                    if let thumbnail = tab.thumbnail, false {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .clipped()
                            .contentShape(.rect)
                    } else {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay {
                                ProgressView()
                            }
                    }
                    
                    BottomToolbar(tab: tab, popoverBack: .constant(false), popoverForward: .constant(false))
                        .opacity(animateView ? 1 : 0)
                        .allowsHitTesting(false)
                }
                .ignoresSafeArea()
                .frame(width: viewSize.width, height: viewSize.height)
                .offset(viewPosition)
            }
        }
    }
}

#Preview {
    ContentView()
}
