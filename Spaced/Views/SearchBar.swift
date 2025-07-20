//
//  SearchBar.swift
//  Spaced
//
//  Created by Krish Shah on 7/16/25.
//

import SwiftUI

struct SearchBar: View {
    @ObservedObject var tab: Tab
    
    @State var searchFocusedState = false
    @State var urlEdit = ""
    @FocusState var searchFocused: Bool
    
    @Namespace var namespace
    
    var progress: CGFloat {
        (tab.progress / 0.4) * 0.6
    }
    
    var body: some View {
        HStack {
            if searchFocusedState {
                HStack {
                    TextField("Search or type URL", text: $urlEdit)
                        .keyboardType(.webSearch)
                        .focused($searchFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            withAnimation(.easeInOut) {
                                searchFocusedState = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                searchFocused = false
                            }
                            
                            if !urlEdit.isEmpty {
                                if !urlEdit.contains("://") {
                                    if urlEdit.contains("localhost") || urlEdit.contains("127.0.0.1") {
                                        urlEdit = "http://" + urlEdit
                                    } else {
                                        urlEdit = "https://" + urlEdit
                                    }
                                }
                                
                                
                                if urlEdit == tab.webView.url?.absoluteString {
                                    return
                                }
                                
                                if let url = URL(string: urlEdit) {
                                    tab.load(url: url)
                                }
                            }
                        }
//                        .border(.red, width: 2)
                    
                    Button(action: {
                        urlEdit = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                    .frame(height: 25)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .background(.tertiary)
                    .clipShape(.capsule)
                    .matchedGeometryEffect(id: "searchbar-text", in: namespace)
                
                Button("Cancel") {
                    withAnimation(.easeOut(duration: 0.2)) {
                        searchFocusedState = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        searchFocused = false
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                HStack {
                    Button("", systemImage: "") {
                        
                    }
                    .frame(width: 30)
                    
                    Spacer()
                    
                    Text(tab.url.host() ?? "")
                        .font(.system(size: 16 - tab.progress * 2))
                    
                    Spacer()
                    
                    if let url = tab.webView.url {
                        let title = tab.webView.title
                        ShareLink("", item: url, subject: title != nil ? Text(title!) : nil)
                            .frame(width: 30)
                            .opacity(1 - progress)
                    } else {
                        Color.clear.frame(width: 30)
                    }
                }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .background(.tertiary.opacity(1 - progress))
                    .clipShape(.capsule)
                    .onTapGesture {
                        if tab.progress > 0.5 {
                            withAnimation(.snappy) {
                                tab.progress = 0
                            }
                        } else {
                            urlEdit = tab.url.absoluteString
                            
                            withAnimation(.easeOut(duration: 0.2)) {
                                searchFocusedState = true
                            }
                            searchFocused = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                    }
                    .matchedGeometryEffect(id: "searchbar-text", in: namespace)
            }
        }
        .padding(.bottom, (1 - tab.progress) * 10)
        .padding(.horizontal)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea()
        }
        .overlay(Divider(), alignment: .bottom)
    }
}


#Preview {
    let tab = Tab.fake
    VStack {
        SearchBar(
            tab: tab,
            searchFocusedState: false,
        )
        .frame(height: 40 - tab.progress * 30)
        Spacer()
        Button("Toggle progress") {
            withAnimation(.smooth(duration: 0.4)) {
                if tab.progress < 0.5 {
                    tab.progress = 1
                } else {
                    tab.progress = 0
                }
            }
        }
    }
}
