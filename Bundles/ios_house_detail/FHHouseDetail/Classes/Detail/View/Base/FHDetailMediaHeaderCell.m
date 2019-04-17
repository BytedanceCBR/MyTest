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

#define kHEIGHT 300

@interface FHDetailMediaHeaderCell ()<FHMultiMediaScrollViewDelegate>

@property(nonatomic , strong) FHMultiMediaScrollView *mediaView;
@property(nonatomic , strong) FHMultiMediaModel *model;
@property (nonatomic, strong)   NSMutableArray       *imageList;

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
    
    NSArray *houseImageDict = ((FHDetailMediaHeaderModel *)self.currentData).houseImageDictList;

    for (FHDetailOldDataHouseImageDictListModel *listModel in houseImageDict) {
        NSString *groupType = nil;
        if([listModel.houseImageTypeName isEqualToString:@"户型"] ){
            groupType = @"户型";
        }else{
            groupType = @"图片";
        }
        
        for (FHDetailHouseDataItemsHouseImageModel *imageModel in listModel.houseImageList) {
            FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
            itemModel.mediaType = FHMultiMediaTypePicture;
            itemModel.imageUrl = imageModel.url;
            itemModel.groupType = groupType;
            [itemArray addObject:itemModel];
            [self.imageList addObject:imageModel];
        }
    }
    
//    FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
//    itemModel.mediaType = FHMultiMediaTypeVideo;
//    itemModel.videoUrl = @"https://aweme.snssdk.com/aweme/v1/play/?video_id=v03033c20000bbvd7nlehji8cghrbb20&line=0&ratio=default&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0";
//    itemModel.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
//    itemModel.groupType = @"视频";
//    [itemArray addObject:itemModel];
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
    
    FHDetailPictureViewController *vc = [[FHDetailPictureViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    //    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = index;
    vc.albumImageBtnClickBlock = ^(NSInteger index){
//        [weakSelf enterPictureShowPictureWithIndex:index];
    };
    vc.albumImageStayBlock = ^(NSInteger index,NSInteger stayTime) {
//        [weakSelf stayPictureShowPictureWithIndex:index andTime:stayTime];
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
//        if (currentIndex >= 0 && currentIndex < weakSelf.images.count) {
//            weakSelf.currentIndex = currentIndex;
//            weakSelf.isLarge = YES;
//            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
//            [weakSelf.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//        }
    };
    
    [vc presentPhotoScrollViewWithDismissBlock:^{
//        weakSelf.isLarge = NO;
//        [weakSelf trackPictureShowWithIndex:weakSelf.currentIndex];
//        [weakSelf trackPictureLargeStayWithIndex:weakSelf.currentIndex];
    }];
    
    vc.saveImageBlock = ^(NSInteger currentIndex) {
//        [weakSelf trackSavePictureWithIndex:currentIndex];
    };
    
//    self.isLarge = YES;
//    [self trackPictureShowWithIndex:index];
//    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
}


#pragma mark - FHMultiMediaScrollViewDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
    // 图片逻辑
    if (index >= 0 && index < self.imageList.count) {
        [self showImagesWithCurrentIndex:index];
    }
}

@end

@implementation FHDetailMediaHeaderModel

@end


