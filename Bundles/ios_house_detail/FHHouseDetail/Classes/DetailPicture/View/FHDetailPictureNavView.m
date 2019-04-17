//
//  FHDetailPictureNavView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/15.
//

#import "FHDetailPictureNavView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>

@interface FHDetailPictureNavView ()
@property (nonatomic, strong)   UIImage       *backWhiteImage;
@property(nonatomic , strong) UIButton *backBtn;
@property (nonatomic, strong)   UILabel       *titleLabel;// 图片

@end

@implementation FHDetailPictureNavView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.frame = CGRectMake(18, 10, 24, 24);
    [self addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.frame.size.width - 100, 24)];
    _titleLabel.text = @"图片";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont themeFontMedium:18];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
}

- (void)backAction:(UIButton *)sender
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (UIImage *)backWhiteImage
{
    if (!_backWhiteImage) {
        _backWhiteImage = [UIImage imageNamed:@"detail_back_white"];
    }
    return _backWhiteImage;
}


@end
