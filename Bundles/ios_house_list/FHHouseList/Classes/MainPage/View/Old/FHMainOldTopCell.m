//
//  FHMainOldTopCell.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainOldTopCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHConfigModel.h>

@interface FHMainOldTopCell ()

@property(nonatomic , strong) UIImageView *bgView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;

@end

@implementation FHMainOldTopCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgView.contentMode = UIViewContentModeScaleAspectFill;
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontRegular:15];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontLight:12];
        _subtitleLabel.textColor = RGB(0xff, 0xec, 0xcb);
        
        [self.contentView addSubview:_bgView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subtitleLabel];
        
    }
    return self;
}

-(void)updateWithModel:(FHConfigDataOpData2ItemsModel *)model
{
    
}

@end
