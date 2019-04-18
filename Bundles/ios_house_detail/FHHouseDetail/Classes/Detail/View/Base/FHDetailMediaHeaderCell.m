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

#define kHEIGHT 300

@interface FHDetailMediaHeaderCell ()<FHMultiMediaScrollViewDelegate>

@property(nonatomic , strong) FHMultiMediaScrollView *mediaView;
@property(nonatomic , strong) FHMultiMediaModel *model;
@property (nonatomic, strong)   NSMutableArray       *imageList;
@property(nonatomic, strong) NSMutableDictionary *pictureShowDict;
@property(nonatomic, assign) BOOL isLarge;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, assign) NSTimeInterval enterTimestamp;

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

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailMediaHeaderModel class]]) {
        return;
    }
    [self.imageList removeAllObjects];
    self.currentData = data;

    [self generateModel];
    [self.mediaView updateWithModel:self.model];
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _pictureShowDict = [NSMutableDictionary dictionary];
        
        _imageList = [[NSMutableArray alloc] init];
        _mediaView = [[FHMultiMediaScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHEIGHT)];
        _mediaView.delegate = self;
        [self.contentView addSubview:_mediaView];
        
        [_mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
            make.height.mas_equalTo(kHEIGHT);
        }];
    }
    return self;
}

- (void)generateModel {
    self.model = [[FHMultiMediaModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    
//    FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
//    itemModel.mediaType = FHMultiMediaTypeVideo;
//    itemModel.videoUrl = @"https://aweme.snssdk.com/aweme/v1/play/?video_id=v03033c20000bbvd7nlehji8cghrbb20&line=0&ratio=default&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0";
//    itemModel.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
//    itemModel.groupType = @"视频";
//    [itemArray addObject:itemModel];
    
    NSArray *houseImageDict = ((FHDetailMediaHeaderModel *)self.currentData).houseImageDictList;

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
    
//
//    FHMultiMediaItemModel *itemModel2 = [[FHMultiMediaItemModel alloc] init];
//    itemModel2.mediaType = FHMultiMediaTypePicture;
//    itemModel2.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
//    itemModel2.groupType = @"图片";
//    [itemArray addObject:itemModel2];
//
//    FHMultiMediaItemModel *itemModel3 = [[FHMultiMediaItemModel alloc] init];
//    itemModel3.mediaType = FHMultiMediaTypePicture;
//    itemModel3.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9thgq2vC0ycF";
//    itemModel3.groupType = @"图片";
//    [itemArray addObject:itemModel3];
//
//    FHMultiMediaItemModel *itemModel4 = [[FHMultiMediaItemModel alloc] init];
//    itemModel4.mediaType = FHMultiMediaTypePicture;
//    itemModel4.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9thfQ36dAgvc";
//    itemModel4.groupType = @"户型";
//    [itemArray addObject:itemModel4];
//
//    FHMultiMediaItemModel *itemModel5 = [[FHMultiMediaItemModel alloc] init];
//    itemModel5.mediaType = FHMultiMediaTypePicture;
//    itemModel5.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9thgLATrEhGe";
//    itemModel5.groupType = @"户型";
//    [itemArray addObject:itemModel5];
    
    self.model.medias = itemArray;
}

-(void)showImagesWithCurrentIndex:(NSInteger)index
{
    NSArray *images = self.imageList;
    if (images.count == 0 || index < 0 || index >= images.count) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.baseViewModel.detailController.ttNeedIgnoreZoomAnimation = YES;
    FHDetailPictureViewController *vc = [[FHDetailPictureViewController alloc] init];
    vc.topVC = self.baseViewModel.detailController;
    vc.dragToCloseDisabled = YES;
    //    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = index;
    vc.albumImageBtnClickBlock = ^(NSInteger index){
        [weakSelf enterPictureShowPictureWithIndex:index];
    };
    vc.albumImageStayBlock = ^(NSInteger index,NSInteger stayTime) {
        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
    };
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:images.count];
    for(id<FHDetailPhotoHeaderModelProtocol> imgModel in images)
    {
        NSMutableDictionary *dict = [[imgModel toDictionary] mutableCopy];
        //change url_list from string array to dict array
        NSMutableArray *dictUrlList = [[NSMutableArray alloc] initWithCapacity:imgModel.urlList.count];
        for (NSString * url in imgModel.urlList) {
            if ([url isKindOfClass:[NSString class]]) {
                [dictUrlList addObject:@{@"url":url}];
            }else{
                [dictUrlList addObject:url];
            }
        }
        dict[@"url_list"] = dictUrlList;
        
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [models addObject:model];
        }
    }
    vc.mediaHeaderModel = (FHDetailMediaHeaderModel *)self.currentData;
    vc.imageInfosModels = models;// 图片展示模型
    
    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index+1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < images.count; i++) {
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
    
    [vc presentPhotoScrollViewWithDismissBlock:^{
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
        
//        NSString 
        dict[@"click_position"] = str;
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
    if (index >= 0 && index < self.imageList.count) {
        [self showImagesWithCurrentIndex:index];
    }
}

- (void)willDisplayCellForItemAtIndex:(NSInteger)index {
    [self trackPictureShowWithIndex:index];
}

- (void)selectItem:(NSString *)title {
    [self trackClickOptions:title];
}

@end

@implementation FHDetailMediaHeaderModel

@end


