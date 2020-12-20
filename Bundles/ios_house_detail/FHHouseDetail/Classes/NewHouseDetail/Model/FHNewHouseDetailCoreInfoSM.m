//
//  FHNewHouseDetailCoreInfoSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailCoreInfoSM.h"
#import "FHDetailHouseNameCell.h"

@implementation FHNewHouseDetailCoreInfoSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    
    NSMutableArray *items = [NSMutableArray array];
    
    FHNewHouseDetailHeaderTitleCellModel *houseTitleModel = [[FHNewHouseDetailHeaderTitleCellModel alloc] init];
    houseTitleModel.advantage = model.data.topBanner.advantage;
    houseTitleModel.businessTag = model.data.topBanner.businessTag;
    houseTitleModel.titleStr = model.data.coreInfo.name;
    houseTitleModel.aliasName = model.data.coreInfo.aliasName;
    houseTitleModel.tags = model.data.tags;
    self.titleCellModel = houseTitleModel;
    [items addObject:self.titleCellModel];
    
    // 基础信息
    if (model.data.baseInfo) {
        FHNewHouseDetailPropertyListCellModel *houseCore = [[FHNewHouseDetailPropertyListCellModel alloc] init];
        houseCore.baseInfo = model.data.baseInfo;
//        FHDetailDisclaimerModel *disclaimerModel = [[FHDetailDisclaimerModel alloc]init];
//        disclaimerModel.disclaimer =  [[FHDisclaimerModel alloc] initWithData:[model.data.disclaimer toJSONData] error:nil];
//        disclaimerModel.contact = model.data.contact ;
//        houseCore.disclaimerModel = disclaimerModel;
        
        FHDetailHouseNameModel *houseName = [[FHDetailHouseNameModel alloc] init];
        // 添加标题
        if (model.data) {
            houseName.type = 1;
            houseName.name = model.data.coreInfo.name;
            houseName.aliasName = model.data.coreInfo.aliasName;
            houseName.type = 2;
            houseName.tags = model.data.tags;
            //        [self.items addObject:houseName];
        }
        houseCore.houseName = houseName;
        houseCore.courtId = model.data.coreInfo.id;
        self.propertyListCellModel = houseCore;
        [items addObject:self.propertyListCellModel];
    } else {
        self.propertyListCellModel = nil;
    }
    
    // 地址信息
    FHNewHouseDetailAddressInfoCellModel *addressInfo = [[FHNewHouseDetailAddressInfoCellModel alloc] init];
    addressInfo.name = model.data.coreInfo.name;
    addressInfo.courtId = model.data.coreInfo.id;
    addressInfo.gaodeLat = model.data.coreInfo.gaodeLat;
    addressInfo.gaodeLng = model.data.coreInfo.gaodeLng;
    addressInfo.courtAddress = model.data.coreInfo.courtAddress;
    addressInfo.courtAddressIcon = model.data.coreInfo.courtAddressIcon;
    self.addressInfoCellModel = addressInfo;
    [items addObject:self.addressInfoCellModel];

    // 变价通知
    FHNewHouseDetailPriceNotifyCellModel *priceInfo = [[FHNewHouseDetailPriceNotifyCellModel alloc] init];
//    priceInfo.contactModel = self.contactViewModel;
    priceInfo.priceAssociateInfo = model.data.changePriceNotifyAssociateInfo;
    priceInfo.openAssociateInfo = model.data.beginSellingNotifyAssociateInfo;
    self.priceNotifyCellModel = priceInfo;
    [items addObject:self.priceNotifyCellModel];
    self.items = items.copy;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
