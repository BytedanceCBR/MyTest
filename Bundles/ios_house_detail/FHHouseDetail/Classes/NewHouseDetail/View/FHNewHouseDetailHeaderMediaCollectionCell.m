//
//  FHNewHouseDetailHeaderMediaCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/8.
//

#import "FHNewHouseDetailHeaderMediaCollectionCell.h"
#import "FHMultiMediaModel.h"
#import "FHDetailPictureViewController.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <NSString+BTDAdditions.h>
#import "FHUtils.h"
#import "FHMultiMediaModel.h"
#import "FHDetailNewModel.h"
#import <FHVRDetailWebViewController.h>
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"
#import "FHFloorPanPicShowViewController.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHDetailNewMediaHeaderDataHelper.h"
#import "FHDetailNewMediaHeaderView.h"
@interface FHNewHouseDetailHeaderMediaCollectionCell ()

@property (nonatomic, strong) FHDetailNewMediaHeaderView *headerView;
@property (nonatomic, strong) FHDetailNewMediaHeaderDataHelper *dataHelper;
@property (nonatomic, strong) FHMultiMediaModel *model;
@property (nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, weak) FHFloorPanPicShowViewController *pictureListViewController;
@property (nonatomic, weak) FHDetailPictureViewController *pictureDetailVC;

@end

@implementation FHNewHouseDetailHeaderMediaCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    CGFloat photoCellHeight = 281;
    photoCellHeight = round(width / 375.0f * photoCellHeight + 0.5);
    return CGSizeMake(width, photoCellHeight);
}

- (void)dealloc {
}

- (NSString *)elementType {
    return @"picture";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailHeaderMediaModel class]]) {
        return;
    }
    self.currentData = data;
    self.model = [[FHMultiMediaModel alloc] init];
    [self.dataHelper setMediaHeaderModel:data];
    self.model.medias = self.dataHelper.headerViewData.mediaItemArray;
    [self.headerView updateMultiMediaModel:self.model];
    [self.headerView setTotalPagesLabelText:[NSString stringWithFormat:@"共%lu张", (unsigned long)self.dataHelper.pictureDetailData.detailPictureModel.itemList.count]];
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
        self.dataHelper = [[FHDetailNewMediaHeaderDataHelper alloc] init];
        [self createUI];
    }
    return self;
}

#pragma mark - UI
- (void)createUI {
    self.pictureShowDict = [NSMutableDictionary dictionary];
    self.headerView = [[FHDetailNewMediaHeaderView alloc] init];
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
    if (index < 0 || index >= self.dataHelper.pictureDetailData.mediaItemArray.count) {
        return;
    }
    __weak typeof(self) weakSelf = self;
//    self.baseViewModel.detailController.ttNeedIgnoreZoomAnimation = YES;
    FHDetailPictureViewController *pictureDetailViewController = [[FHDetailPictureViewController alloc] init];
    pictureDetailViewController.detailPictureModel = self.dataHelper.pictureDetailData.detailPictureModel;
    pictureDetailViewController.contactViewModel = self.dataHelper.pictureDetailData.contactViewModel;
    //大图图片线索
    pictureDetailViewController.imageGroupAssociateInfo = self.dataHelper.pictureDetailData.imageGroupAssociateInfo;
    //VR线索
    pictureDetailViewController.vrImageAssociateInfo = self.dataHelper.pictureDetailData.vrImageAssociateInfo;
    //视频线索
    pictureDetailViewController.videoImageAssociateInfo = self.dataHelper.pictureDetailData.videoImageAssociateInfo;
    
    NSMutableDictionary *videoTracerDict = [self tracerDic].mutableCopy;
    videoTracerDict[@"element_type"] = @"large_picture_preview";
    pictureDetailViewController.videoTracerDict = videoTracerDict.copy;
    
    pictureDetailViewController.houseType = FHHouseTypeNewHouse;
    if (self.pictureListViewController) {
        pictureDetailViewController.topVC = self.pictureListViewController;
    } else {
        pictureDetailViewController.topVC = [TTUIResponderHelper topViewControllerFor:self];
    }
    
    pictureDetailViewController.dragToCloseDisabled = YES;
    pictureDetailViewController.startWithIndex = index;
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
    pictureDetailViewController.clickTitleTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"big_photo_album"];
    };
    pictureDetailViewController.clickImageBlock = ^(NSInteger currentIndex) {
        if (currentIndex < 0 || currentIndex >= weakSelf.dataHelper.pictureDetailData.mediaItemArray.count) {
            return;
        }
        FHMultiMediaItemModel *itemModel = weakSelf.dataHelper.pictureDetailData.mediaItemArray[currentIndex];
        if (itemModel.mediaType == FHMultiMediaTypeVRPicture) {
            [weakSelf gotoVRDetail:itemModel];
        }
    };
    pictureDetailViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        weakSelf.currentIndex = currentIndex;
        [weakSelf trackHeaderViewMediaShowWithIndex:currentIndex isLarge:YES];
    };

    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index + 1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:self.dataHelper.pictureDetailData.mediaItemArray.count];
    for (NSInteger i = 0; i < self.dataHelper.pictureDetailData.mediaItemArray.count; i++) {
        [placeholders addObject:placeholder];
        NSValue *frameValue = [NSValue valueWithCGRect:frame];
        [frames addObject:frameValue];
    }
    pictureDetailViewController.placeholders = placeholders;
    if (!self.pictureListViewController) {
        pictureDetailViewController.placeholderSourceViewFrames = frames;
    } else {
//        pictureDetailViewController.placeholderSourceViewFrames =
    }

    pictureDetailViewController.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
    };
    
    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];
    [self trackHeaderViewMediaShowWithIndex:index isLarge:YES];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
    self.pictureDetailVC = pictureDetailViewController;
}

