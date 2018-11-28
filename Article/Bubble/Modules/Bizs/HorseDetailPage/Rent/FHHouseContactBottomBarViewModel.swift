//
//  FHHouseContactBottomBarViewModel.swift
//  NewsLite
//
//  Created by leo on 2018/11/22.
//

import Foundation
import RxSwift
import RxCocoa
class FHHouseContactBottomBarViewModel {

    let disposeBag = DisposeBag()

    weak var bottomBar: HouseDetailPageBottomBarView?

    var contactPhone = BehaviorRelay<FHHouseDetailContact?>(value: nil)

    let houseId: Int64
    let houseType: HouseType
    var searchId: String?
    var imprId: String?
    var logPb: Any?
    var showSendPhoneAlert: ((String, String, String) -> Void)?


    init(bottomBar: HouseDetailPageBottomBarView,
         houseId: Int64,
         houseType: HouseType) {
        self.bottomBar = bottomBar
        self.houseId = houseId
        self.houseType = houseType
        bindBottomBarViewBehavior()
    }

    func sendPhoneNumberRequest(houseId: Int64,
                                phone: String,
                                from: String = "detail",
                                success: @escaping () -> Void,
                                error: @escaping (Error) -> Void)
    {
        requestSendPhoneNumber(houseId: houseId, phone: phone, from: from)
            .subscribe(onNext: { (response) in
                if let status = response?.status, status == 0 {
                    let toastCount =  UserDefaults.standard.integer(forKey: kFHToastCountKey)
                    if toastCount >= 3 {
                        EnvContext.shared.toast.showToast("提交成功")
                    }
                    success()
                }
                else {
                    if let message = response?.message
                    {
                        EnvContext.shared.toast.showToast("提交失败," + message)
                    }
                }
            }, onError: { (e) in
                error(e)
                EnvContext.shared.toast.showToast("提交失败")
            })
            .disposed(by: self.disposeBag)
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

    func bindBottomBarViewBehavior() {
        bottomBar?.contactBtn.rx.tap
            .withLatestFrom(self.contactPhone)
            .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
            .bind(onNext: { [unowned self] (contactPhone) in

                if let phone = contactPhone?.phone, phone.count > 0 {

                    var theImprId: String?
                    var theSearchId: String?

                    if let logPB = self.logPb as? [String: Any],
                        let imprId = logPB["impr_id"] as? String,
                        let searchId = self.searchId {
                        theImprId = imprId
                        theSearchId = searchId

                    }
                    self.callRealtorPhone(contactPhone: contactPhone,
                                          houseId: self.houseId,
                                          houseType: self.houseType,
                                          searchId: theSearchId ?? "",
                                          imprId: theImprId ?? "",
                                          disposeBag: self.disposeBag)
                    self.followForSendPhone(showTip: false)

//                    if self.houseType != .neighborhood {
//
//                        var traceParams = self.traceParams <|> EnvContext.shared.homePageParams
//                            .exclude("house_type")
//                            .exclude("element_type")
//                            .exclude("maintab_search")
//                            .exclude("search")
//                            .exclude("filter")
//                        traceParams = traceParams <|>
//                            toTracerParams(self.enterFromByHouseType(houseType: self.houseType), key: "page_type") <|>
//                            toTracerParams(self.detailPageViewModel?.searchId ?? "be_null", key: "search_id") <|>
//                            toTracerParams("\(self.houseId)", key: "group_id")
//                        recordEvent(key: "click_call", params: traceParams)
//                    }

                }else {
                    var titleStr: String = "询底价"
                    if self.houseType == .neighborhood {
                        titleStr = "咨询经纪人"
                    }
                    self.showSendPhoneAlert?(titleStr, "随时获取房源最新动态", "提交")
                }

            })
            .disposed(by: disposeBag)
    }

    func followForSendPhone(showTip: Bool) {

    }

    //TODO func refreshSecondHouseBottomBar(contactPhone: FHHouseDetailContact?)
    func refreshRentHouseBottomBar(model: FHRentDetailResponseModel) {
        self.bottomBar?.isHidden = false
        if let contact = model.data?.contact {
            self.bottomBar?.leftView.isHidden = contact.showRealtorinfo == 1 ? false : true
            self.bottomBar?.avatarView.bd_setImage(with: URL(string: contact.avatarUrl ?? ""), placeholder: UIImage(named: "defaultAvatar"))
            let leftWidth = contact.showRealtorinfo == 1 ? 140 : 0

            if var realtorName = contact.realtorName, realtorName.count > 0 {
                if realtorName.count > 4 {
                    realtorName = realtorName + "..."
                }
                self.bottomBar?.nameLabel.text = realtorName
            } else {
                self.bottomBar?.nameLabel.text = "经纪人"
            }

            if var agencyName = contact.agencyName,
                agencyName.count > 0,
                let bottomBar = self.bottomBar {
                if agencyName.count > 4 {
                    agencyName = agencyName + "..."
                }
                bottomBar.agencyLabel.text = agencyName
                bottomBar.agencyLabel.isHidden = false

                bottomBar.nameLabel.snp.remakeConstraints({ (maker) in
                    maker.left.equalTo(bottomBar.avatarView.snp.right).offset(10)
                    maker.top.equalTo(bottomBar.avatarView).offset(2)
                    maker.right.equalToSuperview()
                })

            }else {
                if let bottomBar = self.bottomBar {
                    bottomBar.nameLabel.snp.remakeConstraints({ (maker) in
                        maker.left.equalTo(bottomBar.avatarView.snp.right).offset(10)
                        maker.centerY.equalTo(bottomBar.avatarView)
                        maker.right.equalToSuperview()
                    })
                }
                self.bottomBar?.agencyLabel.isHidden = true

            }

            self.bottomBar?.leftView.snp.updateConstraints({ (maker) in
                maker.width.equalTo(leftWidth)
            })


        }

        //如果电话不存在则默认是询底价
        var titleStr:String = "电话咨询"
        if (model.data?.contact?.phone?.isEmpty ?? true) == true {
            titleStr = "询底价"
        }

        self.bottomBar?.contactBtn.setTitle(titleStr, for: .normal)
        self.bottomBar?.contactBtn.setTitle(titleStr, for: .highlighted)
    }
}
