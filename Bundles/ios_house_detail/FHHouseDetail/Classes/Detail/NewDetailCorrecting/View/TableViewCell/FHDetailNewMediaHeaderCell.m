//
//  FHDetailNewMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//
//1.处理数据
//2.将除了轮播图之外的所有View处理
//3.与楼盘相册和图片详情页交互操作
#import "FHDetailNewMediaHeaderCell.h"
#import "FHDetailNewMediaHeaderScrollView.h"
#import "FHMultiMediaModel.h"
#import "FHDetailOldModel.h"
#import "FHDetailPictureViewController.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "FHMultiMediaVideoCell.h"
#import <FHHouseBase/FHUserTrackerDefine.h>
#import "NSString+URLEncoding.h"
#import "FHUtils.h"
#import "FHMultiMediaModel.h"
#import "FHCommonDefines.h"
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
#import "FHDetailHeaderTitleView.h"

@interface FHDetailNewMediaHeaderCell ()<FHDetailNewMediaHeaderScrollViewDelegate,FHDetailScrollViewDidScrollProtocol,FHDetailVCViewLifeCycleProtocol>


@property(nonatomic, strong) FHDetailNewMediaHeaderScrollView *mediaView;
@property (nonatomic, weak)     UIView       *vcParentView;
@property(nonatomic, strong) UIView *bottomGradientView;
@property(nonatomic, strong) FHDetailHeaderTitleView *titleView;            //头图下面的标题栏


@property(nonatomic, strong) FHMultiMediaModel *model;
@property(nonatomic, strong) NSMutableArray *imageList;
@property(nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property(nonatomic, assign) BOOL isLarge;
@property(nonatomic, assign) BOOL isHasClickVR;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, assign)   NSInteger       vedioCount;
@property (nonatomic, assign)   CGFloat       photoCellHeight;

@property (nonatomic, weak , nullable)UIViewController *weakDetailVC;

@property (nonatomic, weak) FHFloorPanPicShowViewController *pictureListViewController;
@property (nonatomic, weak) FHDetailPictureViewController *pictureDetailVC;

@end
@implementation FHDetailNewMediaHeaderCell

- (void)dealloc {
    if(self.vedioCount > 0){
        [self.mediaView.videoVC close];
    }
//    [[FHVRCacheManager sharedInstance] removeVRPreloadCache:self.hash];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    if(self.vedioCount > 0){
        return @"video";
    }
    return @"picture";
}

+ (CGFloat)cellHeight {
    CGFloat photoCellHeight = 281;
    photoCellHeight = round([UIScreen mainScreen].bounds.size.width / 375.0f * photoCellHeight + 0.5);
    return photoCellHeight;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewMediaHeaderModel class]]) {
        return;
    }
    [self.imageList removeAllObjects];
    self.currentData = data;
    [self generateModel];
    self.mediaView.isShowTopImageTab = [(FHDetailNewMediaHeaderModel *)self.currentData isShowTopImageTab];
    self.mediaView.baseViewModel = self.baseViewModel;
    self.titleView.baseViewModel = self.baseViewModel;
    
    [self.mediaView updateModel:self.model];
    self.titleView.model = ((FHDetailNewMediaHeaderModel *)self.currentData).titleDataModel;
    //有视频才传入埋点
    if(self.vedioCount > 0){
        self.mediaView.tracerDic = [self tracerDic];
    }
    [self reckoncollectionHeightWithData:((FHDetailNewMediaHeaderModel *)self.currentData).titleDataModel];
    
    if (((FHDetailNewMediaHeaderModel *)data).weakVC) {
        self.weakDetailVC = ((FHDetailNewMediaHeaderModel *)data).weakVC;
    }
}

- (void)createVRPreloadWebview{

         
}

