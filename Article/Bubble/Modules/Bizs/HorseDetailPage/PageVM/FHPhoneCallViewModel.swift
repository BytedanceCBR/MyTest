//
//  FHPhoneCallViewModel.swift
//  Article
//
//  Created by leo on 2019/1/2.
//

import Foundation
import RxSwift
import RxCocoa

@objc
class FHPhoneCallViewModel: NSObject {

    let theDisposeBag = DisposeBag()

    var followUpAction: (() -> Void)?

    func bindCallBtn(btn: UIButton,
                     rank: String,
                     houseId: Int64,
                     houseType: HouseType,
                     traceModel: HouseRentTracer?,
                     contact: FHHouseDetailContact,
                     disposeBag: DisposeBag) {
        let theTraceModel = traceModel?.copy()
        btn.rx.tap
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] () in
                let searchId = traceModel?.searchId ?? "be_null"
                self?.callRealtorPhone(contactPhone: contact,
                                       houseId: houseId,
                                       houseType: houseType,
                                       searchId: searchId,
                                       imprId: "",
                                       disposeBag: disposeBag, tracer: { [weak self] (isVirtualNumber) in
                                        self?.traceCall(rank: rank,
                                                        contact: contact,
                                                        isVirtualNumber: isVirtualNumber,
                                                        traceModel: theTraceModel as? HouseRentTracer)
                })
            }
            .disposed(by: disposeBag)
    }

    func traceCall(rank: String,
                   contact: FHHouseDetailContact,
                   isVirtualNumber: Bool,
                   traceModel: HouseRentTracer?) {
        let params = TracerParams.momoid() <|>
            toTracerParams(traceModel?.pageType ?? "be_null", key: "page_type") <|>
            toTracerParams(traceModel?.cardType ?? "be_null", key: "card_type") <|>
            toTracerParams(traceModel?.elementFrom ?? "be_null", key: "element_from") <|>
            toTracerParams(traceModel?.rank ?? "be_null", key: "rank") <|>
            toTracerParams(traceModel?.logPb ?? "be_null", key: "log_pb") <|>
            toTracerParams(traceModel?.originSearchId ?? "be_null", key: "origin_search_id") <|>
            toTracerParams(traceModel?.originFrom ?? "be_null", key: "origin_from") <|>
            toTracerParams(contact.realtorId ?? "be_null", key: "realthor_id") <|>
            toTracerParams(rank, key: "realtor_rank") <|>
            toTracerParams("detail_related", key: "realtor_position") <|>
            toTracerParams(isVirtualNumber ? 1 : 0, key: "has_associate") <|>
            toTracerParams(traceModel?.enterFrom ?? "be_null", key: "enter_from")
        // 谢飞不打，我就不打has_auth
        recordEvent(key: "click_call", params: params)
    }

    func callRealtorPhone(contactPhone: FHHouseDetailContact?,
                          houseId: Int64,
                          houseType: HouseType,
                          searchId: String,
                          imprId: String,
                          disposeBag: DisposeBag,
                          tracer: @escaping (Bool) -> Void) {
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
                    tracer(true)
                }else {
                    Utils.telecall(phoneNumber: phone)
                    tracer(false)
                }
                self.followUpAction?()
            }, onError: { (error) in
                Utils.telecall(phoneNumber: phone)
                tracer(false)
                self.followUpAction?()
            })
            .disposed(by: disposeBag)

    }

    @objc
    func requestVirtualNumberAndCall(realtorId: String,
                                     traceModel: HouseRentTracer?,
                                     phone: String,
                                     houseId: String,
                                     searchId: String,
                                     imprId: String,
                                     onSuccessed: @escaping () -> Void) {
        var contact = FHHouseDetailContact()
        contact.realtorId = realtorId
        contact.phone = phone
        self.callRealtorPhone(contactPhone: contact,
                              houseId: Int64(houseId) ?? -1,
                              houseType: .secondHandHouse,
                              searchId: searchId,
                              imprId: imprId,
                              disposeBag: theDisposeBag) {  [weak self] (isVirtualNumber) in
                                if let traceModel = traceModel {
                                    self?.traceCall(rank: traceModel.rank,
                                                   contact: contact,
                                                   isVirtualNumber: isVirtualNumber,
                                                   traceModel: traceModel)
                                    onSuccessed()
                                }
        }
    }
}
