//
//  FHFloorPanPicCollectionCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/12.
//

#import "FHFloorPanPicCollectionCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHHouseBaseItemCell.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>

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
    _imageV.layer.borderColor = [UIColor themeGray6].CGColor;
    _imageV.layer.borderWidth = 0.5;
    _imageV.clipsToBounds = YES;
    [self addSubview:_imageV];
    
    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).mas_offset(0);
        make.width.mas_equalTo(78 * [TTDeviceHelper scaleToScreen375]);
        make.height.mas_equalTo(78 * [TTDeviceHelper scaleToScreen375]);
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
