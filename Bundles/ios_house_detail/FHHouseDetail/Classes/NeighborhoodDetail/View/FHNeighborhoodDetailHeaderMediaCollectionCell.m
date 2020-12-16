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
#import "FHVideoViewController.h"
#import "FHNeighborhoodDetailMediaHeaderView.h"

@interface FHNeighborhoodDetailHeaderMediaCollectionCell ()<FHMultiMediaCorrectingScrollViewDelegate, FHDetailScrollViewDidScrollProtocol, FHDetailVCViewLifeCycleProtocol>

@property (nonatomic, strong) FHVideoViewController *videoVC;
@property (nonatomic, strong) FHNeighborhoodDetailMediaHeaderView *headerView;
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
    CGFloat photoCellHeight = 260;
    photoCellHeight = round(width / 375.0f * photoCellHeight + 0.5);
    return CGSizeMake(width, photoCellHeight);
}


- (void)dealloc {
    
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailHeaderMediaModel class]]) {
        return;
    }
    self.currentData = data;
    [self.dataHelper setMediaHeaderModel:data];
    self.model = [[FHMultiMediaModel alloc] init];
    self.model.medias = self.dataHelper.headerViewData.mediaItemArray;
    [self.headerView updateMultiMediaModel:self.model];
    
}

- (FHVideoViewController *)videoVC {
    if (!_videoVC) {
        _videoVC = [[FHVideoViewController alloc] init];
        _videoVC.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [FHNeighborhoodDetailMediaHeaderView cellHeight]);
        NSMutableDictionary *dict = [self tracerDic].mutableCopy;
        dict[@"element_type"] = @"large_picture_preview";
        _videoVC.tracerDic = dict.copy;
    }
    return _videoVC;
}

- (NSString *)elementType {
    return @"picture";
}

- (NSDictionary *)tracerDic {
    NSMutableDictionary *dict = [self.detailTracerDict mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type"]];
        return dict.copy;
    } else {
        return nil;
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataHelper = [[FHDetailNeighborhoodMediaHeaderDataHelper alloc] init];
        [self createUI];
    }
    return self;
}

#pragma mark - UI
- (void)createUI {
    self.pictureShowDict = [NSMutableDictionary dictionary];
    self.headerView = [[FHNeighborhoodDetailMediaHeaderView alloc] init];
    [self.contentView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    __weak typeof(self) weakSelf = self;
    self.headerView.didClickItemViewName = ^(NSString *_Nonnull name) {
        [weakSelf selectItem:name];
    };
    self.headerView.willDisplayCellForItemAtIndex = ^(NSInteger index) {
        [weakSelf willDisplayCellForItemAtIndex:index];
    };
    self.headerView.goToPictureListFrom = ^(NSString *_Nonnull name) {
        [weakSelf goToPictureListFrom:name];
    };
    self.headerView.didSelectiItemAtIndex = ^(NSInteger index) {
        [weakSelf didSelectItemAtIndex:index];
    };
}

- (void)showImagesWithCurrentIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.detailPictureModel.itemList.count) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    FHDetailPictureViewController *pictureDetailViewController = [[FHDetailPictureViewController alloc] init];
    pictureDetailViewController.detailPictureModel = self.dataHelper.pictureDetailData.detailPictureModel;
    
    pictureDetailViewController.videoVC = self.videoVC;
    pictureDetailViewController.houseType = FHHouseTypeNeighborhood;
    if (self.pictureListViewController) {
        pictureDetailViewController.topVC = self.pictureListViewController;
    } else {
        pictureDetailViewController.topVC = [TTUIResponderHelper topViewControllerFor:self];
    }


    
    pictureDetailViewController.dragToCloseDisabled = YES;
    pictureDetailViewController.startWithIndex = index;
    self.currentIndex = index;
    pictureDetailViewController.clickTitleTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"big_photo_album"];
    };
    


    pictureDetailViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        weakSelf.currentIndex = currentIndex;
        [weakSelf trackHeaderViewMediaShowWithIndex:currentIndex isLarge:YES];
    };
    
    //如果是小区，移除按钮 或者户型详情页也移除按钮
    //099 户型详情页 显示底部按钮

    pictureDetailViewController.isShowBottomBar = NO;

    
    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index + 1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:self.dataHelper.pictureDetailData.detailPictureModel.itemList.count];
    for (NSInteger i = 0; i < self.dataHelper.pictureDetailData.detailPictureModel.itemList.count; i++) {
        [placeholders addObject:placeholder];
        NSValue *frameValue = [NSValue valueWithCGRect:frame];
        [frames addObject:frameValue];
    }
    if (!self.pictureListViewController) {
        pictureDetailViewController.placeholderSourceViewFrames = frames;
        pictureDetailViewController.placeholders = placeholders;
    }
    __weak FHDetailPictureViewController *weakPictureController = pictureDetailViewController;
    pictureDetailViewController.albumImageBtnClickBlock = ^(NSInteger index) {
        [weakSelf enterPictureShowPictureWithIndex:index from:@"all_pic"];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.pictureListViewController) {
            [weakPictureController dismissSelf];
        } else {
            [strongSelf showPictureList];
        }
    };

    pictureDetailViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        weakSelf.currentIndex = currentIndex;
        [weakSelf trackHeaderViewMediaShowWithIndex:currentIndex isLarge:YES];
    };
    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
        
        NSInteger currentIndex = weakSelf.currentIndex;
        
        NSInteger mediaHeaderIndex = 0;
        mediaHeaderIndex = [weakSelf.dataHelper getMediaHeaderIndexFromPictureDetailIndex:currentIndex];
        
        [weakSelf.headerView scrollToItemAtIndex:mediaHeaderIndex];
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];
    [pictureDetailViewController setWillBeginPanBackBlock:^(NSInteger index) {
        
        NSInteger mediaHeaderIndex = 0;
        mediaHeaderIndex = [weakSelf.dataHelper getMediaHeaderIndexFromPictureDetailIndex:index];
        
        [weakSelf.headerView scrollToItemAtIndex:mediaHeaderIndex];
    }];

    pictureDetailViewController.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
    };
    [self trackHeaderViewMediaShowWithIndex:index isLarge:YES];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
    self.pictureDetailVC = pictureDetailViewController;
}

