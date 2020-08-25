//
//  FHDetailNewMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//
//1.处理数据
//3.与楼盘相册和图片详情页交互操作
#import "FHDetailNewMediaHeaderCell.h"
#import "FHDetailNewMediaHeaderScrollView.h"
#import "FHMultiMediaModel.h"
#import "FHDetailPictureViewController.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "FHMultiMediaVideoCell.h"
#import <FHHouseBase/FHUserTrackerDefine.h>
#import "NSString+URLEncoding.h"
#import "FHUtils.h"
#import "FHMultiMediaModel.h"

#import "FHDetailNewModel.h"
#import <FHVRDetailWebViewController.h>
//#import "FHVRCacheManager.h"
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"
#import "FHFloorPanPicShowViewController.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import "FHDetailFloorPanDetailInfoModel.h"
#import <TTUIWidget/TTNavigationController.h>
#import "TTReachability.h"
#import "ToastManager.h"

#import "FHDetailNewMediaHeaderDataHelper.h"
#import "FHDetailNewMediaHeaderView.h"

@interface FHDetailNewMediaHeaderCell ()<FHDetailScrollViewDidScrollProtocol, FHDetailVCViewLifeCycleProtocol>

@property (nonatomic, strong) FHDetailNewMediaHeaderView *headerView;
@property (nonatomic, weak)   UIView *vcParentView;
@property (nonatomic, strong) FHDetailNewMediaHeaderModel *headerModel;
@property (nonatomic, strong) FHMultiMediaModel *model;
@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property (nonatomic, assign) BOOL isLarge;
@property (nonatomic, assign) BOOL isHasClickVR;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, assign)   NSInteger vedioCount;
@property (nonatomic, assign)   CGFloat photoCellHeight;

@property (nonatomic, weak) FHFloorPanPicShowViewController *pictureListViewController;
@property (nonatomic, weak) FHDetailPictureViewController *pictureDetailVC;

@end
@implementation FHDetailNewMediaHeaderCell

- (void)dealloc {
    if (self.vedioCount > 0) {
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"picture";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewMediaHeaderModel class]]) {
        return;
    }
    self.imageList = [NSArray array];

    FHDetailNewMediaHeaderDataHelperData *nData = [FHDetailNewMediaHeaderDataHelper generateModel:(FHDetailNewMediaHeaderModel *)data];
    self.model = [[FHMultiMediaModel alloc] init];
    self.model.medias = nData.itemArray;
    self.imageList = nData.imageList;
    self.headerView.showHeaderImageNewType = ((FHDetailNewMediaHeaderModel *)data).isShowTopImageTab;
    [self.headerView updateMultiMediaModel:self.model];
    [self.headerView setTotalPagesLabelText:[NSString stringWithFormat:@"共%ld张", self.model.medias.count]];

    [self.headerView updateTitleModel:((FHDetailNewMediaHeaderModel *)data).titleDataModel];
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
        [self createUI];
    }
    return self;
}

