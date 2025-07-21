//
//  NavigationPath+.swift
//  Spaced
//
//  Created by Krish Shah on 7/20/25.
//

import SwiftUI

extension NavigationPath {
    mutating func removeAll() {
        self.removeLast(self.count)
    }
}