- (void)showPictureList {
    NSMutableDictionary *routeParam = [NSMutableDictionary dictionary];
    FHFloorPanPicShowViewController *pictureListViewController = [[FHFloorPanPicShowViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(routeParam)];
    pictureListViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    pictureListViewController.floorPanShowModel = self.dataHelper.photoAlbumData.floorPanModel;
    pictureListViewController.isShowSegmentTitleView = YES;
    pictureListViewController.navBarName = @"小区相册";

    __weak typeof(self) weakSelf = self;
    pictureListViewController.albumImageStayBlock = ^(NSInteger index, NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    pictureListViewController.albumImageBtnClickBlock = ^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //如果是从大图进入的图片列表，dismiss picturelist
        if (strongSelf.pictureDetailVC) {
            [strongSelf.pictureListViewController dismissViewControllerAnimated:NO completion:nil];
            if (index >= 0) {
                [strongSelf.pictureDetailVC.photoScrollView setContentOffset:CGPointMake(weakSelf.pictureDetailVC.view.frame.size.width * index, 0) animated:NO];
            }
        } else {
            [strongSelf showImagesWithCurrentIndex:index];
        }
    };
    pictureListViewController.topImageClickTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"photo_album"];
    };

    UIViewController *presentedVC;
    if (self.pictureDetailVC) {
        presentedVC = self.pictureDetailVC;
    }
    if (!presentedVC) {
        presentedVC = [TTUIResponderHelper visibleTopViewController];
    }
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:pictureListViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [presentedVC presentViewController:navigationController animated:YES completion:nil];
    self.pictureListViewController = pictureListViewController;
}

