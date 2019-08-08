//
//  ArticleListNotifyBarView.m
//  Article
//
//  Created by Zhang Leonardo on 14-4-2.
//
//

#import "ArticleListNotifyBarView.h"
#import <Masonry/Masonry.h>
#import "UIImage+TTThemeExtension.h"
#import "UIView+CustomTimingFunction.h"
#import "TTUIResponderHelper.h"
#import "UIColor+Theme.h"

#define kNotifyLabelFontSize 14.f

@interface ArticleListNotifyBarView()

@property(nonatomic, strong) SSThemedLabel * notifyLabel;
@property(nonatomic, strong) SSThemedButton * bgButton;
@property(nonatomic, copy) XPNotifyBarButtonBlock bgButtonBlock;
@property(nonatomic, copy) XPNotifyBarButtonBlock actionButtonBlock;
@property(nonatomic, copy) XPNotifyBarHideBlock hideBlock;
@property(nonatomic, copy) XPNotifyBarWillHideBlock willHideBlock;

@end

@implementation ArticleListNotifyBarView

- (void)dealloc
{
    [self clean];
    self.notifyLabel = nil;
    self.bgButton = nil;
    self.rightActionButton = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _bgButton.backgroundColors = @[[UIColor themeRed2],[UIColor themeRed2]]; // @[@"d5e9f7",@"788289"];
        [_bgButton addTarget:self action:@selector(bgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        
        [_bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.notifyLabel = [[SSThemedLabel alloc] initWithFrame:self.bounds];
        _notifyLabel.font = [UIFont systemFontOfSize:kNotifyLabelFontSize];
        _notifyLabel.backgroundColor = [UIColor clearColor];
        _notifyLabel.textAlignment = NSTextAlignmentCenter;
        _notifyLabel.textColors = @[[UIColor themeRed3],[UIColor themeRed3]]; //@[@"2a90d7",@"23618e"];
        [self addSubview:_notifyLabel];
        
        [_notifyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.rightActionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _rightActionButton.hidden = YES;
        [_rightActionButton setBackgroundImage:[UIImage themedImageNamed:@"refresh_close"] forState:UIControlStateNormal];
        [_rightActionButton.titleLabel setFont:[UIFont systemFontOfSize:kNotifyLabelFontSize]];
        [_rightActionButton addTarget:self action:@selector(rightActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bgButton addSubview:_rightActionButton];
        
        [_rightActionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgButton);
            make.right.equalTo(self.bgButton).offset(-14);
            make.height.width.equalTo(@50);
        }];
        
        self.hidden = YES;

        [self reloadThemeUI];
        
    }
    return self;
}

- (void)showMessage:(NSString *)message
  actionButtonTitle:(NSString *)title
          delayHide:(BOOL)delayHide
           duration:(float)duration
bgButtonClickAction:(XPNotifyBarButtonBlock)bgButtonBlock
actionButtonClickBlock:(XPNotifyBarButtonBlock)actionButtonBlock
       didHideBlock:(XPNotifyBarHideBlock)hideBlock {
    [self showMessage:message
    actionButtonTitle:title
            delayHide:delayHide
             duration:duration
  bgButtonClickAction:bgButtonBlock
actionButtonClickBlock:actionButtonBlock
         didHideBlock:hideBlock
        willHideBlock:nil];
}

- (void)showMessage:(NSString *)message
  actionButtonTitle:(NSString *)title
          delayHide:(BOOL)delayHide
           duration:(float)duration
bgButtonClickAction:(XPNotifyBarButtonBlock)bgButtonBlock
actionButtonClickBlock:(XPNotifyBarButtonBlock)actionButtonBlock
       didHideBlock:(XPNotifyBarHideBlock)hideBlock
      willHideBlock:(XPNotifyBarWillHideBlock)willHideBlock
{
    if (!self.hidden) {
        [self hideImmediately];
    }

    CGRect rect = CGRectMake([TTUIResponderHelper paddingForViewWidth:0], self.frame.origin.y, self.superview.frame.size.width - [TTUIResponderHelper paddingForViewWidth:0]*2, self.frame.size.height);
    self.frame = rect;
    
    self.bgButtonBlock = bgButtonBlock;
    self.actionButtonBlock = actionButtonBlock;
    self.hideBlock = hideBlock;
    self.willHideBlock = willHideBlock;
    self.clipsToBounds = YES;
    self.hidden = NO;
    self.alpha = 0;
   
    [_notifyLabel setText:message];
    
    _rightActionButton.hidden = delayHide;
    if(isEmptyString(title)){
        [_rightActionButton setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [_rightActionButton setTitle:title forState:UIControlStateNormal];
    }
    
    self.bgButton.transform = CGAffineTransformMakeScale(0.01, 1);
    
    [UIView animateWithDuration:0.25 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        self.bgButton.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
    
    if (delayHide) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideIfNeeds) object:nil];
        [self performSelector:@selector(hideIfNeeds) withObject:nil afterDelay:duration];
    }
    
    self.userClose = !delayHide;
}

- (void)rightActionButtonClicked:(id)sender
{
    [self hideSelf];
    if (_actionButtonBlock) {
        _actionButtonBlock(_rightActionButton);
    }
}

- (void)bgButtonClicked:(id)sender
{
    [self hideSelf];
    if (_bgButtonBlock) {
        _bgButtonBlock(_bgButton);
    }
}

- (void)hideIfNeeds
{
    if (self.userClose || self.hidden) {
        return;
    }
    else
        [self hideSelf];
}

- (void)hideImmediately
{
    self.userClose = NO;
    self.hidden = YES;
    __weak typeof(self) weakSelf = self;
    if(_willHideBlock) {
        _willHideBlock(weakSelf);
    }
    if (_hideBlock) {
        _hideBlock(weakSelf);
    }
}

- (void)hideSelf
{
    self.userClose = NO;
    CGFloat barH = self.bounds.size.height;
    
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformMakeTranslation(0, -barH))) {
        self.hidden = YES;
        return;
    }

    if(self.willHideBlock) {
        WeakSelf;
        self.willHideBlock(wself);
    }
    // 注意，0.3s与TTRefreshView收起列表的动画时间一致
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -barH);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.transform = CGAffineTransformIdentity;
        __weak typeof(self) weakSelf = self;
        if (self.hideBlock) {
            self.hideBlock(weakSelf);
        }
    }];
}

- (void)clean
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.hideBlock = nil;
    self.bgButtonBlock = nil;
    self.actionButtonBlock = nil;
}

- (BOOL)needResetScrollView {
    return self.userClose;
}

+ (UIView<ErrorToastProtocal>*)addErrorToastViewWithTop:(CGFloat)top width:(CGFloat)width height:(CGFloat)height{
    return [[ArticleListNotifyBarView alloc] initWithFrame:CGRectMake(0, top, width, height)];

}

@end
