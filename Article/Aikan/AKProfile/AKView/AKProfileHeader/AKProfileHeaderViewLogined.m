//
//  AKProfileHeaderViewLogined.m
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import "AKTaskSettingHelper.h"
#import "AKProfileHeaderInfoView.h"
#import "AKProfileHeaderViewDefine.h"
#import "AKProfileHeaderViewLogined.h"
#import <TTAccountManager.h>
#import <UIColor+TTThemeExtension.h>

@interface AKProfileHeaderViewLogined ()

@property (nonatomic, strong)AKProfileHeaderInfoView                    *infoView;
@property (nonatomic, strong)UIView                                     *centerSeparateView;
@property (nonatomic, strong)AKProfileHeaderBeneficialView              *beneficialView;
@property (nonatomic, weak)NSObject<AKProfileHeaderViewLoginedDelegate> *delegate;

@end

@implementation AKProfileHeaderViewLogined

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<AKProfileHeaderViewLoginedDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = self.infoView.height;
    if ([AKTaskSettingHelper shareInstance].akBenefitEnable) {
        height += self.beneficialView.height;
    }
    return CGSizeMake(self.width > 0 ? self.width : [TTUIResponderHelper mainWindow].width, height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.infoView.frame = CGRectMake(0, 0, self.width, kHeightProfileHeaderViewInfoView);
    self.centerSeparateView.frame = CGRectMake(kHPaddingContentView, self.infoView.bottom - .5, self.width - kHPaddingContentView * 2, .5);
    self.beneficialView.hidden = ![AKTaskSettingHelper shareInstance].akBenefitEnable;
    self.centerSeparateView.hidden = self.beneficialView.hidden;
    self.beneficialView.frame = CGRectMake(0, self.infoView.bottom, self.width, kHeightProfileHeaderViewBeneficialView);
}

- (void)createComponent
{
    [self createInfoView];
    [self createBeneficalView];
    [self createSeparateView];
    [self refreshUserInfo];
}

- (void)createInfoView
{
    AKProfileHeaderInfoView *infoView = [[AKProfileHeaderInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width, kHeightProfileHeaderViewInfoView)];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoViewTapGestureAction:)];
    [infoView addGestureRecognizer:gesture];
    [self addSubview:infoView];
    self.infoView = infoView;
}

- (void)createBeneficalView
{
    AKProfileHeaderBeneficialView *beneficalView = [[AKProfileHeaderBeneficialView alloc] initWithFrame:CGRectMake(0, kHeightProfileHeaderViewInfoView, self.width, kHeightProfileHeaderViewBeneficialView)];
    beneficalView.delegate = self.delegate;
    [self addSubview:beneficalView];
    self.beneficialView = beneficalView;
}

- (void)createSeparateView
{
    _centerSeparateView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithHexString:@"E9E9E9"];
        view.height = .5;
        view;
    });
    [self addSubview:_centerSeparateView];
}

#pragma setter

- (void)setDelegate:(NSObject<AKProfileHeaderViewLoginedDelegate> *)delegate
{
    _delegate = delegate;
    self.beneficialView.delegate = delegate;
}

#pragma public

- (void)refreshUserInfo
{
    if ([[TTAccount sharedAccount] isLogin]) {
        [self.infoView setupAvatorImageWithImageURL:[TTAccountManager avatarURLString]];
        [self.infoView setupUserName:TTAccountManager.userName];
    } else {
        [self.infoView setupAvatorImageWithImageURL:nil];
        [self.infoView setupUserName:@"未登录"];
    }
}

- (void)refreshBenefitInfoWithModels:(NSArray<AKProfileBenefitModel *> *)model
{
    [self.beneficialView refreshBenefitInfoWithModels:model];
}

#pragma private

- (void)infoViewTapGestureAction:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(infoViewRegionClicked)]) {
        [self.delegate infoViewRegionClicked];
    }
}

- (void)beneficalButtonClickedWithModel:(AKProfileBenefitModel *)model beneficButton:(AKProfileHeaderBeneficialButton *)button
{
    if ([self.delegate respondsToSelector:@selector(beneficalButtonClickedWithModel:beneficButton:)]) {
        [self.delegate beneficalButtonClickedWithModel:model beneficButton:button];
    }
}

@end
