//
//  FHFalseListTopHeaderView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/30.
//

#import "FHFalseListTopHeaderView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIImageView+BDWebImage.h"

@interface FHFalseListTopHeaderView ()

@property(nonatomic , strong) UIImageView *bannerImageView;

@end

@implementation FHFalseListTopHeaderView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bannerImageView = [[UIImageView alloc] init];
        [self addSubview:_bannerImageView];
        
        [_bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self);
            make.height.mas_equalTo(120);
        }];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:18];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        [_titleLabel setBackgroundColor:[UIColor whiteColor]];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.bottom.equalTo(self).offset(0);
            make.height.mas_equalTo(28);
        }];
    }
    return self;
}

- (void)refreshUI:(NSString *)title andImageUrl:(NSURL *)imageUrl
{
    _titleLabel.text = title;
    [_bannerImageView bd_setImageWithURL:imageUrl placeholder:[UIImage imageNamed:@"default_image"]];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