- (void)reckoncollectionHeightWithData:(FHDetailHouseTitleModel *)titleModel {
    
    CGFloat titleHeight = 41;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont themeFontMedium:24]};
    CGRect rect = [titleModel.titleStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-66, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];                     //算出标题的高度
    if (titleModel.advantage.length > 0 && titleModel.businessTag.length > 0) { //如果头图下面有横幅那么高度增加40
        titleHeight += 40;
    }
    
    CGFloat rectHeight = rect.size.height;
    if (rectHeight > [UIFont themeFontMedium:24].lineHeight * 2){          //如果超过两行，只显示两行，小区只显示一行，需要特判
        rectHeight = [UIFont themeFontMedium:24].lineHeight * 2;
    }
    
    titleHeight += 20 + rectHeight - 21;//20是标题具体顶部的距离，21是重叠的41减去透明阴影的20 (21 = 41 - 20)
    
    if (titleModel.tags.count>0) {
        //这里分别加上标签高度20，标签间隔20
        titleHeight += 20 + 20;
    }
    
    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(titleHeight);
    }];
}
- (NSDictionary *)tracerDic {
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    
    if([dict isKindOfClass:[NSDictionary class]]){
        [dict removeObjectsForKeys:@[@"card_type"]];
        return dict;
    }else{
        return nil;
    }
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
        [self initConstaints];
    }
    return self;
}
- (void)createUI {
    _photoCellHeight = [FHDetailNewMediaHeaderCell cellHeight];
    _pictureShowDict = [NSMutableDictionary dictionary];
    _vedioCount = 0;
    _imageList = [[NSMutableArray alloc] init];
    _mediaView = [[FHDetailNewMediaHeaderScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _photoCellHeight)];
    _mediaView.delegate = self;
    [self.contentView addSubview:_mediaView];
    
    [self.contentView addSubview:self.bottomGradientView];
    self.titleView = [[FHDetailHeaderTitleView alloc]init];
    [self.contentView addSubview:self.titleView];
    
    // 底部渐变层
}

- (void)initConstaints {
    [_mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.photoCellHeight);
    }];
    
    [self.bottomGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.mediaView);
        make.bottom.equalTo(self.mediaView);
        make.height.mas_equalTo(self.bottomGradientView.frame.size.height);
    }];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.mediaView.mas_bottom).offset(-41);
        make.height.equalTo(0);
    }];
    
}

-(UIView *)bottomGradientView {
    if(!_bottomGradientView){
        
        CGFloat aspect = 375.0 / 25;
        CGFloat width = SCREEN_WIDTH;
        
        CGFloat height = round(width / aspect + 0.5);
        CGRect frame = CGRectMake(0, 0, width, height);
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = frame;
        gradientLayer.colors = @[
                                 (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor,
                                 (__bridge id)[UIColor themeGray7].CGColor
                                 ];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 0.9);
        
        _bottomGradientView = [[UIView alloc] initWithFrame:frame];
        [_bottomGradientView.layer addSublayer:gradientLayer];
    }
    return _bottomGradientView;
}

- (void)generateModel {
    self.model = [[FHMultiMediaModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    NSArray *houseImageDict = ((FHDetailNewMediaHeaderModel *)self.currentData).houseImageDictList;
    FHMultiMediaItemModel *vedioModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vedioModel;
    FHDetailHouseVRDataModel *vrModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vrModel;
    FHMultiMediaItemModel *baiduPanoramaModel = ((FHDetailNewMediaHeaderModel *)self.currentData).baiduPanoramaModel;
    if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
        FHMultiMediaItemModel *itemModelVR = [[FHMultiMediaItemModel alloc] init];
        itemModelVR.mediaType = FHMultiMediaTypeVRPicture;
        
        if (vrModel.vrImage.url) {
            itemModelVR.imageUrl = vrModel.vrImage.url;
        }
        itemModelVR.groupType = @"VR";
        [itemArray addObject:itemModelVR];
        [self.imageList addObject:itemModelVR];
        
        [self trackVRElementShow];
    }
    
    if (vedioModel && vedioModel.videoID.length > 0) {
        self.vedioCount = 1;
        [itemArray addObject:vedioModel];
    }
    
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        NSString *groupType = nil;
        if (listModel.usedSceneType == FHHouseDetailImageListDataUsedSceneTypeFloorPan) {
            if (listModel.houseImageType == 2001) {
                groupType = @"户型";
            } else {
                groupType = @"样板间";
            }
        } else {
            if(listModel.houseImageType == FHDetailHouseImageTypeApartment){
                groupType = @"户型";
            }else{
                groupType = @"图片";
            }
        }
        
        NSInteger index = 0;
        NSArray<FHImageModel> *instantHouseImageList = listModel.instantHouseImageList;
        
        
        for (FHImageModel *imageModel in listModel.houseImageList) {
            if (imageModel.url.length > 0) {
                FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
                itemModel.mediaType = FHMultiMediaTypePicture;
                itemModel.imageUrl = imageModel.url;
                itemModel.pictureType = listModel.houseImageType;
                itemModel.pictureTypeName = listModel.houseImageTypeName;
                itemModel.groupType = groupType;
                if (instantHouseImageList.count > index) {
                    FHImageModel *instantImgModel = instantHouseImageList[index];
                    itemModel.instantImageUrl = instantImgModel.url;
                }
                [itemArray addObject:itemModel];
                [self.imageList addObject:imageModel];
            }
            index++;
        }
    }
    
    if (baiduPanoramaModel && baiduPanoramaModel.imageUrl.length > 0) {
        [itemArray addObject:baiduPanoramaModel];
    }
    
    self.model.medias = itemArray;
}