- (void)gotoVRDetail:(FHMultiMediaItemModel *)itemModel {
    //VR
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

    if (itemModel.vrOpenUrl.length) {
        [self trackClickOptions:@"house_vr_icon"];
        NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
        NSMutableDictionary *param = [NSMutableDictionary new];
        param[@"enter_from"] = tracerDict[UT_PAGE_TYPE] ? : UT_BE_NULL;
        param[UT_ELEMENT_FROM] = tracerDict[UT_ELEMENT_FROM] ? : UT_BE_NULL;
        param[UT_ORIGIN_FROM] = tracerDict[UT_ORIGIN_FROM] ? : UT_BE_NULL;
        param[UT_ORIGIN_SEARCH_ID] = tracerDict[UT_ORIGIN_SEARCH_ID] ? : UT_BE_NULL;
        param[UT_LOG_PB] = tracerDict[UT_LOG_PB] ? : UT_BE_NULL;
        NSString *reportParams = [FHUtils getJsonStrFrom:param];
        NSString *openUrl = [NSString stringWithFormat:@"%@&report_params=%@", itemModel.vrOpenUrl, reportParams];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://house_vr_web?back_button_color=white&hide_bar=true&hide_back_button=true&hide_nav_bar=true&url=%@", [openUrl btd_stringByURLEncode]]]];
    }
}

- (void)showPictureList {
    NSMutableDictionary *routeParam = [NSMutableDictionary dictionary];
    FHFloorPanPicShowViewController *pictureListViewController = [[FHFloorPanPicShowViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(routeParam)];
    pictureListViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    pictureListViewController.isShowSegmentTitleView = YES;
    pictureListViewController.imageAlbumAssociateInfo = self.dataHelper.photoAlbumData.imageAlbumAssociateInfo;
    pictureListViewController.contactViewModel = self.dataHelper.photoAlbumData.contactViewModel;
    pictureListViewController.elementFrom = @"new_detail";

    pictureListViewController.floorPanShowModel = self.dataHelper.photoAlbumData.floorPanModel;
    
    __weak typeof(self) weakSelf = self;
    pictureListViewController.albumImageStayBlock = ^(NSInteger index, NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    pictureListViewController.albumImageBtnClickBlock = ^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //如果是从大图进入的图片列表，dismiss picturelist
        if (index < 0 || index >= strongSelf.dataHelper.pictureDetailData.mediaItemArray.count) {
            return;
        }
        FHMultiMediaItemModel *itemModel = strongSelf.dataHelper.pictureDetailData.mediaItemArray[index];
        if (itemModel.mediaType == FHMultiMediaTypeVRPicture) {
            [strongSelf gotoVRDetail:itemModel];
        } else {
            if (strongSelf.pictureDetailVC) {
                [strongSelf.pictureListViewController.navigationController popViewControllerAnimated:YES];
                if (index >= 0) {
                    [strongSelf.pictureDetailVC.photoScrollView setContentOffset:CGPointMake(weakSelf.pictureDetailVC.view.frame.size.width * index, 0) animated:NO];
                }
            } else {
                [strongSelf showImagesWithCurrentIndex:index];
            }
        }
    };
    pictureListViewController.topImageClickTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"photo_album"];
    };
    [[TTUIResponderHelper correctTopNavigationControllerFor:self] pushViewController:pictureListViewController animated:YES];
    self.pictureListViewController = pictureListViewController;
}

#pragma mark - 埋点
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
        TRACK_EVENT(@"click_tab", dict);
    } else {
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//轮播图 埋点
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
        dict[@"event_tracking_id"] = @"104162";
        if (isLarge) {
            dict[@"element_type"] = @"large_picture_preview";
        }
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
        dict[@"event_tracking_id"] = @"110853";
        

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
    TRACK_EVENT(@"picture_gallery", dict);
}

//埋点
- (void)stayPictureShowPictureWithIndex:(NSInteger)index andTime:(NSInteger)stayTime {
    NSMutableDictionary *dict = [self traceParamsForGallery:index];
    dict[@"stay_time"] = [NSNumber numberWithInteger:stayTime * 1000];
    TRACK_EVENT(@"picture_gallery_stay", dict);
}

#pragma mark - FHDetailNewMediaHeaderViewBlocks

- (void)didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.headerViewData.mediaItemArray.count) {
        return;
    }
    FHMultiMediaItemModel *itemModel = self.dataHelper.headerViewData.mediaItemArray[index];
    
    if (itemModel.mediaType == FHMultiMediaTypeVRPicture) {
        [self gotoVRDetail:itemModel];
        return;
    }
    
    NSUInteger detailIndex = 0;
    detailIndex = [self.dataHelper getPictureDetailIndexFromMediaHeaderIndex:index];
    [self showImagesWithCurrentIndex:detailIndex];
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    [self trackHeaderViewMediaShowWithIndex:index isLarge:NO];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}

//进入图片相册页
- (void)goToPictureListFrom:(NSString *)from {
    [self enterPictureShowPictureWithIndex:NSUIntegerMax from:from];
    [self showPictureList];
    if (self.pictureListViewController) {
        self.pictureListViewController.elementFrom = from;
    }
}

@end

@implementation FHNewHouseDetailHeaderMediaModel


@end
