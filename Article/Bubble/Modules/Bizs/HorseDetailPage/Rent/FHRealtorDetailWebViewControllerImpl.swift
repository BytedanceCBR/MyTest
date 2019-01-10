//
//  FHRealtorDetailWebViewControllerImpl.swift
//  Article
//
//  Created by leo on 2019/1/9.
//

import Foundation

class FHRealtorDetailWebViewControllerDelegateImpl: NSObject, FHRealtorDetailWebViewControllerDelegate {

    var followUp:(() -> Void)?

    func followUpAction() {
        followUp?()
    }
}
