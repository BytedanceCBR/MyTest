//
//  FHDetailMediaHeaderCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHDetailMediaHeaderCell.h"
#import "FHMultiMediaScrollView.h"
#import "FHMultiMediaModel.h"
#import "FHDetailOldModel.h"
#import "FHDetailPictureViewController.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "FHMultiMediaVideoCell.h"

@interface FHDetailMediaHeaderCell ()<FHMultiMediaScrollViewDelegate,FHDetailScrollViewDidScrollProtocol,FHDetailVCViewLifeCycleProtocol>

@property(nonatomic, strong) FHMultiMediaScrollView *mediaView;
@property(nonatomic, strong) FHMultiMediaModel *model;
@property(nonatomic,strong) NSMutableArray *imageList;
@property(nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property(nonatomic, assign) BOOL isLarge;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) NSTimeInterval enterTimestamp;
@property (nonatomic, assign)   NSInteger       vedioCount;
@property (nonatomic, assign)   CGFloat       photoCellHeight;
@property (nonatomic, weak)     UIView       *vcParentView;

@end

@implementation FHDetailMediaHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {
    [self.mediaView.videoVC close];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    if(self.vedioCount > 0){
        return @"video";
    }
    return @"picture";
}

+ (CGFloat)cellHeight {
    CGFloat photoCellHeight = 300.0; // 默认300
    photoCellHeight = [UIScreen mainScreen].bounds.size.width / 375.0f * photoCellHeight;
    return photoCellHeight;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailMediaHeaderModel class]]) {
        return;
    }
    [self.imageList removeAllObjects];
    self.currentData = data;
    
    self.mediaView.tracerDic = [self tracerDic];

    [self generateModel];
    [self.mediaView updateWithModel:self.model];
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
        _photoCellHeight = [FHDetailMediaHeaderCell cellHeight];
        _pictureShowDict = [NSMutableDictionary dictionary];
        _vedioCount = 0;
        _imageList = [[NSMutableArray alloc] init];
        _mediaView = [[FHMultiMediaScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _photoCellHeight)];
        _mediaView.delegate = self;
        [self.contentView addSubview:_mediaView];
        
        [_mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
            make.height.mas_equalTo(self.photoCellHeight);
        }];
    }
    return self;
}