#pragma mark - UI
- (void)createUI {
    self.pictureShowDict = [NSMutableDictionary dictionary];
    self.vedioCount = 0;
    self.imageList = [[NSMutableArray alloc] init];
    self.headerView = [[FHDetailNewMediaHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
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
    self.headerView.scrollToIndex = ^(NSInteger index) {
        [weakSelf willDisplayCellForItemAtIndex:index];
    };
    self.headerView.didSelectiItemAtIndex = ^(NSInteger index) {
        [weakSelf didSelectItemAtIndex:index];
    };
}

- (void)showImagesWithCurrentIndex:(NSInteger)index {
    NSArray *images = self.imageList;

    if ([images.firstObject isKindOfClass:[FHMultiMediaItemModel class]]) {
        FHMultiMediaItemModel *model = (FHMultiMediaItemModel *)images.firstObject;
        if (model.mediaType == FHMultiMediaTypeVRPicture) {
            NSMutableArray *imageListArray = [NSMutableArray arrayWithArray:images];
            [imageListArray removeObjectAtIndex:0];
            images = imageListArray;
            index = index - 1;
        }
    }

    FHDetailHouseVRDataModel *vrModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vrModel;
    //VR
    if (index < 0 && vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
        if (![TTReachability isNetworkConnected]) {
            [[ToastManager manager] showToast:@"网络异常"];
            return;
        }

        if (vrModel.openUrl) {
            [self trackClickOptions:@"house_vr_icon"];
            NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
            NSMutableDictionary *param = [NSMutableDictionary new];
            param[UT_ELEMENT_TYPE] = @"happiness_eye_tip";
            param[@"enter_from"] = tracerDict[UT_PAGE_TYPE] ? : UT_BE_NULL;
            param[UT_ELEMENT_FROM] = tracerDict[UT_ELEMENT_FROM] ? : UT_BE_NULL;
            param[UT_ORIGIN_FROM] = tracerDict[UT_ORIGIN_FROM] ? : UT_BE_NULL;
            param[UT_ORIGIN_SEARCH_ID] = tracerDict[UT_ORIGIN_SEARCH_ID] ? : UT_BE_NULL;
            param[UT_LOG_PB] = tracerDict[UT_LOG_PB] ? : UT_BE_NULL;
            NSString *reportParams = [FHUtils getJsonStrFrom:param];
            NSString *openUrl = [NSString stringWithFormat:@"%@&report_params=%@", vrModel.openUrl, reportParams];
            self.isHasClickVR = YES;
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://house_vr_web?back_button_color=white&hide_bar=true&hide_back_button=true&hide_nav_bar=true&url=%@", [openUrl URLEncodedString]]]];
//            }
        }
        return;
    }
    if (index < 0 || index >= (images.count + self.vedioCount)) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.baseViewModel.detailController.ttNeedIgnoreZoomAnimation = YES;
    FHDetailPictureViewController *pictureDetailViewController = [[FHDetailPictureViewController alloc] init];
    pictureDetailViewController.houseType = self.baseViewModel.houseType;
    if (self.pictureListViewController) {
        pictureDetailViewController.topVC = self.pictureListViewController;
    } else {
        pictureDetailViewController.topVC = self.baseViewModel.detailController;
    }

    if ([self.baseViewModel.detailData isKindOfClass:[FHDetailNewModel class]]) {
        FHDetailNewModel *model = (FHDetailNewModel *)self.baseViewModel.detailData;
        pictureDetailViewController.associateInfo = model.data.imageGroupAssociateInfo;
        if (!model.data.isShowTopImageTab) {
            //如果是新房，非北京、江州以外的城市，暂时隐藏头部
            pictureDetailViewController.isShowSegmentView = NO;
        }
    }

    // 分享
    pictureDetailViewController.shareActionBlock = ^{
        NSString *v_id = @"be_null";
//        if (weakSelf.mediaView.videoVC.model.videoID.length > 0) {
//            v_id = weakSelf.mediaView.videoVC.model.videoID;
//        }
        NSDictionary *dict = @{ @"item_id": v_id,
                                @"element_from": @"video" };
        [weakSelf.baseViewModel.contactViewModel shareActionWithShareExtra:dict];
    };
    // 收藏
//    pictureDetailViewController.collectActionBlock = ^(BOOL followStatus) {
//        if (followStatus) {
//            [weakSelf.baseViewModel.contactViewModel cancelFollowAction];
//        } else {
//            NSString *v_id = @"be_null";
//            if (weakSelf.mediaView.videoVC.model.videoID.length > 0) {
//                v_id = weakSelf.mediaView.videoVC.model.videoID;
//            }
//            NSDictionary *dict = @{ @"item_id": v_id,
//                                    @"element_from": @"video" };
//            [weakSelf.baseViewModel.contactViewModel followActionWithExtra:dict];
//        }
//    };
    pictureDetailViewController.dragToCloseDisabled = YES;
    if (self.vedioCount > 0) {
//        pictureDetailViewController.videoVC = self.mediaView.videoVC;
    }
    pictureDetailViewController.startWithIndex = index;
    pictureDetailViewController.albumImageBtnClickBlock = ^(NSInteger index) {
        [weakSelf enterPictureShowPictureWithIndex:index from:@"all_pic"];
    };
    pictureDetailViewController.albumImageStayBlock = ^(NSInteger index, NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    pictureDetailViewController.topImageClickTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index element:@"big_photo_album"];
    };

    [pictureDetailViewController setMediaHeaderModel:self.currentData mediaImages:images];
    FHDetailNewMediaHeaderModel *model = ((FHDetailNewMediaHeaderModel *)self.currentData);
    //去除flag判断，改为判断详情页type
    if (self.baseViewModel.houseType == FHHouseTypeNewHouse && [model.topImages isKindOfClass:[NSArray class]] && model.topImages.count > 0) {
//        FHDetailNewTopImage *topImage = model.topImages.firstObject;
//        pictureDetailViewController.smallImageInfosModels = topImage.smallImageGroup;
        pictureDetailViewController.smallImageInfosModels = [model processTopImagesToSmallImageGroups];
    }

    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index + 1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0; i < images.count + self.vedioCount; i++) {
        [placeholders addObject:placeholder];
        NSValue *frameValue = [NSValue valueWithCGRect:frame];
        [frames addObject:frameValue];
    }
    if (!self.pictureListViewController) {
        pictureDetailViewController.placeholderSourceViewFrames = frames;
        pictureDetailViewController.placeholders = placeholders;
    }
    if (model.isShowTopImageTab) {
        __weak FHDetailPictureViewController *weakPictureController = pictureDetailViewController;
        [pictureDetailViewController setAllPhotoActionBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.pictureListViewController) {
                [weakPictureController dismissSelf];
            } else {
                [strongSelf showPictureList];
            }
        }];
    }
    pictureDetailViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        if (currentIndex >= 0 && currentIndex < weakSelf.model.medias.count) {
            weakSelf.currentIndex = currentIndex;
            weakSelf.isLarge = YES;

            NSInteger vrOffset = 0;
            FHDetailHouseVRDataModel *vrModel = ((FHDetailNewMediaHeaderModel *)weakSelf.currentData).vrModel;
            //VR增加偏移
            if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
                vrOffset = 1;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 + vrOffset inSection:0];
