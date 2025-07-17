//
//  UIApplication+.swift
//  Spaced
//
//  Created by Krish Shah on 7/15/25.
//

import SwiftUI

extension UIApplication {
    var safeAreaTopInset: CGFloat {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 0
    }
    
    var safeAreaBottomInset: CGFloat {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom }
            .first ?? 0
    }
}
