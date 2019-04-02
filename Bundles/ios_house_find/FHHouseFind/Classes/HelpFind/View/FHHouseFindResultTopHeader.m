//
//  FHHouseFindResultTopHeader.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/1.
//

#import "FHHouseFindResultTopHeader.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@interface FHHouseFindResultTopHeader ()

@property(nonatomic , strong) UIImageView *backImageView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIView *iconContainerView;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;

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
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        _titleLabel.text = @"未能找到符合条件房源";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.top.mas_equalTo(60);
            make.height.mas_equalTo(28);
        }];
        
        _iconContainerView = [UIView new];
        _iconContainerView.layer.masksToBounds = YES;
        _iconContainerView.layer.cornerRadius = 4;
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

- (void)refreshUI:(FHHouseFindRecommendDataModel *)model
{
    if(![model isKindOfClass:[FHHouseFindRecommendDataModel class]])
    {
        return;
    }
    
    for (NSInteger i = 0; i < 3; i++) {
        UIView *itemView = [UIView new];
        [_iconContainerView addSubview:itemView];
        [itemView setBackgroundColor:[UIColor whiteColor]];
        
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(([UIScreen mainScreen].bounds.size.width - 40)/3 * i);
            make.height.mas_equalTo(80);
            make.width.mas_equalTo(([UIScreen mainScreen].bounds.size.width - 40)/3);
            make.top.mas_equalTo(0);
        }];
        
        UIImageView *imageIcon = [UIImageView new];
        NSString *stringImageName = [NSString stringWithFormat:@"house_find_help_icon%ld",i+1];
        imageIcon.image = [UIImage imageNamed:stringImageName];
        [itemView addSubview:imageIcon];
        
        [imageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(itemView);
            make.width.height.mas_equalTo(24);
            make.top.mas_equalTo(20);
        }];
        
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        [itemView addSubview:subTitleLabel];
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        subTitleLabel.font = [UIFont themeFontRegular:12];
        subTitleLabel.textColor = [UIColor themeGray1];
        
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(itemView);
            make.left.right.equalTo(itemView);
            make.top.mas_equalTo(48);
        }];
        
        switch (i) {
            case 0:
            {
                subTitleLabel.text = model.priceTitle;
            }
                break;
            case 1:
            {
                subTitleLabel.text = model.districtTitle;
            }
                break;
            case 2:
            {
                subTitleLabel.text = model.roomNumTitle;
            }
                break;
            default:
                break;
        }
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
