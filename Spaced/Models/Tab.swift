//
//  TabState.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import Foundation
import SwiftUI
import WebKit

class Tab: NSObject, ObservableObject, Identifiable {
    let id = UUID().uuidString
    
    @Published var webView: WKWebView
    
    @Published var url: URL
    @Published var title: String?
    
    @Published var thumbnail: UIImage?
    @Published var useThumbnail = false
    
    @Published var currentContentMode: WKWebpagePreferences.ContentMode?
    @Published var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    
    @Published var currentScrollOffset: CGFloat = 0
    @Published var previousScrollOffset: CGFloat = 0
    
    @Published var progress: CGFloat = 0
    
    var appeared = false
    
    var _fake: Int = 0
    static let fakeURLs: [URL] = [
        URL(string: "https://apple.com")!,
        URL(string: "https://developer.apple.com")!,
        URL(string: "https://developer.apple.com/documentation/webkit")!
    ]
    
    init(initialURL: URL, _fake: Int = 0) {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "Version/1.0 SpacedBrowser"
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.url = initialURL
        self._fake = _fake
        super.init()
        
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        load(url: self.url)
    }
    
    func load(url: URL) {
        self.url = url
        
        webView.load(URLRequest(url: url))
    }
    
    func getThumbnail(completionHandler: (() -> Void)? = nil) {
        webView.takeSnapshot(with: nil) { img, err in
            if let err = err {
                print("Snapshot err: \(err)")
            } else {
                self.thumbnail = img
                completionHandler?()
            }
        }
    }
}

extension Tab: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.url = webView.url ?? URL(string: "WH#ETWH")!
        
        currentContentMode = navigation.effectiveContentMode
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if _fake > 0 && _fake < Tab.fakeURLs.count {
            
            self.load(url: Tab.fakeURLs[_fake])
            _fake += 1
        }
    }
}

extension Tab {
    func toggleContentMode() {
        let requestMobileSite = currentContentMode == .desktop
        if let url = self.webView.url {
            let requestedContentMode: WKWebpagePreferences.ContentMode = requestMobileSite ? .mobile : .desktop
            if url.scheme != "file" {
                if let hostName = url.host {
                    self.contentModeToRequestForHost[hostName] = requestedContentMode
                }
            } else {
                self.contentModeToRequestForHost[""] = requestedContentMode
            }
            self.webView.reloadFromOrigin()
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        if let hostName = navigationAction.request.url?.host {
            if let preferredContentMode = contentModeToRequestForHost[hostName] {
                preferences.preferredContentMode = preferredContentMode
            }
        } else if navigationAction.request.url?.scheme == "file" {
            if let preferredContentMode = contentModeToRequestForHost[""] {
                preferences.preferredContentMode = preferredContentMode
            }
        }
        decisionHandler(.allow, preferences)
    }
}

extension Tab {
    static var fake: Tab {
        let fake = Tab(initialURL: Tab.fakeURLs.first!, _fake: 1)
        
            // Sequentially load URLs to simulate navigation history
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            fake.webView.load(URLRequest(url: Tab.fakeURLs.first!))
        }
        
        return fake
    }
}

extension Tab: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        
        if contentHeight - scrollViewHeight < 200 {
            return // Don't do anything if tab too small
        }
        
        let maxOffsetY = max(0, contentHeight - scrollViewHeight)
        let offsetY = scrollView.contentOffset.y
        
        // Ignore bounce (overscroll)
        guard offsetY >= 0, offsetY <= maxOffsetY else {
            return
        }
        
        let offset = max(0, abs(offsetY)) * (offsetY < 0 ? -1 : 1)
        
        previousScrollOffset = currentScrollOffset
        currentScrollOffset = offset
        
        let delta = currentScrollOffset - previousScrollOffset
        
        progress += delta / 80
        progress = max(min(progress, 1), 0)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if progress < 0.4 {
                withAnimation(.snappy) {
                    progress = 0
                }
            } else {
                withAnimation(.snappy) {
                    progress = 1
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if progress < 0.4 {
            withAnimation(.snappy) {
                progress = 0
            }
        } else {
            withAnimation(.snappy) {
                progress = 1
            }
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        withAnimation(.snappy) {
            progress = 0
        }
    }
}


#Preview {
    Detail(tab: Tab.fake)
        .environmentObject(TabCoordinator.init())
}
