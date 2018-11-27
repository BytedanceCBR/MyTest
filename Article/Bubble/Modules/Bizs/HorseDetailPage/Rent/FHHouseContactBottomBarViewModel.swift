//
//  FHHouseContactBottomBarViewModel.swift
//  NewsLite
//
//  Created by leo on 2018/11/22.
//

import Foundation
import RxSwift
class FHHouseContactBottomBarViewModel {

    let disposeBag = DisposeBag()

    weak var bottomBar: HouseDetailPageBottomBarView?

    init(bottomBar: HouseDetailPageBottomBarView) {
        self.bottomBar = bottomBar
    }


    func callRealtorPhone(contactPhone: FHHouseDetailContact?,
                          houseId: Int64,
                          houseType: HouseType,
                          searchId: String,
                          imprId: String,
                          disposeBag: DisposeBag) {

        guard let phone = contactPhone?.phone, phone.count > 0 else {
            return
        }

        EnvContext.shared.toast.showToast("电话查询中")
        requestVirtualNumber(realtorId: contactPhone?.realtorId ?? "0",
                             houseId: houseId,
                             houseType: houseType,
                             searchId: searchId,
                             imprId: imprId)
            .subscribe(onNext: { (response) in
                EnvContext.shared.toast.dismissToast()
                if let contactPhone = response?.data, let virtualNumber = contactPhone.virtualNumber {
                    Utils.telecall(phoneNumber: virtualNumber)
                }else {
                    Utils.telecall(phoneNumber: phone)
                }
            }, onError: {  (error) in
                EnvContext.shared.toast.dismissToast()
                Utils.telecall(phoneNumber: phone)
            })
            .disposed(by: disposeBag)

    }

    //TODO func refreshSecondHouseBottomBar(contactPhone: FHHouseDetailContact?)
    func refreshRentHouseBottomBar() {

    }
}
