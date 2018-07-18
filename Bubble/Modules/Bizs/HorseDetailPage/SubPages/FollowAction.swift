//
//  FollowAction.swift
//  Bubble
//
//  Created by linlin on 2018/7/18.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
protocol FollowAction {
    var followStatus: BehaviorRelay<FollowStatus?> { get }
    var houseType: HouseType { get set }
    var houseId: String { get set }
}


extension FollowAction {

    func bindWith(houseId: String, houseType: HouseType, followId: String, obve: Observable<Void>) {

    }

}
