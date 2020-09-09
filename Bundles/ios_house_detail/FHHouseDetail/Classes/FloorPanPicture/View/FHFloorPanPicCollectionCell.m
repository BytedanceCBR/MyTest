//
//  FHFloorPanPicCollectionCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/12.
//

#import "FHFloorPanPicCollectionCell.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHHouseBaseItemCell.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>
#import "FHDetailNewModel.h"

@interface FHFloorPanPicCollectionCell ()
@property (nonatomic,strong) UIImageView *imageV;

@end

@implementation FHFloorPanPicCollectionCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    _imageV=[[UIImageView alloc] init];
    _imageV.contentMode = UIViewContentModeScaleAspectFill;
//    _imageV.layer.borderColor = [UIColor themeGray6].CGColor;
    _imageV.layer.cornerRadius = 4.0;
    _imageV.layer.masksToBounds = YES;
    _imageV.layer.borderColor = [UIColor colorWithHexStr:@"#ededed"].CGColor;
    _imageV.layer.borderWidth = 0.7;
    [self addSubview:_imageV];
    
    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)setDataModel:(FHImageModel *)dataModel
{
    if ([dataModel isKindOfClass:[FHImageModel class]]) {
        FHImageModel *model = (FHImageModel *)dataModel;
        if (model.url) {
            [_imageV bd_setImageWithURL:[NSURL URLWithString:model.url] placeholder:[UIImage imageNamed: @"default_image"]];
        }
    }
}

@end