//            [weakSelf.mediaView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//            [weakSelf.mediaView updateItemAndInfoLabel];
//            [weakSelf.mediaView updateVideoState];
        }
    };
//    self.mediaView.isShowenPictureVC = YES;
//    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
//        weakSelf.mediaView.isShowenPictureVC = NO;
//        if ([weakSelf.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
//            [weakSelf resetVideoCell:frame];
//        }
//
//        weakSelf.isLarge = NO;
//        [weakSelf trackPictureShowWithIndex:weakSelf.currentIndex];
//        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
//    }];
//
//    pictureDetailViewController.saveImageBlock = ^(NSInteger currentIndex) {
//        [weakSelf trackSavePictureWithIndex:currentIndex];
//    };
//
//    self.isLarge = YES;
//    [self trackPictureShowWithIndex:index];
//    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
//    self.pictureDetailVC = pictureDetailViewController;
}

- (void)showPictureList {
    FHDetailNewMediaHeaderModel *data = (FHDetailNewMediaHeaderModel *)self.currentData;
    NSMutableDictionary *routeParam = [NSMutableDictionary dictionary];
    FHFloorPanPicShowViewController *pictureListViewController = [[FHFloorPanPicShowViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(routeParam)];
    pictureListViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    if (data.isShowTopImageTab) {
        pictureListViewController.topImages = data.topImages;
        pictureListViewController.associateInfo = data.imageAlbumAssociateInfo;
        pictureListViewController.contactViewModel = data.contactViewModel;
        pictureListViewController.elementFrom = @"new_detail";
    } else {
        pictureListViewController.pictsArray = [data processTopImagesToSmallImageGroups];
    }
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
        presentedVC = data.weakVC;
    }
    if (!presentedVC) {
        presentedVC = [TTUIResponderHelper visibleTopViewController];
    }
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:pictureListViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [presentedVC presentViewController:navigationController animated:YES completion:nil];
    self.pictureListViewController = pictureListViewController;
}

//// 重置视频view，注意状态以及是否是首屏幕图片
//- (void)resetVideoCell:(CGRect)frame {
//    CGRect bound = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    __weak typeof(self) weakSelf = self;
//    if ([self.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
//        FHMultiMediaVideoCell *tempCell = self.mediaView.currentMediaCell;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            weakSelf.mediaView.videoVC.view.frame = bound;
//            [weakSelf.mediaView.videoVC pause];
//            weakSelf.mediaView.currentMediaCell.playerView = weakSelf.mediaView.videoVC.view;
//            [tempCell showCoverView];
//        });
//    }
//}

#pragma mark - 埋点
//埋点
- (void)trackClickTabWithIndex:(NSInteger)index element:(NSString *)element {
    index += self.vedioCount;           //如果有视频要+1
    FHDetailHouseVRDataModel *vrModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vrModel;

    if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
        index++;  //如果有VR 再加+1
    }
    if (index >= 0 && index < _model.medias.count) {//删
        FHMultiMediaItemModel *itemModel = _model.medias[index];
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
}

