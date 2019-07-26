//
//  FHDetailVideoInfoView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/28.
//

#import "FHDetailVideoInfoView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailVideoInfoView ()

@property (nonatomic, strong)   UIButton       *collectBtn;
@property (nonatomic, strong)   UIButton       *shareBtn;

@end

@implementation FHDetailVideoInfoView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
// 67 或者 67 + 74 = 141
- (void)setupUI {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 33)];
    _priceLabel.text = @"410万";
    _priceLabel.textAlignment = NSTextAlignmentLeft;
    _priceLabel.font = [UIFont themeFontRegular:24];
    _priceLabel.textColor = [UIColor whiteColor];
    [self addSubview:_priceLabel];
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 37, [UIScreen mainScreen].bounds.size.width - 40.0, 30)];
    _infoLabel.text = @"2室1厅 105平 Test";
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    _infoLabel.font = [UIFont themeFontRegular:18];
    _infoLabel.textColor = [UIColor whiteColor];
    [self addSubview:_infoLabel];
    
    UIImage *img ;
    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    img = ICON_FONT_IMG(24, @"\U0000e696", [UIColor whiteColor]);//@"detail_collect_white"
    [_collectBtn setImage:img forState:UIControlStateNormal];
    [_collectBtn setImage:img forState:UIControlStateHighlighted];
    [self addSubview:_collectBtn];
    @weakify(self);
    [[[[_collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:self.rac_willDeallocSignal] throttle:0.3]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self collectAction:x];
    }];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    img = ICON_FONT_IMG(24, @"\U0000e692", [UIColor whiteColor]);
    [_shareBtn setImage:img forState:UIControlStateNormal];
    [_shareBtn setImage:img forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.priceLabel);
        make.right.mas_equalTo(self).offset(-20);
    }];
    
    [self.collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.priceLabel);
        make.right.mas_equalTo(self.shareBtn.mas_left).offset(-30);
    }];
    self.followStatus = 0;
}

- (void)setFollowStatus:(NSInteger)followStatus
{
    _followStatus = followStatus;
    UIImage *img = nil;
    UIColor *color = nil;
    if (followStatus == 1) {
        color = [UIColor themeRed1]; //@"detail_collect_yellow"
    } else  {
        color = [UIColor whiteColor]; //@"detail_collect_white"
        
    }
    img = ICON_FONT_IMG(24, @"\U0000e696", color);    
    [_collectBtn setImage:img forState:UIControlStateNormal];
    [_collectBtn setImage:img forState:UIControlStateHighlighted];
}

- (void)collectAction:(UIButton *)sender
{
    if (self.collectActionBlock) {
        self.collectActionBlock(self.followStatus == 1);
    }
}

- (void)shareAction:(UIButton *)sender
{
    if (self.shareActionBlock) {
        self.shareActionBlock();
    }
}

@end
