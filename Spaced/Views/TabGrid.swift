//
//  TabGrid.swift
//  Spaced
//
//  Created by Krish Shah on 7/18/25.
//

import SwiftUI

struct TabGrid: View {
    @EnvironmentObject private var coordinator: TabCoordinator
    
    let namespace: Namespace.ID
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2), spacing: 20) {
                ForEach(coordinator.tabs) { tab in
                    NavigationLink(value: tab) {
                        TabCardView(tab: tab)
                            .padding(5)
                            .background {
                                if coordinator.prevTab == tab {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.blue, lineWidth: 3)
                                }
                            }
                            .padding(3)
                            .contentShape(.rect)
                            //                        .onTapGesture {
                            //                            coordinator.selectedTab = tab
                            //                        }
                    }
                    .id(tab.id)
                    .transition(.scale)

                }
                .animation(.snappy(duration: 0.2), value: coordinator.tabs)
            }
            .padding(30)
        }
            //        .ignoresSafeArea()
            //        .padding(.top, UIApplication.shared.safeAreaTopInset)
    }
}

struct TabCardView: View {
    @EnvironmentObject private var coordinator: TabCoordinator
    @ObservedObject var tab: Tab
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 0) {
                HStack {
                    Text(tab.title ?? tab.url.host() ?? "")
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical)
                        .padding(.trailing, 40)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .trailing) {
                            Button(action: {
                                coordinator.close(tab: tab)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .frame(width: 20, height: 20)
                                    .padding(.vertical)
                                    .padding(.trailing, 10)
                                    .foregroundStyle(.foreground)
                            }
                            .frame(height: 40)
                        }
                }
                .frame(width: size.width, height: 40)
                .background(.thinMaterial)
                
                Rectangle()
                    .fill(.thinMaterial)
                    .overlay {
                        if let thumbnail = tab.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: 160, alignment: .top)
                                .clipped()
                        } else {
                            ProgressView()
                        }
                    }
            }
            .frame(width: size.width, height: 200)
        
        }
        .frame(height: 200)
        .contentShape(.rect)
        .shadow(radius: 5)
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    ContentView()
}
