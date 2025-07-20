
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
                        .background(.regularMaterial)
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
    @Environment(TabCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var tab: Tab

    @Binding var popoverBack: Bool
    @Binding var popoverForward: Bool

    @State var moreOptions = false

    var anchor: PopoverAttachmentAnchor = .rect(.rect(CGRect(x: 0, y: 0, width: 100, height: CGFloat.infinity)))

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
                coordinator.addTab()

            }) {
                Image(systemName: "plus")
                    .padding(5)
                    .background(.tertiary)
                    .clipShape(.circle)
            }
            Spacer()

            Button(action: {
                tab.getThumbnail {
                    dismiss()
                }
            }) {
                ZStack {
                    Image(systemName: "square")
                        .resizable()
                        .frame(width: 25, height: 25)

                    Text(coordinator.tabs.count.description)
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
        .padding(.top, 8)
        .overlay(Divider(), alignment: .top)
        .frame(height: 40)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea()
        }
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
                        coordinator.addTab()
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
}

struct BottomToolbarPreview: View {
    @State var popoverBack = false
    @State var popoverForward = true

    @ObservedObject var tab = Tab.fake
    
    var coordinator: TabCoordinator = .init()

    var body: some View {
        VStack(spacing: 0) {
            Color.red
                .frame(maxHeight: .infinity)
            
            BottomToolbar(
                tab: tab,
                popoverBack: $popoverBack,
                popoverForward: $popoverForward,
            )
            .environment(coordinator)
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
                        print("selected")
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
                        print("selected")
                    }
                    .offset(x: 100, y: -43)
                }
            }
    }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) {
                popoverBack = false
                popoverForward = false
            }
        }
    }
}

#Preview {
    BottomToolbarPreview()
}