//埋点
- (void)trackPictureShowWithIndex:(NSInteger)index {
    FHMultiMediaItemModel *itemModel = _model.medias[index];
    NSString *showType = self.isLarge ? @"large" : @"small";
    NSString *row = [NSString stringWithFormat:@"%@_%li", showType, (long)index];
    self.isLarge = NO;
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
    FHMultiMediaItemModel *itemModel = _model.medias[index];
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
    FHMultiMediaItemModel *itemModel = _model.medias[index];
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

        if ([str isEqualToString:@"图片"]) {
            dict[@"click_position"] = @"picture";
        } else if ([str isEqualToString:@"户型"]) {
            dict[@"click_position"] = @"house_model";
        } else if ([str isEqualToString:@"视频"]) {
            dict[@"click_position"] = @"video";
        } else if ([str isEqualToString:@"house_vr_icon"]) {
            dict[@"click_position"] = @"house_vr_icon";
        } else if ([str isEqualToString:@"VR"]) {
            dict[@"click_position"] = @"house_vr";
        } else if ([str isEqualToString:@"样板间"]) {
            dict[@"click_position"] = @"prototype";
        } else if ([str isEqualToString:@"街景"]) {
            dict[@"click_position"] = @"panorama";
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
    if (_model.medias.count > index) {
        FHMultiMediaItemModel *itemModel = _model.medias[index];
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

#pragma mark - FHDetailNewMediaHeaderScrollViewDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
    // 图片逻辑
    if (index >= 0 && index < (self.imageList.count + self.vedioCount)) {
        [self showImagesWithCurrentIndex:index];
        return;
    }
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    [self trackPictureShowWithIndex:index];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}

- (void)trackVRElementShow
{
    NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_ELEMENT_TYPE] = @"house_vr";
    param[UT_PAGE_TYPE] = tracerDict[UT_PAGE_TYPE] ? : UT_BE_NULL;
    param[UT_ORIGIN_FROM] = tracerDict[UT_ORIGIN_FROM] ? : UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = tracerDict[UT_ORIGIN_SEARCH_ID] ? : UT_BE_NULL;
    param[UT_LOG_PB] = tracerDict[UT_LOG_PB] ? : UT_BE_NULL;
    param[UT_RANK] = tracerDict[UT_RANK] ? : UT_BE_NULL;
    param[UT_ENTER_FROM] = tracerDict[UT_ENTER_FROM] ? : UT_BE_NULL;
    TRACK_EVENT(UT_OF_ELEMENT_SHOW, param);
}

//进入图片相册页
- (void)goToPictureListFrom:(NSString *)from {
    [self enterPictureShowPictureWithIndex:NSUIntegerMax from:from];
    [self showPictureList];
    if (self.pictureListViewController) {
        self.pictureListViewController.elementFrom = from;
    }
}

#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
//    if (vcParentView && self.vedioCount > 0) {
//        self.vcParentView = vcParentView;
//        CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
//        CGFloat navBarHeight = ([TTDeviceHelper isIPhoneXSeries] ? 44 : 20) + 44.0;
//        CGFloat cellHei = [FHDetailMediaHeaderCell cellHeight];
//        if (-point.y + navBarHeight > cellHei) {
//             暂停播放
//            if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Playing) {
//                [self.mediaView.videoVC pause];
//            }
//        } else {
//             如果可以重新播放
//            if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Paused) {
//                [self.mediaView.videoVC play];
//            }
//        }
//    }
}

#pragma mark - FHDetailVCViewLifeCycleProtocol

- (void)vc_viewDidAppear:(BOOL)animated {
//    if (self.vcParentView) {
//        [self fhDetail_scrollViewDidScroll:self.vcParentView];
//    }
//    [self.mediaView checkVRLoadingAnimate];
}

- (void)vc_viewDidDisappear:(BOOL)animated {
}

@end

@implementation FHDetailNewMediaHeaderModel

- (NSArray *)processTopImagesToSmallImageGroups {
    NSMutableArray <FHHouseDetailImageGroupModel *> *pictsArray = [NSMutableArray array];
    //之前传入fisrtTopImage 表示数据不全，需要全部传入
    for (FHDetailNewTopImage *topImage in self.topImages) {
        for (FHHouseDetailImageGroupModel *groupModel in topImage.smallImageGroup) {
            //type类型相同的数据归为一类
            __block NSUInteger index = NSNotFound;
            [pictsArray enumerateObjectsUsingBlock:^(FHHouseDetailImageGroupModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([obj.type isEqualToString:groupModel.type]) {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound) {
                FHHouseDetailImageGroupModel *existGroupModel = pictsArray[index];
                existGroupModel.images = [[NSArray arrayWithArray:existGroupModel.images] arrayByAddingObjectsFromArray:groupModel.images];
            } else {
                [pictsArray addObject:groupModel.copy];
            }
        }
    }
    return pictsArray.copy;
}

@end
