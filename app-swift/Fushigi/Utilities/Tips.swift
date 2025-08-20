//
//  Tips.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/20.
//

import TipKit

struct RefreshTip: Tip {
    var title: Text {
        Text("Refresh list")
    }

    var message: Text? {
        Text("Refresh the currently displayed grammar list to a new set.")
    }

    var image: Image? {
        Image(systemName: "star")
    }
}
