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

    func bindCallBtn(btn: UIButton,
                     rank: String,
                     houseId: Int64,
                     houseType: HouseType,
                     traceModel: HouseRentTracer?,
                     contact: FHHouseDetailContact,
                     disposeBag: DisposeBag) {
        btn.rx.tap
            .bind { [weak self] () in
                self?.traceCall(rank: rank,
                                contact: contact,
                                traceModel: traceModel)
                let searchId = traceModel?.searchId ?? "be_null"

                self?.callRealtorPhone(contactPhone: contact,
                                       houseId: houseId,
                                       houseType: houseType,
                                       searchId: searchId,
                                       imprId: "",
                                       disposeBag: disposeBag)
            }
            .disposed(by: disposeBag)
    }

    func traceCall(rank: String,
                   contact: FHHouseDetailContact,
                   traceModel: HouseRentTracer?) {
        let params = TracerParams.momoid() <|>
            toTracerParams(traceModel?.pageType ?? "be_null", key: "page_type") <|>
            toTracerParams(traceModel?.elementFrom ?? "be_null", key: "element_from") <|>
            toTracerParams(traceModel?.rank ?? "be_null", key: "rank") <|>
            toTracerParams(contact.realtorId ?? "be_null", key: "realthor_id") <|>
            toTracerParams(traceModel?.logPb ?? "be_null", key: "log_pb") <|>
            toTracerParams("detail_related", key: "realtor_position") <|>
            toTracerParams(traceModel?.enterFrom ?? "be_null", key: "enter_from")
        // 谢飞不打，我就不打has_auth
        recordEvent(key: "click_call", params: params)
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
