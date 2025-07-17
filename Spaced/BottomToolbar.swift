//
//  BottomToolbar.swift
//  Spaced
//
//  Created by Krish Shah on 7/16/25.
//

import SwiftUI
import WebKit

enum HistoryDirection {
    case back
    case forward
}

struct HistoryOverlay: View {
    let direction: HistoryDirection
    
    let items: [WKBackForwardListItem]
    
    @Binding var back: Bool
    @Binding var forward: Bool
    
    let onSelect: (WKBackForwardListItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(items, id: \.url) { item in
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        back = false
                        forward = false
                        onSelect(item)
                    }
                } label: {
                    Text(item.title ?? item.url.absoluteString)
                        .lineLimit(2)
                        .font(.title3)
                        .padding()
                        .frame(minWidth: 50, maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 250)
//        .background(Color(uiColor: .systemBackground))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
        .transition(.scale(0.0, anchor: .bottomLeading))
        .zIndex(100)
    }
}


struct BottomToolbar: View {
    @StateObject var manager = TabManager.shared
    @ObservedObject var tab: TabState
    
    @Binding var popoverBack: Bool
    @Binding var popoverForward: Bool
    
    @State var moreOptions = false
        
    var anchor: PopoverAttachmentAnchor = .rect(.rect(CGRect(x: 0, y: 0, width: 100, height: CGFloat.infinity)))
    
    @ViewBuilder
    func FormButton(_ label: String, systemImage: String? = nil, onClick: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
            
            Spacer()
            
            if let img = systemImage {
                Image(systemName: img)
                    .frame(width: 20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            moreOptions = false
            
            onClick()
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                if popoverBack || popoverForward {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popoverBack = false
                        popoverForward = false
                    }
                } else {
                    tab.webView.goBack()
                }
            }) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
            }
            .highPriorityGesture(LongPressGesture().onEnded { _ in
                withAnimation(.easeOut(duration: 0.15)) {
                    popoverForward = false
                    popoverBack = true
                }
            })
            .disabled(tab.webView.backForwardList.backItem == nil)
            .frame(width: 20)
            Spacer()
            
            Button(action: {
                tab.webView.goForward()
                
            }) {
                Image(systemName: "arrow.right")
                    .resizable()
                    .scaledToFit()
            }
            .highPriorityGesture(LongPressGesture().onEnded { _ in
                withAnimation(.easeOut(duration: 0.15)) {
                    popoverBack = false
                    popoverForward = true
                }
            })
            .disabled(tab.webView.backForwardList.forwardItem == nil)
            .frame(width: 20)
            Spacer()
            
            Button(action: {
                manager.addTab()
                
            }) {
                Image(systemName: "plus")
                    .padding(5)
                    .background(.tertiary)
                    .clipShape(.circle)
            }
            Spacer()
            
            Button(action: {
                tab.getThumbnail {
                    tab.useThumbnail = true
                    manager.selectedTab = nil
                }
            }) {
                ZStack {
                    Image(systemName: "square")
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text(manager.tabs.count.description)
                        .font(.subheadline)
                }
            }
            Spacer()
            
            Button(action: {
                moreOptions = true
            }) {
                Image(systemName: "ellipsis")
            }
            
            Spacer()
        }
        .padding(.top, 5)
        .padding(.bottom, UIApplication.shared.safeAreaBottomInset)
        .overlay(Divider(), alignment: .top)
        .background(Color(UIColor.tertiarySystemFill))
//        .transition(.move(edge: .bottom))
        .if(popoverBack || popoverForward) {
            $0.contentShape(Rectangle())
                .highPriorityGesture(TapGesture().onEnded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        popoverBack = false
                        popoverForward = false
                    }
                })
            
        }
        .sheet(isPresented: $moreOptions) {
            Form {
                Section {
                    FormButton("Reload", systemImage: "arrow.clockwise") {
                        tab.webView.reload()
                    }
                    
                    FormButton("New Tab", systemImage: "plus.circle") {
                        manager.addTab()
                    }
                }
                
                Section {
                    if tab.currentContentMode == .desktop {
                        FormButton("Request Mobile Site", systemImage: "iphone") {
                            tab.toggleContentMode()
                        }
                        .symbolRenderingMode(.monochrome)
                    } else {
                        FormButton("Request Desktop Site", systemImage: "desktopcomputer") {
                            tab.toggleContentMode()
                        }
                    }
                    FormButton("Find in page...", systemImage: "text.page.badge.magnifyingglass") {
                        
                    }
                }
            }
            .font(.title3)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.thickMaterial)
        }
    
    }
}

struct BottomToolbarPreview: View {
    @State var popoverBack = false
    @State var popoverForward = false
    
    @ObservedObject var tab = TabState.fake
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Color.red
                    .frame(maxHeight: .infinity)
                
                if popoverBack {
                    HistoryOverlay(
                        direction: .back,
                        items: tab.webView.backForwardList.backList,
                        back: $popoverBack,
                        forward: $popoverForward
                    ) { item in
                        print("selected")
                    }
                    .padding(.leading, 25)
                }
                
                if popoverForward {
                    HistoryOverlay(
                        direction: .forward,
                        items: tab.webView.backForwardList.forwardList,
                        back: $popoverBack,
                        forward: $popoverForward
                    ) { item in
                        print("selected")
                    }
                    .padding(.leading, 25)
                }
            }
            
            BottomToolbar(
                tab: tab,
                popoverBack: $popoverBack,
                popoverForward: $popoverForward,
            )
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) {
                popoverBack = false
                popoverForward = false
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BottomToolbarPreview()
}
