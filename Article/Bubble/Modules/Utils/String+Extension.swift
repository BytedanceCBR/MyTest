//
//  String+Extension.swift
//  Article
//
//  Created by 张元科 on 2018/11/28.
//

import Foundation

extension String {
    
    var urlParameters: [String: String]? {
        
        var urlComponents:NSURLComponents? = nil
        
        if let tempComponents1 = NSURLComponents(string: self) {
            urlComponents = tempComponents1
        } else {
            if let tempComponents2 = NSURLComponents(string: self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                urlComponents = tempComponents2
            }
        }
        
        if urlComponents == nil {
            return nil
        }
        
        guard let queryItems = urlComponents!.queryItems else {
            return nil
        }
        
        var parameters:[String: String] = [:]
        
        queryItems.forEach({ (item) in
            if item.value != nil {
                parameters[item.name] = item.value
            }
        })
        
        return parameters
    }
    
    func urlParameterForKey(_ key:String) -> String? {
        guard let parms = self.urlParameters else {
            return nil
        }
        return parms[key]
    }
}
