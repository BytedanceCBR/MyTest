//
//  FHFilterRedDotManager.swift
//  Article
//
//  Created by leo on 2018/11/22.
//

import Foundation
class FHFilterRedDotManager {

    static let shared = FHFilterRedDotManager()

    var hasClickDot = true

    private var redDotTypes: [String] = []
    private var reddotVersion: String = ""
    private var oldDotVersion: String = ""

    init() {
        loadConfig()
    }

    private func loadConfig() {
        if let redDotTypes = UserDefaults.standard.array(forKey: "redDotTypes") as? [String] {
            self.redDotTypes = redDotTypes
        }
        reddotVersion = UserDefaults.standard.string(forKey: "version") ?? ""
        oldDotVersion = reddotVersion
    }

    private func saveConfig() {
        UserDefaults.standard.setValue(redDotTypes, forKey: "redDotTypes")
        UserDefaults.standard.setValue(reddotVersion, forKey: "version")
        UserDefaults.standard.synchronize()
    }

    func shouldShowRedDot(key: String) -> Bool {
        if redDotTypes.contains(key) && !hasClickDot {
            return true
        } else {
            return false
        }
    }

    func selectFilterItem(key: String) {
        hasClickDot = true
        oldDotVersion = self.reddotVersion
    }

    func mark() {
        oldDotVersion = reddotVersion
        hasClickDot = true
        saveConfig()
    }

    func setSelectedConditions(conditions: [String: Any]) {
        if let theTypes = conditions["reddot_type"] as? String {
            self.redDotTypes.removeAll()
            self.redDotTypes.append("\(theTypes)[]")
        }
        if let reddotVersion = conditions["reddot_version"] {
            self.reddotVersion = reddotVersion as? String ?? ""
            if oldDotVersion != self.reddotVersion {
                hasClickDot = false
            } else {
                hasClickDot = true
            }
        }
        self.saveConfig()
    }

    func shouldOpenAreaPanel() -> Bool {
        return !hasClickDot
    }

}
