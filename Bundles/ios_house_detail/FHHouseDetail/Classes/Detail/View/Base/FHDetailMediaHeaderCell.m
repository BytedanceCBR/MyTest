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

#define kHEIGHT 300

@interface FHDetailMediaHeaderCell ()<FHMultiMediaScrollViewDelegate>

@property(nonatomic , strong) FHMultiMediaScrollView *mediaView;
@property(nonatomic , strong) FHMultiMediaModel *model;

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
    self.currentData = data;

    [self generateModel];
    [self.mediaView updateWithModel:self.model];
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
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

#pragma mark - FHMultiMediaScrollViewDelegate

- (void)didSelectItemAtIndex:(NSInteger)index {
    
}

@end

@implementation FHDetailMediaHeaderModel

@end


