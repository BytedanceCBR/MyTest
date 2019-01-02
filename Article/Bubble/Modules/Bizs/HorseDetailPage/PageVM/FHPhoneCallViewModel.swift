//
//  FHPhoneCallViewModel.swift
//  Article
//
//  Created by leo on 2019/1/2.
//

import Foundation
import RxSwift
import RxCocoa
class FHPhoneCallViewModel: NSObject {

    func bindCallBtn(btn: UIButton, disposeBag: DisposeBag) {
        btn.rx.tap
            .debug("bindCallBtn")
            .bind { [weak self] () in

            }
            .disposed(by: disposeBag)
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

        requestVirtualNumber(realtorId: contactPhone?.realtorId ?? "0",
                             houseId: houseId,
                             houseType: houseType,
                             searchId: searchId,
                             imprId: imprId)
            .subscribe(onNext: { (response) in
                if let contactPhone = response?.data, let virtualNumber = contactPhone.virtualNumber {
                    Utils.telecall(phoneNumber: virtualNumber)
                }else {
                    Utils.telecall(phoneNumber: phone)
                }
                }, onError: { (error) in
                    Utils.telecall(phoneNumber: phone)
            })
            .disposed(by: disposeBag)

    }
}
