//
//  FHMainRentTopCell.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainRentTopCell.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHConfigModel.h>

#define ITEM_HOR_MARGIN 2
#define ITEM_VER_MARGIN 8

@implementation FHMainRentTopCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = frame.size.width - 2*ITEM_HOR_MARGIN;
        
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(ITEM_HOR_MARGIN, 0, width, width)];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, width + ITEM_VER_MARGIN, frame.size.width, 20)];
        _nameLabel.font = [UIFont themeFontRegular:14];
        _nameLabel.textColor = [UIColor themeGray1];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_nameLabel];
        
        
    }
    return self;
}

-(void)updateWithIcon:(NSString *)iconUrl name:(NSString *)name
{
    UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];
    [_iconView bd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholder:placeHolder];
    _nameLabel.text = name;
}

-(void)updateWithModel:(FHConfigDataRentOpDataItemsModel *)model
{
    UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];
    FHConfigDataRentOpDataItemsImageModel*img = [model.image firstObject];
    [_iconView bd_setImageWithURL:[NSURL URLWithString:img.url] placeholder:placeHolder];
    
    _nameLabel.text = model.title;
    
    if (model.textColor.length > 0) {
        _nameLabel.textColor = [UIColor colorWithHexString:model.textColor];
    }
    
//    if (model.backgroundColor.length > 0) {
//
//    }
        
}

@end
