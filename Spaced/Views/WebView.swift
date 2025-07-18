//
//  WebView.swift
//  Spaced
//
//  Created by Krish Shah on 7/14/25.
//

import SwiftUI
import WebKit

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
    ContentView()
}
