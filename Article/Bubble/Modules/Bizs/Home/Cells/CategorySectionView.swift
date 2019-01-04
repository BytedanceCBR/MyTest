//
//  CategorySectionView.swift
//  Bubble
//
//  Created by linlin on 2018/6/15.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import SnapKit
import RxSwift
import RxCocoa

class CategorySectionView: UIView {
    
    let disposeBag = DisposeBag()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(UIScreen.main.bounds.size.width > 330 ? 16 : 14)
        label.textColor = hexStringToUIColor(hex: "#081f33")
        label.text = "为你推荐"
        return label
    }()
    
    var userSelectedCache: YYCache? = {
        YYCache(name: "userdefaultselect")
    }()
    
    let houseTypeRelay = BehaviorRelay<HouseType>(value: .secondHandHouse)
    
    lazy var sectionTitleArray = [""]
    
    var currentIndex: Int?
    
    lazy var segmentedControl: FWSegmentedControl = {
        let re = FWSegmentedControl.segmentedWith(
            scType: SCType.text,
            scWidthStyle: SCWidthStyle.dynamicFixedSuper,
            sectionTitleArray: nil,
            sectionImageArray: nil,
            sectionSelectedImageArray: nil,
            frame: CGRect.zero)
        re.selectionIndicatorHeight = 0
        re.sectionTitleArray = sectionTitleArray
        re.selectionIndicatorColor = .clear
        re.scSelectionIndicatorStyle = .fullWidthStripe
        re.scWidthStyle = .dynamicFixedSuper
        //        re.segmentEdgeInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(14),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#979fac")]
        
        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangMedium(14),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes
        re.selectionIndicatorColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.height.equalTo(21)
            maker.bottom.equalToSuperview()
        }
        
        self.backgroundColor = .white
        
        segmentedControl.indexChangeBlock = {[weak self] index in
            
            if EnvContext.shared.client.reachability.connection == .none
            {
                self?.updateSegementLayOut()
                if let indexValue = self?.currentIndex
                {
                    self?.changeSegementIndex(index: indexValue)
                }
                EnvContext.shared.toast.showToast("网络异常")
                return
            }
            
            if let titleArray = self?.sectionTitleArray
            {
                if titleArray[index] == HouseType.secondHandHouse.stringValue()
                {
                    self?.houseTypeRelay.accept(.secondHandHouse)
                    recordEvent(key: TraceEventName.click_switch_maintablist, params: TracerParams.momoid() <|> toTracerParams("old", key: "click_type"))
                    self?.userSelectedCache?.setObject(String(HouseType.secondHandHouse.rawValue) as NSCoding, forKey: "userdefaultselect")
                    
                }else if titleArray[index] == HouseType.newHouse.stringValue()
                {
                    self?.houseTypeRelay.accept(.newHouse)
                    recordEvent(key: TraceEventName.click_switch_maintablist, params: TracerParams.momoid() <|> 
                        toTracerParams("new", key: "click_type"))
                    self?.userSelectedCache?.setObject(String(HouseType.newHouse.rawValue) as NSCoding, forKey: "userdefaultselect")
                }
                else if titleArray[index] == HouseType.rentHouse.stringValue()
                {
                    self?.houseTypeRelay.accept(.rentHouse)
                    recordEvent(key: TraceEventName.click_switch_maintablist, params: TracerParams.momoid() <|>
                        toTracerParams("rent", key: "click_type"))
                    self?.userSelectedCache?.setObject(String(HouseType.rentHouse.rawValue) as NSCoding, forKey: "userdefaultselect")
                }
            }
            
            self?.currentIndex = index
        }
        
        
        
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints{ maker in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalTo(categoryLabel)
            maker.width.equalTo(110)
            maker.height.equalTo(20)
        }
        
        EnvContext.shared.client.generalBizconfig.generalCacheSubject.skip(1).throttle(0.6, latest: false, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] data in
            if let housetypelistV = data?.housetypelist,housetypelistV.count > 0
            {
                self?.sectionTitleArray.removeAll()
                let houseTypeTest = housetypelistV
                
                let resultArray = houseTypeTest.map{
                    matchHouseTypeName(houseTypeV: HouseType(rawValue: Int($0)))
                    }.filter{ $0 != ""}
                self?.sectionTitleArray = resultArray.count == 0 ? [""] : resultArray
                
                //切换城市默认触发信号
                if let defaulTypeValue = housetypelistV.first,let defaultType = HouseType(rawValue: defaulTypeValue)
                {
                    if let cacheTypeValueStr = self?.userSelectedCache?.object(forKey: "userdefaultselect") as? String
                    {
                        if let cacheUserSelectType = HouseType(rawValue: Int(cacheTypeValueStr) ?? defaulTypeValue), housetypelistV.contains(Int(cacheTypeValueStr) ?? defaulTypeValue)
                        {
                            self?.houseTypeRelay.accept(cacheUserSelectType)
                        }else
                        {
                            self?.houseTypeRelay.accept(defaultType)
                        }
                    }else
                    {
                        self?.houseTypeRelay.accept(defaultType)
                    }
                }
                
                self?.updateSegementLayOut()
            }
        })
            .disposed(by: disposeBag)
        
        updateSegementLayOut()
        
        
        NotificationCenter.default.rx.notification(.notifyGenConfigUpdate)
            .subscribe(onNext: { [weak self] (_) in
                if let dictValue = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value?.toJSON()
                {
                    FHHomeConfigManager.sharedInstance().acceptConfigDictionary(dictValue)
                    EnvContext.shared.client.generalBizconfig.updateConfig()
                    FHEnvContext.sharedInstance().acceptConfigDictionary(dictValue)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func changeSegementIndex(index: Int)
    {
        segmentedControl.selectedSegmentIndex = index
    }
    
    func updateSegementLayOut() {
        segmentedControl.snp.updateConstraints{ maker in
            maker.width.equalTo(sectionTitleArray.count * 55)
        }
        
        segmentedControl.sectionTitleArray = sectionTitleArray
        
        let houseListArray: [Int] = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value?.housetypelist ?? []
        
        if let typeValueStr = self.userSelectedCache?.object(forKey: "userdefaultselect") as? String, let userSelectType = HouseType(rawValue: Int(typeValueStr) ?? HouseType.secondHandHouse.rawValue), houseListArray.contains(userSelectType.rawValue)
        {
            segmentedControl.selectedSegmentIndex = sectionTitleArray.index(of: matchHouseTypeName(houseTypeV: userSelectType)) ?? 0
            self.userSelectedCache?.setObject(String(userSelectType.rawValue) as NSCoding, forKey: "userdefaultselect")
        }else
        {
            segmentedControl.selectedSegmentIndex = 0
            self.userSelectedCache?.setObject(String(houseListArray.first ?? 2) as NSCoding, forKey: "userdefaultselect")
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

func matchHouseTypeName(houseTypeV: HouseType?) -> String
{
    return houseTypeV?.stringValue() ?? ""
}
