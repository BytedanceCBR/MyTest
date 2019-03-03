//
//  FHHouseFindTextItemCell.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindTextItemCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

@interface FHHouseFindTextItemCell ()

@property(nonatomic , strong) UILabel *titleLabel;

@end

@implementation FHHouseFindTextItemCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontRegular:12];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_greaterThanOrEqualTo(5);
            make.right.mas_lessThanOrEqualTo(self.contentView).offset(-5);
            make.center.mas_equalTo(self.contentView);
        }];
        
        self.contentView.layer.cornerRadius = 4;
        self.contentView.layer.masksToBounds = YES;
        
    }
    return self;
}

-(void)updateWithTitle:(NSString *)title highlighted:(BOOL)highlighted
{
    self.titleLabel.text = title;
    self.contentView.backgroundColor = highlighted ? [UIColor themeBlue2] : [UIColor themeGray7];
    self.titleLabel.textColor = highlighted ? [UIColor themeWhite] :  [UIColor themeGray1];
}

@end