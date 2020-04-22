//
//  FHDetectiveTopView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import "FHDetectiveTopView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>


@interface FHDetectiveTopView ()

@property(nonatomic , strong) UIImageView *bgView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIButton *reportButton;

@end

@implementation FHDetectiveTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    UIImage *img = [UIImage imageNamed:@"detail_detective_bg"];
    _bgView = [[UIImageView alloc] initWithImage:img];
    
    CGFloat ratio = 0;
    if (img.size.width > 0) {
        ratio = img.size.height / img.size.width;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontSemibold:20];
    _titleLabel.textColor = [UIColor themeOrange1];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.textColor = [UIColor themeGray3];
    _tipLabel.font = [UIFont themeFontRegular:12];
    
    _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reportButton setTitle:@"举报" forState:UIControlStateNormal];
    [_reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_reportButton setBackgroundColor:[UIColor themeRed1]];
    [_reportButton setImage:[UIImage imageNamed:@"detail_detective_btn"] forState:UIControlStateNormal];
    [_reportButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    _reportButton.titleLabel.font = [UIFont themeFontRegular:14];
    _reportButton.layer.cornerRadius = 4;
    _reportButton.layer.masksToBounds = YES;
    
    [self addSubview:_bgView];
    [self addSubview:_titleLabel];
    [self addSubview:_tipLabel];
    [self addSubview:_reportButton];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(screenWidth * ratio);
        make.bottom.mas_equalTo(0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.height.mas_equalTo(28);
    }];

    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
    }];
    
    [_reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(33);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(56);
    }];
}

- (void)updateWithTitle:(NSString *)title tip:(NSString *)tip
{
    self.titleLabel.text = title;
    self.tipLabel.text = tip;
}

-(void)onAction:(id)sender
{
    if (self.tapBlock) {
        self.tapBlock();
    }
}


@end
