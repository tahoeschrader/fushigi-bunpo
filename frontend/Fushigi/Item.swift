//
//  Item.swift
//  Fushigi
//
//  Created by Tahoe Schrader on R 6/11/20.
//

import Foundation
import SwiftData

@Model
class Item {

    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
