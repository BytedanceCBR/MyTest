//
//  FHFloorPanDetailMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import "FHFloorPanDetailMediaHeaderCell.h"
#import "FHMultiMediaModel.h"
#import "FHDetailPictureViewController.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import "FHUtils.h"
#import "FHMultiMediaModel.h"
#import <FHVRDetailWebViewController.h>
#import "TTSettingsManager.h"
#import "FHFloorPanPicShowViewController.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHFloorPanDetailMediaHeaderDataHelper.h"
#import "FHFloorPanDetailMediaHeaderView.h"

@interface FHFloorPanDetailMediaHeaderCell ()
@property (nonatomic, strong) FHVideoViewController *videoVC;
@property (nonatomic, strong) FHFloorPanDetailMediaHeaderView *headerView;
@property (nonatomic, strong) FHFloorPanDetailMediaHeaderDataHelper *dataHelper;
@property (nonatomic, strong) FHMultiMediaModel *model;
@property (nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval enterTimestamp;

@property (nonatomic, weak) FHDetailPictureViewController *pictureDetailVC;

@end


@implementation FHFloorPanDetailMediaHeaderCell

- (void)dealloc {
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"picture";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHFloorPanDetailMediaHeaderModel class]]) {
        return;
    }
    self.currentData = data;
    self.model = [[FHMultiMediaModel alloc] init];
    [self.dataHelper setMediaHeaderModel:data];
    self.model.medias = self.dataHelper.headerViewData.mediaItemArray;
    [self.headerView updateMultiMediaModel:self.model];
    self.headerView.baseViewModel = self.baseViewModel;
    //后面要变成全部图片个数+VR个数+视频个数

    [self.headerView updateTitleModel:((FHFloorPanDetailMediaHeaderModel *)data).titleDataModel];
}

- (NSDictionary *)tracerDic {
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type"]];
        return dict;
    } else {
        return nil;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier :reuseIdentifier];
    if (self) {
        self.dataHelper = [[FHFloorPanDetailMediaHeaderDataHelper alloc] init];
        [self createUI];
    }
    return self;
}

- (FHVideoViewController *)videoVC {
    if (!_videoVC) {
        _videoVC = [[FHVideoViewController alloc] init];
        _videoVC.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [FHFloorPanDetailMediaHeaderView cellHeight]);
        NSMutableDictionary *dict = [self tracerDic].mutableCopy;
        dict[@"element_type"] = @"large_picture_preview";
        _videoVC.tracerDic = dict.copy;
    }
    return _videoVC;
}

#pragma mark - UI
- (void)createUI {
    self.pictureShowDict = [NSMutableDictionary dictionary];
    self.headerView = [[FHFloorPanDetailMediaHeaderView alloc] init];
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
    self.headerView.didSelectiItemAtIndex = ^(NSInteger index) {
        [weakSelf didSelectItemAtIndex:index];
    };
}


- (void)showImagesWithCurrentIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.detailPictureModel.itemList.count) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.baseViewModel.detailController.ttNeedIgnoreZoomAnimation = YES;
    FHDetailPictureViewController *pictureDetailViewController = [[FHDetailPictureViewController alloc] init];
    pictureDetailViewController.detailPictureModel = self.dataHelper.pictureDetailData.detailPictureModel;
    pictureDetailViewController.contactViewModel = self.dataHelper.pictureDetailData.contactViewModel;
    //大图图片线索
    pictureDetailViewController.imageGroupAssociateInfo = self.dataHelper.pictureDetailData.imageGroupAssociateInfo;
    //VR线索
    pictureDetailViewController.vrImageAssociateInfo = self.dataHelper.pictureDetailData.vrImageAssociateInfo;
    //视频线索
    pictureDetailViewController.videoImageAssociateInfo = self.dataHelper.pictureDetailData.videoImageAssociateInfo;
    
    pictureDetailViewController.videoVC = self.videoVC;
    pictureDetailViewController.houseType = self.baseViewModel.houseType;
    pictureDetailViewController.topVC = self.baseViewModel.detailController;

    pictureDetailViewController.dragToCloseDisabled = YES;
    pictureDetailViewController.startWithIndex = index;
    self.currentIndex = index;
    pictureDetailViewController.clickTitleTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"big_photo_album"];
    };
    
    pictureDetailViewController.clickImageBlock = ^(NSInteger currentIndex) {
        FHMultiMediaItemModel *itemModel = weakSelf.dataHelper.pictureDetailData.mediaItemArray[currentIndex];
        if (itemModel.mediaType == FHMultiMediaTypeVRPicture) {
            [weakSelf gotoVRDetail:itemModel];
        }
    };
    
    pictureDetailViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        weakSelf.currentIndex = currentIndex;
        [weakSelf trackHeaderViewMediaShowWithIndex:currentIndex isLarge:YES];
    };


    pictureDetailViewController.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
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
    pictureDetailViewController.placeholderSourceViewFrames = frames;
    pictureDetailViewController.placeholders = placeholders;

    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
        NSInteger currentIndex = weakSelf.currentIndex;
        [weakSelf.headerView scrollToItemAtIndex:currentIndex];
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
        NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
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

#pragma mark - 埋点
//埋点
- (void)trackClickTabWithIndex:(NSInteger)index element:(NSString *)element {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.mediaItemArray.count) {
        return;
    }
    FHMultiMediaItemModel *itemModel = self.dataHelper.pictureDetailData.mediaItemArray[index];
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
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

    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [dict removeObjectsForKeys:@[@"card_type", @"rank", @"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"picture_type"] = itemModel.pictureTypeName;
        dict[@"show_type"] = showType;
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
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
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
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
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
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
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
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
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
    switch (itemModel.mediaType) {
        case FHMultiMediaTypeVRPicture:
            [self gotoVRDetail:itemModel];
            break;
        case FHMultiMediaTypePicture:
            [self showImagesWithCurrentIndex:index];
            break;
        default:
            break;
    }
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    [self trackHeaderViewMediaShowWithIndex:index isLarge:NO];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}


@end

@implementation FHFloorPanDetailMediaHeaderModel

@end