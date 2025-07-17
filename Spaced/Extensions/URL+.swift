//
//  URL+.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import Foundation

extension URL {
    func normalized() -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)

        // Remove fragment
        components?.fragment = nil

        // Sort query parameters (if any)
        if let queryItems = components?.queryItems {
            components?.queryItems = queryItems.sorted { $0.name < $1.name }
        }

        // Handle trailing slash (optional: preserve if it's root only)
        if var path = components?.path, path != "/", path.hasSuffix("/") {
            path = String(path.dropLast())
            components?.path = path
        }

        return components?.url ?? self
    }
}