//埋点
- (void)trackClickTabWithIndex:(NSInteger)index element:(NSString *)element {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.mediaItemArray.count) {
        return;
    }
    FHMultiMediaItemModel *itemModel = self.dataHelper.pictureDetailData.mediaItemArray[index];
    NSMutableDictionary *dict = [[self tracerDic] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"tab_name"] = itemModel.pictureTypeName;
        if (element) {
            dict[@"element_type"] = element;
        }
        dict[@"event_tracking_id"] = @"107651";
        TRACK_EVENT(@"click_tab", dict);
    } else {
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackHeaderViewMediaShowWithIndex:(NSInteger)index isLarge:(BOOL)isLarge {
    NSInteger limit = isLarge ? self.dataHelper.pictureDetailData.mediaItemArray.count : self.dataHelper.headerViewData.mediaItemArray.count;
    if (index < 0 || index >= limit) {
        return;
    }
    FHMultiMediaItemModel *itemModel = isLarge ? self.dataHelper.pictureDetailData.mediaItemArray[index] : self.dataHelper.headerViewData.mediaItemArray[index];
    NSString *showType = isLarge ? @"large" : @"small";
    NSString *row = [NSString stringWithFormat:@"%@_%li", showType, (long)index];
    if (_pictureShowDict[row]) {
        return;
    }
    _pictureShowDict[row] = row;

    NSMutableDictionary *dict = [[self tracerDic] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"picture_type"] = itemModel.pictureTypeName;
        dict[@"show_type"] = showType;
        TRACK_EVENT(@"picture_show", dict);
    } else {
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackPictureLargeStayWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.mediaItemArray.count) {
        return;
    }
    FHMultiMediaItemModel *itemModel = self.dataHelper.pictureDetailData.mediaItemArray[index];
    NSMutableDictionary *dict = [[self tracerDic] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }

    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"show_type"] = @"large";

        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTimestamp;
        if (duration <= 0) {
            return;
        }

        dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f", (duration * 1000)];
        self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
        TRACK_EVENT(@"picture_large_stay", dict);
    } else {
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackSavePictureWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.mediaItemArray.count) {
        return;
    }
    FHMultiMediaItemModel *itemModel = self.dataHelper.pictureDetailData.mediaItemArray[index];
    NSMutableDictionary *dict = [[self tracerDic] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }

    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"show_type"] = @"large";

        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTimestamp;
        if (duration <= 0) {
            return;
        }

        dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f", (duration * 1000)];
        TRACK_EVENT(@"picture_save", dict);
    } else {
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackClickOptions:(NSString *)str {
    NSMutableDictionary *dict = [[self tracerDic] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }

    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from", @"origin_search_id", @"log_pb", @"origin_from"]];

        if (str.length > 0) {
            dict[@"click_position"] = str;
        }

        dict[@"rank"] = @"be_null";

        TRACK_EVENT(@"click_options", dict);
    } else {
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

- (NSMutableDictionary *)traceParamsForGallery:(NSInteger)index
{
    NSMutableDictionary *dict = [[self tracerDic] mutableCopy];
    if (self.dataHelper.pictureDetailData.mediaItemArray.count > index && index >= 0) {
        FHMultiMediaItemModel *itemModel = self.dataHelper.pictureDetailData.mediaItemArray[index];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
        }
        dict[@"picture_id"] = itemModel.imageUrl;
    }
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from"]];
    }
    dict[@"show_type"] = @"large";
    return dict;
}

//埋点
- (void)enterPictureShowPictureWithIndex:(NSInteger)index from:(NSString *)from {
    NSMutableDictionary *dict = [self traceParamsForGallery:index];
    if (from.length) {
        dict[@"element_from"] = from;
    }
    dict[@"event_tracking_id"] = @"107652";
    
    TRACK_EVENT(@"picture_gallery", dict);
}

//埋点
- (void)stayPictureShowPictureWithIndex:(NSInteger)index andTime:(NSInteger)stayTime {
    NSMutableDictionary *dict = [self traceParamsForGallery:index];
    dict[@"stay_time"] = [NSNumber numberWithInteger:stayTime * 1000];
    TRACK_EVENT(@"picture_gallery_stay", dict);
}

#pragma mark - FHMultiMediaCorrectingScrollViewDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.headerViewData.mediaItemArray.count) {
        return;
    }
    FHMultiMediaItemModel *itemModel = self.dataHelper.headerViewData.mediaItemArray[index];
    
    if (itemModel.mediaType != FHMultiMediaTypeBaiduPanorama) {
        
        NSUInteger detailIndex = 0;
        detailIndex = [self.dataHelper getPictureDetailIndexFromMediaHeaderIndex:index];
        [self showImagesWithCurrentIndex:detailIndex];
    } else {
        if (itemModel.mediaType == FHMultiMediaTypeBaiduPanorama && itemModel.imageUrl.length > 0) {
            //进入百度街景
            //shceme baidu_panorama_detail
            if (![TTReachability isNetworkConnected]) {
                [[ToastManager manager] showToast:@"网络异常"];
                return;
            }

            NSMutableDictionary *tracerDict = [[self tracerDic] mutableCopy];
            NSMutableDictionary *param = [NSMutableDictionary new];
            tracerDict[@"element_from"] = @"picture";
            [tracerDict setObject:tracerDict[@"page_type"] forKey:@"enter_from"];
            param[TRACER_KEY] = tracerDict.copy;

            NSString *gaodeLat = nil;
            NSString *gaodeLon = nil;
            // 获取图片需要的房源信息数据
            
            gaodeLat = itemModel.gaodeLat;
            gaodeLon = itemModel.gaodeLng;
            if (gaodeLat.length && gaodeLon.length) {
                param[@"gaodeLat"] = gaodeLat;
                param[@"gaodeLon"] = gaodeLon;
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
            }
        }
    }
}


- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    [self trackHeaderViewMediaShowWithIndex:index isLarge:NO];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}

//进入图片页面页
- (void)goToPictureListFrom:(NSString *)from {
    [self enterPictureShowPictureWithIndex:NSUIntegerMax from:from];
    [self showPictureList];
    if (self.pictureListViewController) {
        self.pictureListViewController.elementFrom = from;
    }
}
@end

@implementation FHNeighborhoodDetailHeaderMediaModel


@end
