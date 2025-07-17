//
//  WebView.swift
//  Spaced
//
//  Created by Krish Shah on 7/14/25.
//

import SwiftUI
import WebKit
import PublishedObject

class TabState: NSObject, ObservableObject, Identifiable {
    let id = UUID()
    
    @Published var webView: WKWebView
    
    @Published var url: URL
    @Published var title: String?
    
    @Published var thumbnail: UIImage?
    @Published var useThumbnail = false
    
    @Published var currentContentMode: WKWebpagePreferences.ContentMode?
    @Published var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
        
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

extension TabState: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.url = webView.url ?? URL(string: "WH#ETWH")!
        
        currentContentMode = navigation.effectiveContentMode
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getThumbnail()
        if _fake > 0 && _fake < TabState.fakeURLs.count {
            
            self.load(url: TabState.fakeURLs[_fake])
            _fake += 1
        }
    }
}

extension TabState {
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

extension TabState {
    static var fake: TabState {
        let fake = TabState(initialURL: TabState.fakeURLs.first!, _fake: 1)

        
        // Sequentially load URLs to simulate navigation history
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            fake.webView.load(URLRequest(url: TabState.fakeURLs.first!))
        }
        
        TabManager.shared.tabs.append(fake)
        
        return fake
    }
}

class TabManager: ObservableObject {
    static let shared = TabManager()
    
    @Published var tabs: [TabState] = []
    @Published var selectedIndex: Int = 0
    
    @PublishedObject var _selectedTab: TabState?
    var selectedTab: TabState? {
        get {
            return _selectedTab
        }
        set {
            if newValue != _selectedTab {
                print("Selecting new tab \(newValue?.url)")
                previousTab = _selectedTab
                _selectedTab = newValue
            }
        }
    }
    
    @PublishedObject var previousTab: TabState?
    
    private func setSelectedTab() {
        guard tabs.indices.contains(selectedIndex) else {
            selectedTab = nil
            return
        }
        selectedTab = tabs[selectedIndex]
    }

    func addTab(url: URL = URL(string: "https://google.com")!) {
        let newTab = TabState(initialURL: url)
        tabs.append(newTab)
        selectedIndex = tabs.count - 1
        setSelectedTab()
    }

    func close(tab: TabState) {
        if let ind = tabs.firstIndex(where: { _tab in
            _tab.id == tab.id
        }) {
            tabs.remove(at: ind)
            if let prev = previousTab, !tabs.contains(prev) {
                previousTab = tabs.last
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        addWebView(to: container)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard uiView.subviews.first !== webView else {
            return // WebView already in place, nothing to update
        }

        uiView.subviews.forEach { $0.removeFromSuperview() }
        addWebView(to: uiView)
    }

    private func addWebView(to container: UIView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}



#Preview {
    TabGrid()
}
