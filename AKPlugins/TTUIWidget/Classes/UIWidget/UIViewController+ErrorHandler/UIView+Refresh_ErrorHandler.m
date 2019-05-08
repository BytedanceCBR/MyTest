//
//  UIViewController+Refresh_ErrorHandler.m
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import "UIView+Refresh_ErrorHandler.h"
#import "TTFullScreenLoadingView.h"
#import "TTFullScreenErrorView.h"

//Toutiao Yewu
//#import "ArticleListNotifyBarView.h"
#import "TTThemeManager.h"
#import "UIScrollView+Refresh.h"
#import "UIViewAdditions.h"

#define kSessionExpiredErrorCode            1003
#define kMissingSessionKeyErrorCode         1007

#define kNotifyBarViewHeight kTTPullRefreshLoadingHeight

CGFloat const kTipDefaultDuration = 2.0f;

CGFloat const kTipDurationInfinite = -1.0f;


@import ObjectiveC;

@implementation UIView (Refresh_ErrorHandler)

#pragma mark properties

- (UIEdgeInsets)ttContentInset {
    
    NSValue * value = objc_getAssociatedObject(self, @selector(ttContentInset));
    return [value UIEdgeInsetsValue];
}

- (void)setTtContentInset:(UIEdgeInsets)ttContentInset {
    
    objc_setAssociatedObject(self, @selector(ttContentInset),[NSValue valueWithUIEdgeInsets: ttContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView*)ttIndicator {
    
    return (UIActivityIndicatorView*)objc_getAssociatedObject(self, @selector(ttIndicator));
}

- (void)setTtIndicator:(UIActivityIndicatorView *)ttIndicator {
    
    objc_setAssociatedObject(self, @selector(ttIndicator),ttIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)ttLoadingView {
    
    return (UIView*)objc_getAssociatedObject(self, @selector(ttLoadingView));
}

- (void)setTtLoadingView:(UIView *)ttLoadingView {
    
    objc_setAssociatedObject(self, @selector(ttLoadingView),ttLoadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)ttErrorView {
    
    return (UIView*)objc_getAssociatedObject(self, @selector(ttErrorView));
}

- (void)setTtErrorView:(UIView *)ttErrorView {
    
    objc_setAssociatedObject(self, @selector(ttErrorView),ttErrorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)ttErrorToastView {
    UIView *ttErrorToastView_ = (UIView*)objc_getAssociatedObject(self, @selector(ttErrorToastView));
    if (ttErrorToastView_ && !ttErrorToastView_.superview) {
        [self addSubview:ttErrorToastView_];
    }

    return ttErrorToastView_;
}

- (void)setTtErrorToastView:(UIView *)ttErrorToastView {
    
    objc_setAssociatedObject(self, @selector(ttErrorToastView),ttErrorToastView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ttHasLoadCachedData {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(ttHasLoadCachedData));
    return [number boolValue];
}

- (void)setTtHasLoadCachedData:(BOOL)ttHasLoadCachedData {
    
    objc_setAssociatedObject(self, @selector(ttHasLoadCachedData),@(ttHasLoadCachedData), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

- (BOOL)ttNeedShowIndicator {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(ttNeedShowIndicator));
    return [number boolValue];
}

- (void)setTtNeedShowIndicator:(BOOL)ttNeedShowIndicator {
    
    objc_setAssociatedObject(self, @selector(ttNeedShowIndicator),@(ttNeedShowIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

- (BOOL)ttDisableNotifyBar {
    NSNumber *number = objc_getAssociatedObject(self, @selector(ttDisableNotifyBar));
    return [number boolValue];
}

- (void)setTtDisableNotifyBar:(BOOL)ttDisableNotifyBar {
    
    objc_setAssociatedObject(self, @selector(ttDisableNotifyBar),@(ttDisableNotifyBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

- (TTFullScreenErrorViewType)ttViewType {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(ttViewType));
    return [number integerValue];
}

- (void)setTtViewType:(TTFullScreenErrorViewType)ttViewType {
    
    objc_setAssociatedObject(self, @selector(ttViewType),@(ttViewType), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

- (UIScrollView*)ttAssociatedScrollView {
    
    return (UIScrollView*)objc_getAssociatedObject(self, @selector(ttAssociatedScrollView));
}

- (void)setTtAssociatedScrollView:(UIScrollView *)ttAssociatedScrollView {
    
    objc_setAssociatedObject(self, @selector(ttAssociatedScrollView),ttAssociatedScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)ttTargetView {
    
    return (UIView*)objc_getAssociatedObject(self, @selector(ttTargetView));
}

- (void)setTtTargetView:(UIView *)ttTargetView {
    
    objc_setAssociatedObject(self, @selector(ttTargetView),ttTargetView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)ttMessagebarHeight {
    NSNumber *number = objc_getAssociatedObject(self, @selector(ttMessagebarHeight));
    CGFloat h = [number doubleValue];
    if (h == 0) return kNotifyBarViewHeight;
    return h;
}

- (void)setTtMessagebarHeight:(CGFloat)ttMessagebarHeight {
    objc_setAssociatedObject(self, @selector(ttMessagebarHeight), @(ttMessagebarHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

-(TTCustomEmptyErrorMsgBlock)customEmptyErrorMsgBlock{
    return (TTCustomEmptyErrorMsgBlock)objc_getAssociatedObject(self, @selector(customEmptyErrorMsgBlock));
}

-(void)setCustomEmptyErrorMsgBlock:(TTCustomEmptyErrorMsgBlock)customEmptyErrorMsgBlock{
    objc_setAssociatedObject(self, @selector(customEmptyErrorMsgBlock), customEmptyErrorMsgBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TTCustomEmptyErrorImageNameBlock)customEmptyErrorImageNameBlock{
    return (TTCustomEmptyErrorImageNameBlock)objc_getAssociatedObject(self, @selector(customEmptyErrorImageNameBlock));
}

-(void)setCustomEmptyErrorImageNameBlock:(TTCustomEmptyErrorImageNameBlock)customEmptyErrorImageNameBlock{
    objc_setAssociatedObject(self, @selector(customEmptyErrorImageNameBlock), customEmptyErrorImageNameBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TTCustomFullScreenErrorViewBlock)customFullScreenErrorViewBlock{
    return (TTCustomFullScreenErrorViewBlock)objc_getAssociatedObject(self, @selector(customFullScreenErrorViewBlock));
}

- (void)setCustomFullScreenErrorViewBlock:(TTCustomFullScreenErrorViewBlock)customFullScreenErrorViewBlock{
    objc_setAssociatedObject(self, @selector(customFullScreenErrorViewBlock), customFullScreenErrorViewBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark register views
- (void)tt_registerLoadingViewWithNib:(UINib *)nib {
    
    self.ttLoadingView = [nib instantiateWithOwner:self options:nil].firstObject;
}
- (void)tt_registerLoadingViewWithClass:(Class)className {
    
    self.ttLoadingView = [[className alloc] init];
}


- (void)tt_registerErrorViewWithNib:(UINib *)nib {

    self.ttErrorView = [nib instantiateWithOwner:self options:nil].firstObject;
}

- (void)tt_registerErrorViewWithClass:(Class)className {
    self.ttErrorView = [[className alloc] init];

}

- (void)tt_registerErrorToastViewWithClass:(Class)className {
    self.ttErrorToastView = [[className alloc] init];
    
}

#pragma mark update functions

- (void)tt_startUpdate
{
    self.ttErrorView.hidden = YES;
    [self.ttIndicator stopAnimating];
    self.ttIndicator.hidden = YES;

    
    UIViewController * vc = [self valueForKey:@"_viewDelegate"];
    
    id target;
    if ([self conformsToProtocol:@protocol(UIViewControllerErrorHandler)]) {
        target = self;
    }
    else if ([vc conformsToProtocol:@protocol(UIViewControllerErrorHandler)]){
        target = vc;

    }
    else
        return;
 
    if (![target performSelector:@selector(tt_hasValidateData)]) {
        
        if (!self.ttLoadingView) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            NSArray* nibViews = [bundle loadNibNamed:@"TTFullScreenLoadingView" owner:nil options:nil];
            self.ttLoadingView = nibViews.firstObject;
        }
        
        self.ttLoadingView.frame = CGRectMake(self.ttContentInset.left, self.ttContentInset.top,self.frame.size.width - self.ttContentInset.left - self.ttContentInset.right, self.frame.size.height - self.ttContentInset.top - self.ttContentInset.bottom);
        self.ttLoadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        self.ttLoadingView.userInteractionEnabled = NO;
        
        [self addSubview: self.ttLoadingView];
        self.ttLoadingView.hidden = NO;
        [self.ttLoadingView performSelector:@selector(startLoadingAnimation)];

    }
    else if (self.ttNeedShowIndicator) {
        if (!self.ttIndicator) {
            self.ttIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        self.ttIndicator.center = CGPointMake((self.frame.size.width - self.ttContentInset.left - self.ttContentInset.right)/2, (self.frame.size.height - self.ttContentInset.top-self.ttContentInset.bottom)/2);
        self.ttIndicator.color = [[TTThemeManager sharedInstance_tt] themedColorForKey:@"TextColor3"];
        
        [self addSubview: self.ttIndicator];
        self.ttIndicator.hidden = NO;
        [self.ttIndicator startAnimating];
    }
}


- (void)tt_endUpdataData {
    
    [self.ttIndicator stopAnimating];
    self.ttIndicator.hidden = YES;

    self.ttLoadingView.hidden = YES;
    self.ttErrorView.hidden = YES;
    
    
}

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error {
    
    [self tt_endUpdataData:isCache error:error tip:nil tipTouchBlock:nil];
}

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error tip:(NSString*)tip tipTouchBlock:(TipTouchBlock)block {
    
    [self tt_endUpdataData:isCache error:error tip:tip duration:kTipDefaultDuration tipTouchBlock: block];

}

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error tip:(NSString*)tip duration:(CGFloat)duration tipTouchBlock:(TipTouchBlock)block
{
    
    self.ttAssociatedScrollView.ttHasIntegratedMessageBar = NO;

    [self.ttIndicator stopAnimating];
    self.ttIndicator.hidden = YES;

    self.ttLoadingView.hidden = YES;
    self.ttErrorView.hidden = YES;
 

    UIViewController * vc = [self valueForKey:@"_viewDelegate"];
    id target;
    if ([self conformsToProtocol:@protocol(UIViewControllerErrorHandler)]) {
        target = self;
    }
    else if ([vc conformsToProtocol:@protocol(UIViewControllerErrorHandler)]){
        target = vc;
        
    }
    else
        return;

 
    if(isCache){
        
        
        if ([target performSelector:@selector(tt_hasValidateData)] && !self.ttHasLoadCachedData) {
            
            self.ttHasLoadCachedData = YES;
           
        }
      
        
    }
    else {
        
        //处理错误
        if (error) {
            
            if (!self.ttDisableNotifyBar && [target performSelector:@selector(tt_hasValidateData)]){
                
                self.ttAssociatedScrollView.ttHasIntegratedMessageBar = YES;
                
                if (!self.ttErrorToastView) {
                    
                    NSLog(@"ttErrorToastView is nil");
                    return;
                    
                }
                self.ttErrorToastView.frame = CGRectMake(self.ttContentInset.left,self.ttContentInset.top, self.width - self.ttContentInset.left - self.ttContentInset.right, self.ttMessagebarHeight);
                [self addSubview:self.ttErrorToastView];


                __weak typeof(self) wself = self;

                [(UIView<ErrorToastProtocal> *)self.ttErrorToastView showMessage:[self errorMsgFromNSError:error] actionButtonTitle:nil delayHide:kTipDefaultDuration == kTipDurationInfinite? NO:YES duration:kTipDefaultDuration bgButtonClickAction:^(UIButton* btn){
                    
                    if (block) {
                        block();
                    }
                    if (duration != kTipDurationInfinite) {
                        [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
                        
                    }

                } actionButtonClickBlock:^(UIButton *button) {
                    
                    [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
                    
                }  didHideBlock:^(id barView) {
                    [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
                }];
                
                if(duration>0)
                {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetMessageBarInset) object:nil];
                    [self performSelector:@selector(resetMessageBarInset) withObject:nil afterDelay:duration];
                }

                
                if ([target respondsToSelector:@selector(handleError:)]) {
                    
                    [target performSelector:@selector(handleError:) withObject:error];
                }
                
            }
            else {
                
                if (!self.ttErrorView) {
                    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
                    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                    NSArray* nibViews = [bundle loadNibNamed:@"TTFullScreenErrorView" owner:nil options:nil];
                    self.ttErrorView = nibViews.firstObject;
                }
                self.ttErrorView.frame = CGRectMake(self.ttContentInset.left,self.ttContentInset.top,self.frame.size.width - self.ttContentInset.left - self.ttContentInset.right, self.frame.size.height - self.ttContentInset.top - self.ttContentInset.bottom);
                
                self.ttErrorView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                if (self.ttTargetView) {
                    
//                    self.ttErrorView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
                    [self.ttTargetView addSubview: self.ttErrorView];
                }
                else {
                    [self addSubview: self.ttErrorView];
                }
                
                //自定设置必须在setViewType前
                self.ttErrorView.customEmptyErrorMsgBlock = self.customEmptyErrorMsgBlock;
                self.ttErrorView.customEmptyErrorImageNameBlock = self.customEmptyErrorImageNameBlock;
                self.ttErrorView.customFullScreenErrorViewBlock = self.customFullScreenErrorViewBlock;
                self.ttErrorView.viewType = [self errorViewTypeFromNSError:error];
                
                switch (self.ttErrorView.viewType) {
                    case TTFullScreenErrorViewTypeNetWorkError:
                    {
                        if ([target respondsToSelector:@selector(refreshData)]) {
                            [((TTFullScreenErrorView*)self.ttErrorView).refreshButton addTarget:target action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                        break;
                    case TTFullScreenErrorViewTypeSessionExpired:
                    {
                        if ([target respondsToSelector:@selector(sessionExpiredAction)]) {
                        
                            [((TTFullScreenErrorView*)self.ttErrorView).actionBtn addTarget:target action:@selector(sessionExpiredAction) forControlEvents:UIControlEventTouchUpInside];

                        }

                    }
                        break;
                        
                    default:
                    {
                        
                        if ([target respondsToSelector:@selector(refreshData)]) {
                            [((TTFullScreenErrorView*)self.ttErrorView).refreshButton addTarget:target action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
                        }

                    }
                        break;
                }
                
                
                self.ttErrorView.hidden = NO;
            }

        }//如果没有错误 看看需不需要加入空白页
        else {
            
            if (tip.length > 0 && !self.ttDisableNotifyBar && [target performSelector:@selector(tt_hasValidateData)]){
                
                self.ttAssociatedScrollView.ttHasIntegratedMessageBar = YES;
                
                if (!self.ttErrorToastView) {
                    
                    NSLog(@"ttErrorToastView is nil");
                    return;
                    
                }
                self.ttErrorToastView.frame = CGRectMake(self.ttContentInset.left,self.ttContentInset.top, self.width - self.ttContentInset.left - self.ttContentInset.right, self.ttMessagebarHeight);
                [self addSubview:self.ttErrorToastView];
                
                
                __weak typeof(self) wself = self;
                
                [(UIView<ErrorToastProtocal> *)self.ttErrorToastView showMessage:tip actionButtonTitle:nil delayHide:kTipDefaultDuration == kTipDurationInfinite? NO:YES duration:kTipDefaultDuration bgButtonClickAction:^(UIButton* btn){
                    
                    if (block) {
                        block();
                    }
                    if (duration != kTipDurationInfinite) {
                        [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
                        
                    }
                    
                } actionButtonClickBlock:^(UIButton *button) {
                    
                    [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
                    
                }  didHideBlock:^(id barView) {
                    [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
                }];
                
                if(duration>0)
                {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetMessageBarInset) object:nil];
                    [self performSelector:@selector(resetMessageBarInset) withObject:nil afterDelay:duration];
                }
                
                
                if ([target respondsToSelector:@selector(handleError:)]) {
                    
                    [target performSelector:@selector(handleError:) withObject:error];
                }
                
            } else if (![target performSelector:@selector(tt_hasValidateData)]){
            
                if (!self.ttErrorView) {
                    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
                    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                    NSArray* nibViews = [bundle loadNibNamed:@"TTFullScreenErrorView" owner:nil options:nil];
                    self.ttErrorView = nibViews.firstObject;
                }

                self.ttErrorView.frame = CGRectMake(self.ttContentInset.left,self.ttContentInset.top,self.frame.size.width - self.ttContentInset.left - self.ttContentInset.right, self.frame.size.height - self.ttContentInset.top - self.ttContentInset.bottom);
                
                self.ttErrorView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                if (self.ttTargetView) {
                    
                    self.ttErrorView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
                    [self.ttTargetView addSubview: self.ttErrorView];
                }
                else {
                    [self addSubview: self.ttErrorView];
                }
                
                //自定设置必须在setViewType前
                self.ttErrorView.customEmptyErrorMsgBlock = self.customEmptyErrorMsgBlock;
                self.ttErrorView.customEmptyErrorImageNameBlock = self.customEmptyErrorImageNameBlock;
                self.ttErrorView.customFullScreenErrorViewBlock = self.customFullScreenErrorViewBlock;
                self.ttErrorView.viewType = self.ttViewType;
                
                if ([target respondsToSelector:@selector(emptyViewBtnAction)]) {
                    
                    [((TTFullScreenErrorView*)self.ttErrorView).actionBtn addTarget:target action:@selector(emptyViewBtnAction) forControlEvents:UIControlEventTouchUpInside];

                }
                
                self.ttErrorView.hidden = NO;
                
            }

        }
    }
    
}

- (void)tt_ShowTip:(NSString*)tip duration:(CGFloat)duration tipTouchBlock:(TipTouchBlock)block {
    
    if (!self.ttErrorToastView) {
        
        NSLog(@"ttErrorToastView is nil");
        return;
        
    }
    self.ttAssociatedScrollView.ttHasIntegratedMessageBar = YES;
    
    self.ttErrorToastView.frame = CGRectMake(self.ttContentInset.left,self.ttContentInset.top, self.width - self.ttContentInset.left - self.ttContentInset.right, self.ttMessagebarHeight);
    [self addSubview:self.ttErrorToastView];

    __weak typeof(self) wself = self;

    [(UIView<ErrorToastProtocal> *)self.ttErrorToastView showMessage:NSLocalizedString(tip,nil) actionButtonTitle:nil delayHide: duration == kTipDurationInfinite? NO:YES duration:duration bgButtonClickAction:^(UIButton* btn){
        
        if (block) {
            block();
        }

        [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
        

    } actionButtonClickBlock:^(UIButton *button) {

        [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
        
    }  didHideBlock:^(id barView) {
        [wself.ttAssociatedScrollView.pullDownView messageBarResetContentInset];
    }];
    
    
    if(duration>0)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetMessageBarInset) object:nil];
        [self performSelector:@selector(resetMessageBarInset) withObject:nil afterDelay:duration];
    }

 
}

- (void)resetMessageBarInset {
    
    [self.ttAssociatedScrollView.pullDownView messageBarResetContentInset];

}
 

#pragma  helper
-(NSString *)errorMsgFromNSError:(NSError*)error
{
    if (error.userInfo[@"description"]) {
        return error.userInfo[@"description"];
    }
    return NSLocalizedString(@"网络不给力，请稍后重试",nil);
}

-(TTFullScreenErrorViewType)errorViewTypeFromNSError:(NSError*)error
{
    //如果是自定义的，直接返回
    if (self.ttViewType == TTFullScreenErrorViewTypeCustomView) {
        return TTFullScreenErrorViewTypeCustomView;
    }
    
    if (error.code == kMissingSessionKeyErrorCode || error.code == kSessionExpiredErrorCode)
    {
        return TTFullScreenErrorViewTypeSessionExpired;
    }
    
    return TTFullScreenErrorViewTypeNetWorkError;
}
@end
