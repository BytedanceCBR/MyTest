//
//  FHFilterRedDotManager.swift
//  Article
//
//  Created by leo on 2018/11/22.
//

import Foundation
class FHFilterRedDotManager {

    static let shared = FHFilterRedDotManager()

    var hasClickDot = false

    init() {
        loadConfig()
    }

    private func loadConfig() {
        hasClickDot = UserDefaults.standard.bool(forKey: "hasClickDot")
    }

    private func saveConfig() {
        UserDefaults.standard.set(true, forKey: "hasClickDot")
        UserDefaults.standard.synchronize()
    }

    func shouldShowRedDot(key: String) -> Bool {
        if key == "school[]" && !hasClickDot {
            return true
        } else {
            return false
        }
    }

    func selectFilterItem(key: String) {
        if key == "school[]" {
            hasClickDot = true
            saveConfig()
        }
    }
}
