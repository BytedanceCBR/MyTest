//
//  FHDetailNewMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//
//3.与楼盘相册和图片详情页交互操作
#import "FHDetailNewMediaHeaderCell.h"
#import "FHDetailNewMediaHeaderScrollView.h"
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

@interface FHDetailNewMediaHeaderCell ()

@property (nonatomic, strong) FHDetailNewMediaHeaderView *headerView;
@property (nonatomic, strong) FHDetailNewMediaHeaderDataHelper *dataHelper;
@property (nonatomic, strong) FHMultiMediaModel *model;
@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property (nonatomic, assign) BOOL isLarge;
@property (nonatomic, assign) BOOL isHasClickVR;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, assign)   CGFloat photoCellHeight;

@property (nonatomic, weak) FHFloorPanPicShowViewController *pictureListViewController;
@property (nonatomic, weak) FHDetailPictureViewController *pictureDetailVC;

@end
@implementation FHDetailNewMediaHeaderCell

- (void)dealloc {
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"picture";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewMediaHeaderModel class]]) {
        return;
    }
    self.imageList = [NSArray array];
    self.currentData = data;
    self.model = [[FHMultiMediaModel alloc] init];
    [self.dataHelper setMediaHeaderModel:data];
    self.model.medias = self.dataHelper.headerViewItemArray;
    self.imageList = self.dataHelper.pictureDetailItemArray;
    self.headerView.showHeaderImageNewType = ((FHDetailNewMediaHeaderModel *)data).isShowTopImageTab;
    [self.headerView updateMultiMediaModel:self.model];
    [self.headerView setTotalPagesLabelText:[NSString stringWithFormat:@"共%ld张", self.model.medias.count]];       //后面要变成全部图片个数+VR个数+视频个数

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
        self.dataHelper = [[FHDetailNewMediaHeaderDataHelper alloc] init];
        [self createUI];
    }
    return self;
}

#pragma mark - UI
- (void)createUI {
    self.pictureShowDict = [NSMutableDictionary dictionary];
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
    if (index < 0 || index >= (images.count)) {
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

    pictureDetailViewController.dragToCloseDisabled = YES;
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
        pictureDetailViewController.smallImageInfosModels = self.dataHelper.smallImageGroups;
    }

    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index + 1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0; i < images.count; i++) {
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
    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
        weakSelf.isLarge = NO;
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];

    pictureDetailViewController.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
    };

    self.isLarge = YES;
    [self trackHeaderViewMediaShowWithIndex:index isLarge:YES];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
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
        self.isHasClickVR = YES;
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://house_vr_web?back_button_color=white&hide_bar=true&hide_back_button=true&hide_nav_bar=true&url=%@", [openUrl btd_stringByURLEncode]]]];
    }
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
        pictureListViewController.pictsArray = self.dataHelper.smallImageGroups;
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

#pragma mark - 埋点
//埋点
- (void)trackClickTabWithIndex:(NSInteger)index element:(NSString *)element {
//    FHDetailHouseVRDataModel *vrModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vrModel;
//
//    if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
//        index++;  //如果有VR 再加+1
//    }
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

//轮播图 埋点
- (void)trackHeaderViewMediaShowWithIndex:(NSInteger)index isLarge:(BOOL)isLarge {
    FHMultiMediaItemModel *itemModel = isLarge ? self.dataHelper.pictureDetailItemArray[index] : self.dataHelper.headerViewItemArray[index];
    NSString *showType = isLarge ? @"large" : @"small";
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

#pragma mark - FHDetailNewMediaHeaderViewBlocks

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHMultiMediaItemModel *itemModel = self.dataHelper.headerViewItemArray[index];
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

@end

@implementation FHDetailNewMediaHeaderModel

@end