-(void)showImagesWithCurrentIndex:(NSInteger)index {
    NSArray *images = self.imageList;
    
    if([images.firstObject isKindOfClass:[FHMultiMediaItemModel class]])
    {
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
                param[@"enter_from"] = tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
                param[UT_ELEMENT_FROM] = tracerDict[UT_ELEMENT_FROM]?:UT_BE_NULL;
                param[UT_ORIGIN_FROM] = tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
                param[UT_ORIGIN_SEARCH_ID] = tracerDict[UT_ORIGIN_SEARCH_ID]?:UT_BE_NULL;
                param[UT_LOG_PB] = tracerDict[UT_LOG_PB]?:UT_BE_NULL;
                NSString *reportParams = [FHUtils getJsonStrFrom:param];
                NSString *openUrl = [NSString stringWithFormat:@"%@&report_params=%@",vrModel.openUrl,reportParams];
                self.isHasClickVR = YES;
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://house_vr_web?back_button_color=white&hide_bar=true&hide_back_button=true&hide_nav_bar=true&url=%@",[openUrl URLEncodedString]]]];
//            }
        }
        return;
    }
    
    
    FHMultiMediaItemModel *vedioModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vedioModel;

    if (index < 0 || index >= (images.count + self.vedioCount)) {
        return;
    }
    
