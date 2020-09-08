//
//  FHFloorPanVideoCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/8.
//

#import "FHFloorPanVideoCollectionCell.h"
#import "UIImageView+BDWebImage.h"
#import "Masonry.h"

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
    [self addSubview:_imageV];

    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];


    _maskImageView = [UIView new];
    _maskImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self addSubview:_maskImageView];
    [_maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    _videoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon_small"]];
    [self addSubview:_videoImage];
    
    [_videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.bottom.mas_equalTo(self.imageV.mas_bottom).offset(-5);
        make.left.mas_equalTo(self.imageV.mas_left).offset(6);
    }];
}

- (void)setDataModel:(FHImageModel *)dataModel {
    if ([dataModel isKindOfClass:[FHImageModel class]]) {
        FHImageModel *model = (FHImageModel *)dataModel;
        if (model.url) {
            [_imageV bd_setImageWithURL:[NSURL URLWithString:model.url] placeholder:[UIImage imageNamed: @"default_image"]];
        }
    }
}


@end
