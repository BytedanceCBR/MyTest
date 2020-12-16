//
//  FHDetailNeighborhoodMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/14.
//

#import "FHDetailNeighborhoodMediaHeaderCell.h"
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

@interface FHDetailNeighborhoodMediaHeaderCell ()<FHMultiMediaCorrectingScrollViewDelegate, FHDetailScrollViewDidScrollProtocol, FHDetailVCViewLifeCycleProtocol>

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

@implementation FHDetailNeighborhoodMediaHeaderCell
- (void)dealloc {
    if (self.dataHelper.headerViewData.videoNumer > 0) {
        [self.mediaView.videoVC close];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"picture";
}

+ (CGFloat)cellHeight {
    CGFloat photoCellHeight = 281;
    photoCellHeight = round([UIScreen mainScreen].bounds.size.width / 375.0f * photoCellHeight + 0.5);
    return photoCellHeight;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodMediaHeaderModel class]]) {
        return;
    }
    self.currentData = data;
    [self.dataHelper setMediaHeaderModel:data];
    self.model = [[FHMultiMediaModel alloc] init];
    self.model.medias = self.dataHelper.headerViewData.mediaItemArray;
    
    self.mediaView.isShowTopImageTab = NO;
    self.mediaView.baseViewModel = self.baseViewModel;
    [self.mediaView updateModel:self.model withTitleModel:((FHDetailNeighborhoodMediaHeaderModel *)self.currentData).titleDataModel];
    
    if (self.dataHelper.headerViewData.videoNumer > 0) {
        self.mediaView.tracerDic = [self tracerDic];
    }
    [self reckoncollectionHeightWithData:data];
}

- (void)reckoncollectionHeightWithData:(id)data {
    FHDetailHouseTitleModel *titleModel =  ((FHDetailNeighborhoodMediaHeaderModel *)self.currentData).titleDataModel;
    _photoCellHeight = [FHDetailNeighborhoodMediaHeaderCell cellHeight];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont themeFontMedium:24] };
    CGRect rect = [titleModel.titleStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 66, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil];          //算出标题的高度
    if (titleModel.advantage.length > 0 && titleModel.businessTag.length > 0) { //如果头图下面有横幅那么高度增加40
        _photoCellHeight += 40;
    }

    CGFloat rectHeight = rect.size.height;
    if (rectHeight > [UIFont themeFontMedium:24].lineHeight * 1) {         //如果超过两行，只显示两行，小区只显示一行，需要特判
        rectHeight = [UIFont themeFontMedium:24].lineHeight * 1;
    }

    _photoCellHeight += 20 + rectHeight - 21;//20是标题具体顶部的距离，21是重叠的41减去透明阴影的20 (21 = 41 - 20)

    if (titleModel.tags.count > 0) {
        //这里分别加上标签高度20，标签间隔20
        _photoCellHeight += 20 + 20;
    }

    _photoCellHeight = _photoCellHeight + 22;       //小区的地址Label高度

    [self.mediaView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(self.photoCellHeight);
    }];
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
        self.dataHelper = [[FHDetailNeighborhoodMediaHeaderDataHelper alloc] init];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _photoCellHeight = [FHDetailNeighborhoodMediaHeaderCell cellHeight];
    _pictureShowDict = [NSMutableDictionary dictionary];
    
    _mediaView = [[FHMultiMediaCorrectingScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _photoCellHeight)];
    _mediaView.delegate = self;
    [self.contentView addSubview:_mediaView];

    [_mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.photoCellHeight);
    }];
}

- (void)showImagesWithCurrentIndex:(NSInteger)index {
    if (index < 0 || index >= self.dataHelper.pictureDetailData.detailPictureModel.itemList.count) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.baseViewModel.detailController.ttNeedIgnoreZoomAnimation = YES;
    FHDetailPictureViewController *pictureDetailViewController = [[FHDetailPictureViewController alloc] init];
    pictureDetailViewController.detailPictureModel = self.dataHelper.pictureDetailData.detailPictureModel;
    pictureDetailViewController.houseType = self.baseViewModel.houseType;
    if (self.pictureListViewController) {
        pictureDetailViewController.topVC = self.pictureListViewController;
    } else {
        pictureDetailViewController.topVC = self.baseViewModel.detailController;
    }


    
    pictureDetailViewController.dragToCloseDisabled = YES;
    if (self.dataHelper.headerViewData.videoNumer > 0) {
        pictureDetailViewController.videoVC = self.mediaView.videoVC;
    }
    pictureDetailViewController.startWithIndex = index;
    self.currentIndex = index;
    pictureDetailViewController.clickTitleTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"big_photo_album"];
    };
    


    pictureDetailViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
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
    self.mediaView.isShowenPictureVC = YES;
    
    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
        if ([weakSelf.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
            [weakSelf resetVideoCell:frame];
        }
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
        NSInteger currentIndex = 0;
        currentIndex = [weakSelf.dataHelper getMediaHeaderIndexFromPictureDetailIndex:weakSelf.currentIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
        [weakSelf.mediaView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [weakSelf.mediaView updateItemAndInfoLabel];
        [weakSelf.mediaView updateVideoState];
        weakSelf.mediaView.isShowenPictureVC = NO;
    }];
    [pictureDetailViewController setWillBeginPanBackBlock:^(NSInteger index) {
        
        NSInteger mediaHeaderIndex = 0;
        mediaHeaderIndex = [weakSelf.dataHelper getMediaHeaderIndexFromPictureDetailIndex:index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:mediaHeaderIndex + 1 inSection:0];
        [weakSelf.mediaView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
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

// 重置视频view，注意状态以及是否是首屏幕图片
- (void)resetVideoCell:(CGRect)frame {
    CGRect bound = CGRectMake(0, 0, frame.size.width, frame.size.height);
    __weak typeof(self) weakSelf = self;
    if ([self.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
        FHMultiMediaVideoCell *tempCell = self.mediaView.currentMediaCell;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.mediaView.videoVC.view.frame = bound;
            [weakSelf.mediaView.videoVC pause];
            weakSelf.mediaView.currentMediaCell.playerView = weakSelf.mediaView.videoVC.view;
            [tempCell showCoverView];
        });
    }
}

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

    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
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

            NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
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
#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
    if (vcParentView && self.dataHelper.headerViewData.videoNumer > 0) {
        self.vcParentView = vcParentView;
        CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
        CGFloat navBarHeight = ([TTDeviceHelper isIPhoneXSeries] ? 44 : 20) + 44.0;
        CGFloat cellHei = [FHDetailMediaHeaderCell cellHeight];
        if (-point.y + navBarHeight > cellHei) {
            // 暂停播放
            if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Playing) {
                [self.mediaView.videoVC pause];
            }
        } else {
            // 如果可以重新播放
//            if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Paused) {
//                [self.mediaView.videoVC play];
//            }
        }
    }
}

#pragma mark - FHDetailVCViewLifeCycleProtocol

- (void)vc_viewDidAppear:(BOOL)animated {
//    if (self.vcParentView) {
//        [self fhDetail_scrollViewDidScroll:self.vcParentView];
//    }
    [self.mediaView checkVRLoadingAnimate];
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    if (self.dataHelper.headerViewData.videoNumer > 0 && self.mediaView.videoVC.playbackState == TTVPlaybackState_Playing && !self.mediaView.videoVC.isFullScreen) {
        [self.mediaView.videoVC pause];
    }
}

@end

@implementation FHDetailNeighborhoodMediaHeaderModel

@end
