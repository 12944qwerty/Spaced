//
//  SearchBar.swift
//  Spaced
//
//  Created by Krish Shah on 7/16/25.
//

import SwiftUI

struct SearchBar: View {
    @StateObject var manager = TabManager.shared
    
    @ObservedObject var tab: TabState
    
    @State var searchFocusedState = false
    @State var urlEdit = ""
    @FocusState var searchFocused: Bool
    
    @Namespace var namespace
    
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
                    
                    Spacer()
                    
                    if let url = tab.webView.url {
                        let title = tab.webView.title
                        ShareLink("", item: url, subject: title != nil ? Text(title!) : nil)
                            .frame(width: 30)
                    } else {
                        Color.clear.frame(width: 30)
                    }
                }
                    .frame(height: 25)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .background(.tertiary)
                    .clipShape(.capsule)
                    .onTapGesture {
                        urlEdit = tab.url.absoluteString
                        
                        withAnimation(.easeOut(duration: 0.2)) {
                            searchFocusedState = true
                        }
                        searchFocused = true
                        DispatchQueue.main.async {
                            UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                        }
                    }
                    .matchedGeometryEffect(id: "searchbar-text", in: namespace)
            }
        }
        .padding(.top, UIApplication.shared.safeAreaTopInset)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .background(Color(UIColor.tertiarySystemFill))
        .overlay(Divider(), alignment: .bottom)
    }
}

#Preview {
    VStack {
        SearchBar(
            tab: TabState.fake,
            searchFocusedState: false
        )
        Spacer()
    }
    .ignoresSafeArea()
}
