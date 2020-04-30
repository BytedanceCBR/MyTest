//
//  FHDetailMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHDetailMediaHeaderCorrectingCell.h"
#import "FHMultiMediaCorrectingScrollView.h"
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

@interface FHDetailMediaHeaderCorrectingCell ()<FHMultiMediaCorrectingScrollViewDelegate,FHDetailScrollViewDidScrollProtocol,FHDetailVCViewLifeCycleProtocol>

@property(nonatomic, strong) FHMultiMediaCorrectingScrollView *mediaView;
@property(nonatomic, strong) FHMultiMediaModel *model;
@property(nonatomic, strong) NSMutableArray *imageList;
@property(nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property(nonatomic, assign) BOOL isLarge;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, assign)   NSInteger       vedioCount;
@property (nonatomic, assign)   CGFloat       photoCellHeight;
@property (nonatomic, weak)     UIView       *vcParentView;

@end

@implementation FHDetailMediaHeaderCorrectingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {
    if(self.vedioCount > 0){
        [self.mediaView.videoVC close];
    }
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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailMediaHeaderCorrectingModel class]]) {
        return;
    }
    [self.imageList removeAllObjects];
    self.currentData = data;
    [self generateModel];
    [self.mediaView updateModel:self.model withTitleModel: ((FHDetailMediaHeaderCorrectingModel *)self.currentData).titleDataModel];
    self.mediaView.baseViewModel = self.baseViewModel;
    //有视频才传入埋点
    if(self.vedioCount > 0){
        self.mediaView.tracerDic = [self tracerDic];
    }
    [self reckoncollectionHeightWithData:data];
}

- (void)reckoncollectionHeightWithData:(id)data {
    FHDetailHouseTitleModel *titleModel =  ((FHDetailMediaHeaderCorrectingModel *)self.currentData).titleDataModel;
    _photoCellHeight = [FHDetailMediaHeaderCorrectingCell cellHeight];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont themeFontMedium:24]};
    CGRect rect = [titleModel.titleStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-66, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];                     //算出标题的高度
    if (titleModel.advantage.length > 0 && titleModel.businessTag.length > 0) { //如果头图下面有横幅那么高度增加40
        _photoCellHeight += 40;
    }
    
    CGFloat rectHeight = rect.size.height;
    if (rectHeight > [UIFont themeFontMedium:24].lineHeight * ((titleModel.housetype == FHHouseTypeNeighborhood || titleModel.isFloorPan)? 1: 2)){          //如果超过两行，只显示两行，小区只显示一行，需要特判
        rectHeight = [UIFont themeFontMedium:24].lineHeight * ((titleModel.housetype == FHHouseTypeNeighborhood || titleModel.isFloorPan)? 1: 2);
    }
    
    _photoCellHeight += 30 + rectHeight - 21;//30是标题具体顶部的距离，21是重叠的41减去透明阴影的20 (21 = 41 - 20)
    
    if (titleModel.tags.count>0) {
        //这里分别加上标签高度20，标签间隔20
        if (!titleModel.isFloorPan) { //因为户型详情页的标签和标题在同一行所以这里特判户型详情页不加上这部分高度
            _photoCellHeight += 20 + 20;
        }
    }
    if (titleModel.isFloorPan) {    //户型详情页特有的总价Label
           _photoCellHeight += 20 + 20;
    }
    
    if (((FHDetailMediaHeaderCorrectingModel *)self.currentData).vedioModel.cellHouseType == FHMultiMediaCellHouseNeiborhood) {
        _photoCellHeight = _photoCellHeight +22;       //小区的地址Label高度
    }
    
    [self.mediaView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(_photoCellHeight);
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
    }
    return self;
}
- (void)createUI {
    _photoCellHeight = [FHDetailMediaHeaderCorrectingCell cellHeight];
    _pictureShowDict = [NSMutableDictionary dictionary];
    _vedioCount = 0;
    _imageList = [[NSMutableArray alloc] init];
    _mediaView = [[FHMultiMediaCorrectingScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _photoCellHeight)];
    _mediaView.delegate = self;
    [self.contentView addSubview:_mediaView];

    [_mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.photoCellHeight);
    }];
}