- (void)generateModel {
    self.model = [[FHMultiMediaModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    
    NSArray *houseImageDict = ((FHDetailMediaHeaderModel *)self.currentData).houseImageDictList;
    FHMultiMediaItemModel *vedioModel = ((FHDetailMediaHeaderModel *)self.currentData).vedioModel;
    if (vedioModel && vedioModel.videoID.length > 0) {
        self.vedioCount = 1;
        [itemArray addObject:vedioModel];
    }
    for (FHDetailOldDataHouseImageDictListModel *listModel in houseImageDict) {
        if (listModel.houseImageTypeName.length > 0) {
            NSString *groupType = nil;
            if(listModel.houseImageType == FHDetailHouseImageTypeApartment){
                groupType = @"户型";
            }else{
                groupType = @"图片";
            }
            
            for (FHDetailHouseDataItemsHouseImageModel *imageModel in listModel.houseImageList) {
                if (imageModel.url.length > 0) {
                    FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
                    itemModel.mediaType = FHMultiMediaTypePicture;
                    itemModel.imageUrl = imageModel.url;
                    itemModel.groupType = groupType;
                    [itemArray addObject:itemModel];
                    [self.imageList addObject:imageModel];
                }
            }
        }
    }
    
    self.model.medias = itemArray;
}

-(void)showImagesWithCurrentIndex:(NSInteger)index
{
    NSArray *images = self.imageList;
    if (index < 0 || index >= (images.count + self.vedioCount)) {
        return;
    }
    if (index < self.vedioCount) {
        // 视频
        if (self.mediaView.videoVC.playbackState == TTVideoEnginePlaybackStateStopped) {
            // 第一次 非播放状态直接播放即可
            [self.mediaView.videoVC play];
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    self.baseViewModel.detailController.ttNeedIgnoreZoomAnimation = YES;
    FHDetailPictureViewController *vc = [[FHDetailPictureViewController alloc] init];
    vc.topVC = self.baseViewModel.detailController;
    // 获取图片需要的房源信息数据
    if ([self.baseViewModel.detailData isKindOfClass:[FHDetailOldModel class]]) {
        // 二手房数据
        FHDetailOldModel *model = (FHDetailOldModel *)self.baseViewModel.detailData;
        NSString *priceStr = @"";
        NSString *infoStr = @"";
        FHMultiMediaItemModel *vedioModel = ((FHDetailMediaHeaderModel *)self.currentData).vedioModel;
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
    vc.videoVC = self.mediaView.videoVC;
    vc.startWithIndex = index;
    vc.albumImageBtnClickBlock = ^(NSInteger index){
        [weakSelf enterPictureShowPictureWithIndex:index];
    };
    vc.albumImageStayBlock = ^(NSInteger index,NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    
    [vc setMediaHeaderModel:self.currentData mediaImages:images];
    
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
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
            [weakSelf.mediaView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            [weakSelf.mediaView updateItemAndInfoLabel];
        }
    };
    self.mediaView.isShowenPictureVC = YES;
    [vc presentPhotoScrollViewWithDismissBlock:^{
        weakSelf.mediaView.isShowenPictureVC = NO;
        if ([weakSelf.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
            // 当前是视频
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
    __weak typeof(self) weakSelf = self;
    if ([self.mediaView.currentMediaCell isKindOfClass:[FHMultiMediaVideoCell class]]) {
        FHMultiMediaVideoCell *tempCell = self.mediaView.currentMediaCell;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.mediaView.videoVC.view.frame = frame;
            weakSelf.mediaView.currentMediaCell.playerView = weakSelf.mediaView.videoVC.view;
            weakSelf.mediaView.videoVC.model.isShowControl = NO;
            weakSelf.mediaView.videoVC.model.isShowMiniSlider = YES;
            [weakSelf.mediaView.videoVC updateData:weakSelf.mediaView.videoVC.model];
        });
    }
}

//埋点
- (void)trackPictureShowWithIndex:(NSInteger)index {
    FHMultiMediaItemModel *itemModel = _model.medias[index];
    NSString *showType = self.isLarge ? @"large" : @"small";
    NSString *row = [NSString stringWithFormat:@"%@_%i",showType,index];
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
        }

        dict[@"rank"] = @"be_null";
        
        TRACK_EVENT(@"click_options", dict);
    }else{
        NSAssert(NO, @"传入的detailTracerDic不是字典");
    }
}

- (NSDictionary *)traceParamsForGallery:(NSInteger)index
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


#pragma mark - FHMultiMediaScrollViewDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
    // 图片逻辑
    if (index >= 0 && index < (self.imageList.count + self.vedioCount)) {
        [self showImagesWithCurrentIndex:index];
    }
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    [self trackPictureShowWithIndex:index];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}

#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
//   if (vcParentView) {
//        self.vcParentView = vcParentView;
//        CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
//        CGFloat navBarHeight = ([TTDeviceHelper isIPhoneXDevice] ? 44 : 20) + 44.0;
//        CGFloat cellHei = [FHDetailMediaHeaderCell cellHeight];
//        if (-point.y + navBarHeight > cellHei) {
//            // 暂停播放
//            if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Playing) {
//                [self.mediaView.videoVC pause];
//            }
//        } else {
//            // 如果可以重新播放
//            if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Paused) {
//                [self.mediaView.videoVC play];
//            }
//        }
//   }
}

#pragma mark - FHDetailVCViewLifeCycleProtocol

- (void)vc_viewDidAppear:(BOOL)animated {
//    if (self.vcParentView) {
//        [self fhDetail_scrollViewDidScroll:self.vcParentView];
//    }
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    if (self.mediaView.videoVC.playbackState == TTVPlaybackState_Playing) {
        [self.mediaView.videoVC pause];
    }
}

@end

@implementation FHDetailMediaHeaderModel

@end


