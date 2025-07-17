//
//  TabGrid.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import SwiftUI

struct TabGrid: View {
    @StateObject var manager = TabManager.shared
    
    @Namespace var tabTransitionNamespace
    
    var body: some View {
        ZStack {
            if let selectedTab = manager.selectedTab {
                TabDetailView(tab: selectedTab, namespace: tabTransitionNamespace) {
                    manager.selectedTab = nil
                }
            } else {
                TabListView(manager: manager, namespace: tabTransitionNamespace)
                    .padding(.top, UIApplication.shared.safeAreaTopInset)
            }
        }
        .ignoresSafeArea()
        .animation(.spring(duration: 0.3), value: manager.selectedTab)
//        .onAppear {
//            if manager.tabs.count == 0 {
//                manager.addTab()
//            }
//        }
        .onReceive(manager.$tabs) { tabs in
            if tabs.count == 0 {
                manager.addTab()
            }
        }
    }
}

struct TabListView: View {
    @ObservedObject var manager: TabManager
    var namespace: Namespace.ID

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(manager.tabs) { tab in
                        TabCardView(tab: tab, namespace: namespace)
                            .onTapGesture {
                                manager.selectedTab = tab
                            }
                    }
                }
                .padding()
            }
            .animation(.easeOut, value: manager.tabs)
            
            Spacer()
            
            HStack {
                Button(action: {
                    manager.addTab()
                }) {
                    Image(systemName: "plus")
                        .padding(5)
                        .background(.tertiary)
                        .clipShape(.circle)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.horizontal)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .padding(.top, 0)
            .overlay(Divider(), alignment: .top)
            .background(Color(UIColor.tertiarySystemFill))
        }
    }
}

struct TabCardView: View {
    @StateObject var manager = TabManager.shared
    
    @ObservedObject var tab: TabState
    var namespace: Namespace.ID
    
    @State var width: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(spacing: 1) {
                    Text(tab.title ?? tab.url.host() ?? "")
                        //                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                    
                    Button(action: {
                        manager.close(tab: tab)
                    }) {
                        Image(systemName: "multiply")
                    }
                }
                .frame(height: 40)
                .frame(width: geo.size.width)
                    //                .padding(.horizontal, 7)
                .background(.tertiary)
                    //                .matchedGeometryEffect(id: tab.id.uuidString + "title", in: namespace)
                
                ZStack {
                    if let thumbnail = tab.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: 160, alignment: .top)
                            .clipped()
                    } else {
                        Color.black.brightness(0.8)
                        
                        ProgressView()
                    }
                }
                .frame(width: geo.size.width, height: 160)
                .transition(.scale)
                    //                .matchedGeometryEffect(id: tab.id.uuidString + "container", in: namespace)
            }
            .frame(width: geo.size.width)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)
        .padding(.all, 7)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue, lineWidth: manager.previousTab?.id == tab.id ? 5 : 0)
        )
        .shadow(radius: 1)
    }
}

struct TabDetailView: View {
    var tab: TabState
    var namespace: Namespace.ID
    var onClose: () -> Void
    
    @StateObject var manager = TabManager.shared

    var body: some View {
        OpenedTab(tab: tab, namespace: namespace)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(.systemBackground))
            )
            .ignoresSafeArea()
//            .matchedGeometryEffect(id: tab.id.uuidString + "container", in: namespace)
    }
}

#Preview {
    TabGrid()
        .onAppear {
            TabManager.shared.selectedTab = nil
        }
}
