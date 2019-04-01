//
//  FHHouseFindResultTopHeader.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/1.
//

#import "FHHouseFindResultTopHeader.h"
#import <Masonry.h>
#import <UIFont+House.h>

@interface FHHouseFindResultTopHeader ()

@property(nonatomic , strong) UIImageView *backImageView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIView *iconContainerView;
@property (nonatomic , strong) FHHouseFindRecommendModel *recommendModel;

@end

@implementation FHHouseFindResultTopHeader


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house_find_help_top"]];
        [self addSubview:_backImageView];
        
        [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self);
            make.height.mas_equalTo(159);
        }];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontMedium:20];
        [self addSubview:_titleLabel];
        _titleLabel.text = @"未能找到符合条件房源";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.top.mas_equalTo(60);
            make.height.mas_equalTo(28);
        }];
        
        _iconContainerView = [UIView new];
        [_iconContainerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_iconContainerView];
        
        
        [_iconContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(80);
        }];
    }
    return self;
}

- (void)refreshUI:(FHHouseFindRecommendModel *)model
{
    for (NSInteger i = 0; i < 3; i++) {
        UIView *itemView = [UIView new];
        [_iconContainerView addSubview:itemView];

        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20 + ([UIScreen mainScreen].bounds.size.width - 40)/3);
            make.top.bottom.equalTo(self.iconContainerView);
            make.height.mas_equalTo(80);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
