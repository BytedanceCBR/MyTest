//
//  FHHouseFindFakeSearchBar.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/14.
//

#import "FHHouseFindFakeSearchBar.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

@interface FHHouseFindFakeSearchBar ()

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIImageView *iconImageView;

@end

@implementation FHHouseFindFakeSearchBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontRegular:14];
        _titleLabel.textColor = [UIColor themeGray3];
        _titleLabel.text = @"你想住哪里";
        
        UIImage *img = [UIImage imageNamed:@"nav_search_icon"];
        _iconImageView = [[UIImageView alloc] initWithImage:img];
        
        [self addSubview:_titleLabel];
        [self addSubview:_iconImageView];
        
        self.backgroundColor = [UIColor themeGray7];
 
        [self initConstraints];
        
        UITapGestureRecognizer *tapGesteure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesteure];
        
    }
    return self;
}

-(void)initConstraints
{
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(13, 13));
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(15);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(11);
        make.centerY.mas_equalTo(self);
        make.right.mas_lessThanOrEqualTo(self).offset(-10);
    }];
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _titleLabel.text = placeholder;
}

-(NSString *)placeholder
{
    return _titleLabel.text;
}

-(void)onTap:(UITapGestureRecognizer *)gesture
{
    if (_tapBlock) {
        _tapBlock();
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