- (void)generateModel {
    self.model = [[FHMultiMediaModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    NSArray *houseImageDict = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).houseImageDictList;
    FHMultiMediaItemModel *vedioModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vedioModel;
    FHDetailHouseVRDataModel *vrModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vrModel;
    
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
    
    for (FHDetailOldDataHouseImageDictListModel *listModel in houseImageDict) {
//        if (listModel.houseImageTypeName.length > 0) {
            NSString *groupType = nil;
            if(listModel.houseImageType == FHDetailHouseImageTypeApartment){
                groupType = @"户型";
            }else{
                groupType = @"图片";
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
//        }
    }
    
    self.model.medias = itemArray;
    if([self.baseViewModel.detailData isKindOfClass:[FHDetailOldModel class]]) {
        FHDetailOldModel *detailOldModel = (FHDetailOldModel *)self.baseViewModel.detailData;
        self.model.isShowSkyEyeLogo = detailOldModel.data.baseExtra.detective.detectiveInfo.showSkyEyeLogo;
    }
}

-(void)showImagesWithCurrentIndex:(NSInteger)index
{
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
    
    FHDetailHouseVRDataModel *vrModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vrModel;
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
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://house_vr_web?back_button_color=white&hide_bar=true&hide_back_button=true&hide_nav_bar=true&url=%@",[openUrl URLEncodedString]]]];
        }
        
        return;
    }
    
    
    FHMultiMediaItemModel *vedioModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vedioModel;

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
    FHDetailPictureViewController *vc = [[FHDetailPictureViewController alloc] init];
    vc.houseType = self.baseViewModel.houseType;

    vc.topVC = self.baseViewModel.detailController;
    
//    if (FHVideoModel.cellhou == FHCellt) {
//        <#statements#>
//    }
    

    // 获取图片需要的房源信息数据
    if ([self.baseViewModel.detailData isKindOfClass:[FHDetailOldModel class]]) {
        // 二手房数据
        FHDetailOldModel *model = (FHDetailOldModel *)self.baseViewModel.detailData;
        NSString *priceStr = @"";
        NSString *infoStr = @"";
        if (vedioModel && vedioModel.videoID.length > 0) {
            priceStr = vedioModel.infoTitle;
            infoStr = vedioModel.infoSubTitle;
        }
        NSString *houseId = model.data.id;
        vc.houseId = houseId;
        vc.priceStr = priceStr;
        vc.infoStr = infoStr;

        vc.followStatus = self.baseViewModel.contactViewModel.followStatus;
    }
    
    //如果是小区，移除按钮 或者户型详情页也移除按钮
    
    FHDetailMediaHeaderCorrectingModel *model1 = ((FHDetailMediaHeaderCorrectingModel *)self.currentData);
    if (vedioModel.cellHouseType == FHMultiMediaCellHouseNeiborhood || model1.titleDataModel.isFloorPan) {
        vc.isShowAllBtns = NO;
    }
    
    // 分享
    vc.shareActionBlock = ^{
        NSString *v_id = @"be_null";
        if (weakSelf.mediaView.videoVC.model.videoID.length > 0) {
            v_id = weakSelf.mediaView.videoVC.model.videoID;
        }
        NSDictionary *dict = @{@"item_id":v_id,
                               @"element_from":@"video"};
        [weakSelf.baseViewModel.contactViewModel shareActionWithShareExtra:dict];
    };
    // 收藏
    vc.collectActionBlock = ^(BOOL followStatus) {
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
    vc.dragToCloseDisabled = YES;
    if(self.vedioCount > 0){
        vc.videoVC = self.mediaView.videoVC;
    }
    vc.startWithIndex = index;
    vc.albumImageBtnClickBlock = ^(NSInteger index){
        [weakSelf enterPictureShowPictureWithIndex:index];
    };
    vc.albumImageStayBlock = ^(NSInteger index,NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    vc.topImageClickTabBlock = ^(NSInteger index) {
        [weakSelf trackClickTabWithIndex:index];
    };
    
    [vc setMediaHeaderModel:self.currentData mediaImages:images];
    FHDetailMediaHeaderCorrectingModel *model = ((FHDetailMediaHeaderCorrectingModel *)self.currentData);
    if (!model.isShowTopImageTab && [model.topImages isKindOfClass:[NSArray class]] && model.topImages.count > 0) {
        FHDetailNewTopImage *topImage = model.topImages.firstObject;
        vc.smallImageInfosModels = topImage.smallImageGroup;
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
    vc.placeholderSourceViewFrames = frames;
    vc.placeholders = placeholders;
    vc.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        if (currentIndex >= 0 && currentIndex < weakSelf.model.medias.count) {
            weakSelf.currentIndex = currentIndex;
            weakSelf.isLarge = YES;
            
            NSInteger vrOffset = 0;
            FHDetailHouseVRDataModel *vrModel = ((FHDetailMediaHeaderCorrectingModel *)weakSelf.currentData).vrModel;
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
    [vc presentPhotoScrollViewWithDismissBlock:^{
        
        
        weakSelf.mediaView.isShowenPictureVC = NO;
        if ([weakSelf.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
            [weakSelf resetVideoCell:frame];
        }
        
        weakSelf.isLarge = NO;
        [weakSelf trackPictureShowWithIndex:weakSelf.currentIndex];
        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];
    
    vc.saveImageBlock = ^(NSInteger currentIndex) {
        [weakSelf trackSavePictureWithIndex:currentIndex];
    };
    
    self.isLarge = YES;
    [self trackPictureShowWithIndex:index];
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
}

// 重置视频view，注意状态以及是否是首屏幕图片
- (void)resetVideoCell:(CGRect)frame {
    CGRect bound = CGRectMake(0, 0, frame.size.width, frame.size.height);
    __weak typeof(self) weakSelf = self;
    if ([self.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
        FHMultiMediaVideoCell *tempCell = self.mediaView.currentMediaCell;
        FHMultiMediaItemModel *vedioModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vedioModel;
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

//埋点
- (void)trackClickTabWithIndex:(NSInteger )index {
    index += self.vedioCount;           //如果有视频要+1
    FHDetailHouseVRDataModel *vrModel = ((FHDetailMediaHeaderCorrectingModel *)self.currentData).vrModel;
    
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
            dict[@"tab_name"] = itemModel.pictureTypeName;;
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
        
        if([dict isKindOfClass:[NSDictionary class]]){
            [dict removeObjectsForKeys:@[@"card_type",@"rank",@"element_from"]];
            dict[@"picture_id"] = itemModel.imageUrl;
            dict[@"show_type"] = @"large";
        }
    }
    return dict;
}

//埋点
- (void)enterPictureShowPictureWithIndex:(NSInteger)index {
    NSMutableDictionary *dict = [self traceParamsForGallery:index];
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
    
    if ([(FHDetailMediaHeaderCorrectingModel *)self.currentData isInstantData]) {
        //列表页带入的数据不响应
        return;
    }
    // 图片逻辑
    if (index >= 0 && index < (self.imageList.count + self.vedioCount)) {
        [self showImagesWithCurrentIndex:index];
    }
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    
    if ([(FHDetailMediaHeaderCorrectingModel *)self.currentData isInstantData]) {
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

@implementation FHDetailMediaHeaderCorrectingModel

@end


