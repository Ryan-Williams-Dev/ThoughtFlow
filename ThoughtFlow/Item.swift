//
//  Item.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
