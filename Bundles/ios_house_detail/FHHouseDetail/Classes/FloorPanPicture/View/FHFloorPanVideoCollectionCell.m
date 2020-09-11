//
//  FHFloorPanVideoCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/8.
//

#import "FHFloorPanVideoCollectionCell.h"
#import "UIImageView+BDWebImage.h"
#import "Masonry.h"
#import "FHFloorPanPicShowModel.h"

@interface FHFloorPanVideoCollectionCell ()
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UIImageView *videoImage;
@property (nonatomic, strong) UIView *maskImageView;
@end

@implementation FHFloorPanVideoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    _imageV = [[UIImageView alloc] init];
    _imageV.contentMode = UIViewContentModeScaleAspectFill;
    _imageV.layer.cornerRadius = 4.0;
    _imageV.layer.masksToBounds = YES;
    _imageV.layer.borderColor = [UIColor colorWithHexStr:@"#ededed"].CGColor;
    _imageV.layer.borderWidth = 0.7;
    [self addSubview:_imageV];

    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];


//    _maskImageView = [UIView new];
//    _maskImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
//    [self addSubview:_maskImageView];
//    [_maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];
    
    _videoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_video_start"]];
    [self addSubview:_videoImage];
    
    [_videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.bottom.mas_equalTo(self.imageV.mas_bottom).offset(-5);
        make.left.mas_equalTo(self.imageV.mas_left).offset(6);
    }];
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[FHFloorPanPicShowItemVideoModel class]]) {
        FHFloorPanPicShowItemVideoModel *model = (FHFloorPanPicShowItemVideoModel *)data;
        if (model.image && model.image.url) {
            [_imageV bd_setImageWithURL:[NSURL URLWithString:model.image.url] placeholder:[UIImage imageNamed: @"default_image"]];
        }
    }
}

@end
