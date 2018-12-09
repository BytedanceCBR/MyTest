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
        label.font = CommonUIStyle.Font.pingFangMedium(20)
        label.textColor = hexStringToUIColor(hex: "#081f33")
        label.text = "为你推荐"
        return label
    }()
    
    var userSelectedCache: YYCache? = {
        YYCache(name: "userdefaultselect")
    }()
    
    let houseTypeRelay = BehaviorRelay<HouseType>(value: .secondHandHouse)
    
    lazy var sectionTitleArray = [""]
    
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
        }
        
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints{ maker in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalTo(categoryLabel)
            maker.width.equalTo(110)
            maker.height.equalTo(20)
        }
        
        EnvContext.shared.client.generalBizconfig.generalCacheSubject.skip(1).throttle(0.8, latest: false, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] data in
            if let housetypelistV = data?.housetypelist,housetypelistV.count > 0
            {
                self?.sectionTitleArray.removeAll()
                let houseTypeTest = housetypelistV
                
                let resultArray = houseTypeTest.map{
                    matchHouseTypeName(houseTypeV: HouseType(rawValue: Int($0)))
                    }.filter{ $0 != ""}
                self?.sectionTitleArray = resultArray.count == 0 ? [""] : resultArray
                
                //切换城市默认触发信号
                if let defaulType = housetypelistV.first,let typeValue = HouseType(rawValue: defaulType)
                {
                    if let typeValueStr = self?.userSelectedCache?.object(forKey: "userdefaultselect") as? String
                    {
                        if let userSelectType = HouseType(rawValue: Int(typeValueStr) ?? typeValue.rawValue), housetypelistV.contains(Int(typeValueStr) ?? typeValue.rawValue)
                        {
                            self?.houseTypeRelay.accept(userSelectType)
                        }else
                        {
                            self?.houseTypeRelay.accept(typeValue)
                        }
                    }else
                    {
                        self?.houseTypeRelay.accept(typeValue)
                    }
                }
                
                self?.updateSegementLayOut()
            }
        })
            .disposed(by: disposeBag)
        
        updateSegementLayOut()
        
    }
    
    func updateSegementLayOut() {
        segmentedControl.snp.updateConstraints{ maker in
            maker.width.equalTo(sectionTitleArray.count * 55)
        }
        
        segmentedControl.sectionTitleArray = sectionTitleArray
        
        if let typeValueStr = self.userSelectedCache?.object(forKey: "userdefaultselect") as? String
        {
            if let userSelectType = HouseType(rawValue: Int(typeValueStr) ?? HouseType.secondHandHouse.rawValue)
            {
                segmentedControl.selectedSegmentIndex = sectionTitleArray.index(of: matchHouseTypeName(houseTypeV: userSelectType)) ?? 0
            }
        }else
        {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        self.userSelectedCache?.setObject(String(self.houseTypeRelay.value.rawValue) as NSCoding, forKey: "userdefaultselect")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

func matchHouseTypeName(houseTypeV: HouseType?) -> String
{
    return houseTypeV?.stringValue() ?? ""
}
