//
//  FHHouseFindHistoryItemCell.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindHistoryItemCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

#define ITEM_HOR_MARIN 14

@interface FHHouseFindHistoryItemCell ()

@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UILabel *subtitleLabel;

@end

@implementation FHHouseFindHistoryItemCell

+(CGFloat)widthForTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    
    NSInteger twidth = ceil([title sizeWithAttributes:@{NSFontAttributeName:[UIFont themeFontMedium:14]}].width);
    NSInteger swidth = ceil([subtitle sizeWithAttributes:@{NSFontAttributeName:[UIFont themeFontRegular:12]}].width);
    
    return MIN(137, MAX(twidth, swidth)+2*ITEM_HOR_MARIN);
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:14];
        _titleLabel.textColor = [UIColor themeBlue1];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont themeFontRegular:12];
        _subtitleLabel.textColor = [UIColor themeGray3];
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subtitleLabel];
        
        self.contentView.layer.cornerRadius = 4;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.backgroundColor = [UIColor themeGray7];
        
        [self initConstraints];
        
    }
    return self;
}

-(void)initConstraints
{
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ITEM_HOR_MARIN);
        make.right.mas_lessThanOrEqualTo(self.titleLabel.superview.mas_right).offset(-ITEM_HOR_MARIN);
        make.top.mas_equalTo(8);
        make.height.mas_equalTo(24);
    }];
    
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ITEM_HOR_MARIN);
        make.right.mas_lessThanOrEqualTo(self.subtitleLabel.superview.mas_right).offset(-ITEM_HOR_MARIN);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(20);
    }];
}

-(void)udpateWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    self.titleLabel.text = title;
    self.subtitleLabel.text= subtitle;
}

@end
