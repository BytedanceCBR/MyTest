//
//  TTTracerRecord.swift
//  Article
//
//  Created by leo on 2018/8/16.
//

import Foundation

class TTTracerRecord: TracerRecord {
    func recordEvent(key: String, params: [String : Any]) {
        TTTracker.eventV3(key, params: params)
    }
}
