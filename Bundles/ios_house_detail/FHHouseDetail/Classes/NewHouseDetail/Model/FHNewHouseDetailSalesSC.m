//
//  FHNewHouseDetailSalesSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSalesSC.h"
#import "FHNewHouseDetailSalesSM.h"
#import "FHNewHouseDetailSalesCollectionCell.h"
#import "FHNewHouseDetailViewController.h"
#import "FHDetailSectionTitleCollectionView.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <FHWebView/SSWebViewController.h>
#import <TTAccountSDK/TTAccount.h>

@interface FHNewHouseDetailSalesSC()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailSalesSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNewHouseDetailSalesSM *model = (FHNewHouseDetailSalesSM *)self.sectionModel;
    return [FHNewHouseDetailSalesCollectionCell cellSizeWithData:model.salesCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailSalesSM *model = (FHNewHouseDetailSalesSM *)self.sectionModel;
    FHNewHouseDetailSalesCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailSalesCollectionCell class] withReuseIdentifier:NSStringFromClass([model.salesCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.salesCellModel];
    __weak typeof(self) wself = self;
    cell.clickRecive = ^(id  _Nonnull data) {
        [wself clickRecive:data];
    };
    return cell;
}

- (void)clickRecive:(id)data {
    FHDetailNewDiscountInfoItemModel *itemInfo = (FHDetailNewDiscountInfoItemModel *)data;
    [self addClickOptionLog:@(itemInfo.actionType)];
    FHNewHouseDetailSalesSM *model = (FHNewHouseDetailSalesSM *)self.sectionModel;
    if (itemInfo.actionType == 4 && itemInfo.activityURLString.length) {
        if (itemInfo.activityURLString.length && model.salesCellModel.contactViewModel) {
            NSMutableDictionary *extraDic = self.detailTracerDict.mutableCopy;
            extraDic[@"im_open_url"] = itemInfo.activityURLString;
            extraDic[@"position"] = @"coupon";
            if (itemInfo.associateInfo.imInfo) {
                extraDic[kFHAssociateInfo] = itemInfo.associateInfo;
            }
            [model.salesCellModel.contactViewModel onlineActionWithExtraDict:extraDic];
        }
        return;
    }
    
    //099 优惠跳转类型
    if (itemInfo.actionType == 3 && itemInfo.activityURLString.length) {
        NSString *urlString = itemInfo.activityURLString.copy;
        //@"https://m.xflapp.com/magic/page/ejs/5ecb69c9d7ff73025f6ea4e0?appType=manyhouse";
        if([urlString hasPrefix:@"http://"] ||
           [urlString hasPrefix:@"https://"]) {
            UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
            ssOpenWebView([NSURL URLWithString:urlString], @"", topController.navigationController, NO, nil);
            return;
        }
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:urlString]];
        return;
    }

    NSString *title = itemInfo.discountReportTitle;
    NSString *subtitle = itemInfo.discountReportSubTitle;
    NSString *toast = [NSString stringWithFormat:@"%@，%@",itemInfo.discountReportDoneTitle,itemInfo.discountReportDoneSubTitle];
    NSString *btnTitle = itemInfo.discountButtonText;
    NSMutableDictionary *extraDic = @{@"position":@"coupon"
                                      }.mutableCopy;
    extraDic[kFHCluePage] = itemInfo.page;
    extraDic[@"title"] = title;
    extraDic[@"subtitle"] = subtitle;
    extraDic[@"btn_title"] = btnTitle;
    extraDic[@"toast"] = toast;

    NSMutableDictionary *associateParamDict = @{}.mutableCopy;
    associateParamDict[kFHAssociateInfo] = itemInfo.associateInfo.reportFormInfo;
    NSMutableDictionary *reportParamsDict = [model.salesCellModel.contactViewModel baseParams].mutableCopy;
    reportParamsDict[@"position"] = @"coupon";
    if (extraDic.count > 0) {
        [associateParamDict addEntriesFromDictionary:extraDic];
        reportParamsDict[kFHAssociateInfo] = itemInfo.associateInfo.reportFormInfo;
    }
    associateParamDict[kFHReportParams] = reportParamsDict;

    [model.salesCellModel.contactViewModel fillFormActionWithParams:associateParamDict];
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"coupon";
}

-(void)addClickOptionLog:(NSNumber *)actionType
{
    //click_position: recieve（领取），subscribe（预约）
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    tracerDic[@"element_type"] = @"coupon";
    tracerDic[@"action_type"] = actionType;
    TRACK_EVENT(@"click_options", tracerDic);
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"优惠信息";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}

@end