//    if (index < self.vedioCount && vedioModel.cellHouseType != FHMultiMediaCellHouseNeiborhood) {
//        // 视频
//        if (self.mediaView.videoVC.playbackState == TTVideoEnginePlaybackStateStopped || self.mediaView.videoVC.playbackState == TTVideoEnginePlaybackStatePaused) {
//            // 第一次 非播放状态直接播放即可
//            [self.mediaView.videoVC play];
//            return;
//        }
//    }
    
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
        if (weakSelf.mediaView.videoVC.model.videoID.length > 0) {
            v_id = weakSelf.mediaView.videoVC.model.videoID;
        }
        NSDictionary *dict = @{@"item_id":v_id,
                               @"element_from":@"video"};
        [weakSelf.baseViewModel.contactViewModel shareActionWithShareExtra:dict];
    };
    // 收藏
    pictureDetailViewController.collectActionBlock = ^(BOOL followStatus) {
        if (followStatus) {
            [weakSelf.baseViewModel.contactViewModel cancelFollowAction];
        } else {
            NSString *v_id = @"be_null";
            if (weakSelf.mediaView.videoVC.model.videoID.length > 0) {
                v_id = weakSelf.mediaView.videoVC.model.videoID;
            }
            NSDictionary *dict = @{@"item_id":v_id,
                                   @"element_from":@"video"};
            [weakSelf.baseViewModel.contactViewModel followActionWithExtra:dict];
        }
    };
    pictureDetailViewController.dragToCloseDisabled = YES;
    if(self.vedioCount > 0){
        pictureDetailViewController.videoVC = self.mediaView.videoVC;
    }
    pictureDetailViewController.startWithIndex = index;
    pictureDetailViewController.albumImageBtnClickBlock = ^(NSInteger index){
        [weakSelf enterPictureShowPictureWithIndex:index from:@"all_pic"];
    };
    pictureDetailViewController.albumImageStayBlock = ^(NSInteger index,NSInteger stayTime) {
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
    //如果是小区，移除按钮 或者户型详情页也移除按钮
    //099 户型详情页 显示底部按钮
    
    if (vedioModel.cellHouseType == FHMultiMediaCellHouseNeiborhood) {// || model.titleDataModel.isFloorPan
        pictureDetailViewController.isShowBottomBar = NO;
    }
    if (model.titleDataModel.isFloorPan && model.titleDataModel.titleStr.length) {
        NSMutableString *bottomBarTitle = model.titleDataModel.titleStr.mutableCopy;
        if (model.titleDataModel.squaremeter.length) {
            [bottomBarTitle appendFormat:@" %@",model.titleDataModel.squaremeter];
        }
        if (model.titleDataModel.facingDirection.length) {
            [bottomBarTitle appendFormat:@" %@",model.titleDataModel.facingDirection];
        }
        if (model.titleDataModel.saleStatus.length) {
             [bottomBarTitle appendFormat:@" %@",model.titleDataModel.saleStatus];
        }
        pictureDetailViewController.bottomBarTitle = bottomBarTitle.copy;
    }
    
    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index+1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < images.count + self.vedioCount; i++) {
        [placeholders addObject:placeholder];
        NSValue *frameValue = [NSValue valueWithCGRect:frame];
        [frames addObject:frameValue];
    }
    if (!self.pictureListViewController) {
        pictureDetailViewController.placeholderSourceViewFrames = frames;
        pictureDetailViewController.placeholders = placeholders;
    }
    if (model.isShowTopImageTab) {
        __weak FHDetailPictureViewController * weakPictureController = pictureDetailViewController;
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
            if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr)
            {
                vrOffset = 1;
            }
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 + vrOffset inSection:0];
            [weakSelf.mediaView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            [weakSelf.mediaView updateItemAndInfoLabel];
            [weakSelf.mediaView updateVideoState];
        }
    };
    self.mediaView.isShowenPictureVC = YES;
    [pictureDetailViewController presentPhotoScrollViewWithDismissBlock:^{
        
        
        weakSelf.mediaView.isShowenPictureVC = NO;
        if ([weakSelf.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
            [weakSelf resetVideoCell:frame];
        }
        
        weakSelf.isLarge = NO;
        [weakSelf trackPictureShowWithIndex:weakSelf.currentIndex];
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];
    
    pictureDetailViewController.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
    };
    
    self.isLarge = YES;
    [self trackPictureShowWithIndex:index];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
    self.pictureDetailVC = pictureDetailViewController;
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
    __weak typeof(self)weakSelf = self;
    pictureListViewController.albumImageStayBlock = ^(NSInteger index, NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    pictureListViewController.albumImageBtnClickBlock = ^(NSInteger index){
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

// 重置视频view，注意状态以及是否是首屏幕图片
- (void)resetVideoCell:(CGRect)frame {
    CGRect bound = CGRectMake(0, 0, frame.size.width, frame.size.height);
    __weak typeof(self) weakSelf = self;
    if ([self.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
        FHMultiMediaVideoCell *tempCell = self.mediaView.currentMediaCell;
//        FHMultiMediaItemModel *vedioModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vedioModel;
//        if (vedioModel.cellHouseType == FHMultiMediaCellHouseNeiborhood) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.mediaView.videoVC.view.frame = bound;
                [weakSelf.mediaView.videoVC pause];
                weakSelf.mediaView.currentMediaCell.playerView = weakSelf.mediaView.videoVC.view;
                [tempCell showCoverView];
            });
//        }else
//        {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                weakSelf.mediaView.videoVC.view.frame = bound;
//                weakSelf.mediaView.currentMediaCell.playerView = weakSelf.mediaView.videoVC.view;
//                weakSelf.mediaView.videoVC.model.isShowControl = NO;
//                weakSelf.mediaView.videoVC.model.isShowMiniSlider = YES;
//                weakSelf.mediaView.videoVC.model.isShowStartBtnWhenPause = YES;
//                [weakSelf.mediaView.videoVC updateData:weakSelf.mediaView.videoVC.model];
//            });
//        }
    }
}
#pragma mark - 埋点
//埋点
- (void)trackClickTabWithIndex:(NSInteger )index element:(NSString *)element{
    index += self.vedioCount;           //如果有视频要+1
    FHDetailHouseVRDataModel *vrModel = ((FHDetailNewMediaHeaderModel *)self.currentData).vrModel;
    
    if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
        index ++ ;//如果有VR 再加+1
    }
    if (index >= 0 && index < _model.medias.count) {//删
        FHMultiMediaItemModel *itemModel = _model.medias[index];
        NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
        if(!dict){
            dict = [NSMutableDictionary dictionary];
        }
        if([dict isKindOfClass:[NSDictionary class]]){
            [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from"]];
            dict[@"picture_id"] = itemModel.imageUrl;
            dict[@"tab_name"] = itemModel.pictureTypeName;
            if (element) {
                dict[@"element_type"] = element;
            }
            TRACK_EVENT(@"click_tab", dict);
        }else{
            NSAssert(NO, @"传入的detailTracerDic不是字典");
        }
    }
}

//埋点
- (void)trackPictureShowWithIndex:(NSInteger)index {
    FHMultiMediaItemModel *itemModel = _model.medias[index];
    NSString *showType = self.isLarge ? @"large" : @"small";
    NSString *row = [NSString stringWithFormat:@"%@_%li",showType,(long)index];
    self.isLarge = NO;
    if (_pictureShowDict[row]) {
        return;
    }
    
    _pictureShowDict[row] = row;
    
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    if([dict isKindOfClass:[NSDictionary class]]){
        [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"picture_type"] = itemModel.pictureTypeName;
        dict[@"show_type"] = showType;
        TRACK_EVENT(@"picture_show", dict);
    }else{
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackPictureLargeStayWithIndex:(NSInteger)index {
    FHMultiMediaItemModel *itemModel = _model.medias[index];
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    
    if([dict isKindOfClass:[NSDictionary class]]){
        [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"show_type"] = @"large";
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTimestamp;
        if (duration <= 0) {
            return;
        }
        
        dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",(duration*1000)];
        self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
        TRACK_EVENT(@"picture_large_stay", dict);
    }else{
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackSavePictureWithIndex:(NSInteger)index {
    FHMultiMediaItemModel *itemModel = _model.medias[index];
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    
    if([dict isKindOfClass:[NSDictionary class]]){
        [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from"]];
        dict[@"picture_id"] = itemModel.imageUrl;
        dict[@"show_type"] = @"large";
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTimestamp;
        if (duration <= 0) {
            return;
        }
        
        dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",(duration*1000)];
        TRACK_EVENT(@"picture_save", dict);
    }else{
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

//埋点
- (void)trackClickOptions:(NSString *)str {
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if(!dict){
        dict = [NSMutableDictionary dictionary];
    }
    
    if([dict isKindOfClass:[NSDictionary class]]){
        [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from",@"origin_search_id",@"log_pb",@"origin_from"]];
        
        if([str isEqualToString:@"图片"]){
            dict[@"click_position"] = @"picture";
        }else if([str isEqualToString:@"户型"]){
            dict[@"click_position"] = @"house_model";
        }else if([str isEqualToString:@"视频"]){
            dict[@"click_position"] = @"video";
        }else if([str isEqualToString:@"house_vr_icon"]){
            dict[@"click_position"] = @"house_vr_icon";
        }else if([str isEqualToString:@"VR"]){
            dict[@"click_position"] = @"house_vr";
        }else if ([str isEqualToString:@"样板间"]) {
            dict[@"click_position"] = @"prototype";
        }else if ([str isEqualToString:@"街景"]) {
            dict[@"click_position"] = @"panorama";
        }

        dict[@"rank"] = @"be_null";
        
        TRACK_EVENT(@"click_options", dict);
    }else{
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

- (NSMutableDictionary *)traceParamsForGallery:(NSInteger)index
{
    NSMutableDictionary *dict = [self.baseViewModel.detailTracerDic mutableCopy];
    if (_model.medias.count > index) {
        FHMultiMediaItemModel *itemModel = _model.medias[index];
        if(!dict){
            dict = [NSMutableDictionary dictionary];
        }
        dict[@"picture_id"] = itemModel.imageUrl;
    }
    if([dict isKindOfClass:[NSDictionary class]]){
        [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from"]];
    }
    dict[@"show_type"] = @"large";
    return dict;
}

//埋点
- (void)enterPictureShowPictureWithIndex:(NSInteger)index from:(NSString *)from{
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
    
    if ([(FHDetailNewMediaHeaderModel *)self.currentData isInstantData]) {
        //列表页带入的数据不响应
        return;
    }
    // 图片逻辑
    if (index >= 0 && index < (self.imageList.count + self.vedioCount)) {
        [self showImagesWithCurrentIndex:index];
        return;
    }
    //vr
    FHMultiMediaItemModel *itemModel = _model.medias[index];
    if (itemModel.mediaType == FHMultiMediaTypeBaiduPanorama && itemModel.imageUrl.length) {
        //进入百度街景
        //shceme baidu_panorama_detail
        if (![TTReachability isNetworkConnected]) {
            [[ToastManager manager] showToast:@"网络异常"];
            return;
        }
        
        NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
        NSMutableDictionary *param = [NSMutableDictionary new];
        tracerDict[@"element_from"] = @"picture";
        param[TRACER_KEY] = tracerDict.copy;
        
        NSString *gaodeLat = nil;
        NSString *gaodeLon = nil;
        // 获取图片需要的房源信息数据
        if ([self.baseViewModel.detailData isKindOfClass:[FHDetailOldModel class]]) {
            // 二手房数据
            FHDetailOldModel *model = (FHDetailOldModel *)self.baseViewModel.detailData;
            gaodeLat = model.data.neighborhoodInfo.gaodeLat;
            gaodeLon = model.data.neighborhoodInfo.gaodeLng;

        }else if ([self.baseViewModel.detailData isKindOfClass:[FHDetailNewModel class]]) {
            FHDetailNewModel *model = (FHDetailNewModel *)self.baseViewModel.detailData;
            gaodeLat = model.data.coreInfo.gaodeLat;
            gaodeLon = model.data.coreInfo.gaodeLng;
        }else if ([self.baseViewModel.detailData isKindOfClass:[FHDetailNeighborhoodModel class]]) {
            FHDetailNeighborhoodModel *model = (FHDetailNeighborhoodModel *)self.baseViewModel.detailData;
            gaodeLat = model.data.neighborhoodInfo.gaodeLat;
            gaodeLon = model.data.neighborhoodInfo.gaodeLng;
        } else if ([self.baseViewModel.detailData isKindOfClass:[FHDetailFloorPanDetailInfoModel class]]) {
            //户型详情
//            FHDetailFloorPanDetailInfoModel *model = (FHDetailFloorPanDetailInfoModel *)self.baseViewModel.detailData;
        }
        if (gaodeLat.length && gaodeLon.length) {
            param[@"gaodeLat"] = gaodeLat;
            param[@"gaodeLon"] = gaodeLon;
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
        }
    }
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    
    if ([(FHDetailNewMediaHeaderModel *)self.currentData isInstantData]) {
        //列表页带入的数据不报埋点
        return;
    }
    
    [self trackPictureShowWithIndex:index];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}

- (void)bottomBannerViewDidShow {
    
    NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_ELEMENT_TYPE] = @"happiness_eye_tip";
    param[UT_PAGE_TYPE] = tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    param[UT_ELEMENT_FROM] = tracerDict[UT_ELEMENT_FROM]?:UT_BE_NULL;
    param[UT_ORIGIN_FROM] = tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = tracerDict[UT_ORIGIN_SEARCH_ID]?:UT_BE_NULL;
    param[UT_LOG_PB] = tracerDict[UT_LOG_PB]?:UT_BE_NULL;
    TRACK_EVENT(UT_OF_ELEMENT_SHOW, param);
}

- (void)trackVRElementShow
{
    NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_ELEMENT_TYPE] = @"house_vr";
    param[UT_PAGE_TYPE] = tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    param[UT_ORIGIN_FROM] = tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = tracerDict[UT_ORIGIN_SEARCH_ID]?:UT_BE_NULL;
    param[UT_LOG_PB] = tracerDict[UT_LOG_PB]?:UT_BE_NULL;
    param[UT_RANK] = tracerDict[UT_RANK]?:UT_BE_NULL;
    param[UT_ENTER_FROM] = tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    TRACK_EVENT(UT_OF_ELEMENT_SHOW, param);
}

//进入图片页面页
- (void)goToPictureListFrom:(NSString *)from {
    
    if ([(FHDetailNewMediaHeaderModel *)self.currentData isInstantData]) {
        //列表页带入的数据不响应
        return;
    }
    [self enterPictureShowPictureWithIndex:NSUIntegerMax from:from];
    [self showPictureList];
    if (self.pictureListViewController) {
        self.pictureListViewController.elementFrom = from;
    }
}

#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
   if (vcParentView && self.vedioCount > 0) {
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
    if (self.vedioCount > 0 && self.mediaView.videoVC.playbackState == TTVPlaybackState_Playing && !self.mediaView.videoVC.isFullScreen) {
        [self.mediaView.videoVC pause];
    }
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
             [pictsArray enumerateObjectsUsingBlock:^(FHHouseDetailImageGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

