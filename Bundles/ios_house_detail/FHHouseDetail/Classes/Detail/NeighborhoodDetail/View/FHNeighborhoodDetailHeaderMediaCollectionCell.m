//
//  FHNeighborhoodDetailHeaderMediaCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailHeaderMediaCollectionCell.h"
#import "FHMultiMediaCorrectingScrollView.h"
#import "FHMultiMediaModel.h"
#import "FHDetailPictureViewController.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "FHMultiMediaVideoCell.h"
#import <FHHouseBase/FHUserTrackerDefine.h>
#import "NSString+URLEncoding.h"
#import "FHUtils.h"
#import "FHMultiMediaModel.h"
#import "FHCommonDefines.h"
#import <FHVRDetailWebViewController.h>
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"
#import "FHFloorPanPicShowViewController.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import "FHDetailFloorPanDetailInfoModel.h"
#import <TTUIWidget/TTNavigationController.h>
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHDetailNeighborhoodMediaHeaderDataHelper.h"

@interface FHNeighborhoodDetailHeaderMediaCollectionCell ()<FHMultiMediaCorrectingScrollViewDelegate, FHDetailScrollViewDidScrollProtocol, FHDetailVCViewLifeCycleProtocol>

@property (nonatomic, strong) FHMultiMediaCorrectingScrollView *mediaView;
@property (nonatomic, strong) FHDetailNeighborhoodMediaHeaderDataHelper *dataHelper;
@property (nonatomic, strong) FHMultiMediaModel *model;
@property (nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, assign)   CGFloat photoCellHeight;
@property (nonatomic, weak)     UIView *vcParentView;

@property (nonatomic, weak) FHFloorPanPicShowViewController *pictureListViewController;
@property (nonatomic, weak) FHDetailPictureViewController *pictureDetailVC;

@end

@implementation FHNeighborhoodDetailHeaderMediaCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    CGFloat photoCellHeight = 281;
    photoCellHeight = round(width / 375.0f * photoCellHeight + 0.5);
    return CGSizeMake(width, photoCellHeight);
}


- (void)dealloc {
    if (self.dataHelper.headerViewData.videoNumer > 0) {
        [self.mediaView.videoVC close];
    }
}

- (NSString *)elementType {
    if (self.dataHelper.headerViewData.videoNumer > 0) {
        return @"video";
    }
    return @"picture";
}

//- (void)refreshWithData:(id)data {
//    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodMediaHeaderModel class]]) {
//        return;
//    }
//    self.currentData = data;
//    [self.dataHelper setMediaHeaderModel:data];
//    self.model = [[FHMultiMediaModel alloc] init];
//    self.model.medias = self.dataHelper.headerViewData.mediaItemArray;
//
//    self.mediaView.isShowTopImageTab = NO;
//
//    if (self.dataHelper.headerViewData.videoNumer > 0) {
//        self.mediaView.tracerDic = [self tracerDic];
//    }
//    [self reckoncollectionHeightWithData:data];
//}

@end

@implementation FHNeighborhoodDetailHeaderMediaModel


@end
