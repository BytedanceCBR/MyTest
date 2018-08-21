//
//  AKProfileHeaderView.m
//  News
//
//  Created by chenjiesheng on 2018/3/2.
//

#import "AKProfileHeaderView.h"
#import "AKProfileHeaderViewLogined.h"
#import "AKProfileHeaderViewUnLogin.h"

#import <UIColor+TTThemeExtension.h>
#import <TTAccountManager.h>
@interface AKProfileHeaderView () <AKProfileHeaderViewUnLoginDelegate,AKProfileHeaderViewLoginedDelegate>

@property (nonatomic, strong)AKProfileHeaderViewUnLogin         *unloginView;
@property (nonatomic, strong)AKProfileHeaderViewLogined         *loginedView;
@property (nonatomic, strong)UIView                             *bottomSeparatView;
@property (nonatomic, weak)IBOutlet NSObject<AKProfileHeaderViewDelegate> *delegate;
@property (nonatomic, weak)IBOutlet UITableView                          *tableView;
@end

@implementation AKProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [super setValue:value forUndefinedKey:key];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat topInset = 20;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        topInset = 44.f;
    }
    CGFloat bottomInset = self.bottomSeparatView.height;
    CGSize finalSize;
    if ([TTAccountManager isLogin]) {
        finalSize = self.loginedView.size;
    } else {
        topInset = 0;
        finalSize = self.unloginView.size;
    }
    finalSize.height += topInset + bottomInset;
    return finalSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat topInset = 20;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        topInset = 44.f;
    }
    self.loginedView.origin = CGPointMake(0, topInset);
    self.unloginView.origin = CGPointMake(0, 0);
    CGFloat separateViewTop = self.loginedView.hidden ? self.unloginView.bottom : self.loginedView.bottom;
    self.bottomSeparatView.origin = CGPointMake(0, separateViewTop);
}

- (void)createComponent
{
    [self createBottomSeparateView];
    [self createLoginedView];
    [self createUnloginView];
    self.loginedView.hidden = ![TTAccountManager isLogin];
    self.unloginView.hidden = [TTAccountManager isLogin];
}

- (void)createBottomSeparateView
{
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 8.f)];
    separateView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    separateView.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    [self addSubview:separateView];
    self.bottomSeparatView = separateView;
}

- (void)createLoginedView
{
    AKProfileHeaderViewLogined *view = [[AKProfileHeaderViewLogined alloc] initWithDelegate:self];
    [view sizeToFit];
    [self addSubview:view];
    self.loginedView = view;
}

- (void)createUnloginView
{
    AKProfileHeaderViewUnLogin *view = [[AKProfileHeaderViewUnLogin alloc] init];
    view.delegate = self;
    [view sizeToFit];
    [self addSubview:view];
    self.unloginView = view;
}

#pragma private

- (void)refreshLoginViewAndUnLoginViewStatus
{
    self.loginedView.hidden = ![TTAccountManager isLogin];
    self.unloginView.hidden = [TTAccountManager isLogin];
    [self sizeToFit];
    [self setNeedsLayout];
    self.tableView.tableHeaderView = self;
}

- (void)refreshUserinfo
{
    if (self.loginedView.hidden) {
        return;
    }
    [self.loginedView refreshUserInfo];
}

- (void)refreshBenefitInfoWithModels:(NSArray<AKProfileBenefitModel *> *)model
{
    [self.loginedView refreshBenefitInfoWithModels:model];
}

#pragma AKProfileHeaderViewUnLoginDelegate

- (void)loginButtonClicked:(NSString *)platform
{
    if ([self.delegate respondsToSelector:@selector(loginButtonClicked:)]) {
        [self.delegate loginButtonClicked:platform];
    }
}

#pragma AKProfileHeaderViewLoginedDelegate

- (void)infoViewRegionClicked
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
