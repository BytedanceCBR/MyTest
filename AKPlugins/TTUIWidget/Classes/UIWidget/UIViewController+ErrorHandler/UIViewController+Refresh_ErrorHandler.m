//
//  UIViewController+Refresh_ErrorHandler.m
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTFullScreenLoadingView.h"
#import "TTFullScreenErrorView.h"
#import "UIView+Refresh_ErrorHandler.h"

@import ObjectiveC;


@implementation UIViewController (Refresh_ErrorHandler)



- (UIEdgeInsets)ttContentInset {
    
    return self.view.ttContentInset;
}

- (void)setTtContentInset:(UIEdgeInsets)ttContentInset {
    
    [self.view setTtContentInset:ttContentInset];
}


- (UIView*)ttLoadingView {
    
    return [self.view ttLoadingView];
}

- (void)setTtLoadingView:(UIView *)ttLoadingView {
    
    [self.view setTtLoadingView:ttLoadingView];
}

- (UIView*)ttErrorView {
    
    return [self.view ttErrorView];
}

- (void)setTtErrorView:(UIView *)ttErrorView {
    
    [self.view setTtErrorView:(UIView <ErrorViewProtocal> *)ttErrorView];
}

- (UIView*)ttErrorToastView {
    
    return self.view.ttErrorToastView;
}

- (void)setTtErrorToastView:(UIView<ErrorToastProtocal> *)ttErrorToastView {
    
    [self.view setTtErrorToastView:ttErrorToastView];
}

- (UIView*)ttTargetView {
    
    return self.view.ttTargetView;
}

- (void)setTtTargetView:(UIView *)ttView {
    
    [self.view setTtTargetView:ttView];
}

- (BOOL)ttHasLoadCachedData {
    
    return self.view.ttHasLoadCachedData;
}

- (void)setTtHasLoadCachedData:(BOOL)ttHasLoadCachedData {
    
    [self.view setTtHasLoadCachedData:ttHasLoadCachedData];
}

- (BOOL)ttNeedShowIndicator {
    
    return self.view.ttNeedShowIndicator;
}

- (void)setTtNeedShowIndicator:(BOOL)ttNeedShowIndicator {
    
    [self.view setTtNeedShowIndicator:ttNeedShowIndicator];
}

- (TTFullScreenErrorViewType)ttViewType {
    
    return [self.view ttViewType];
}

- (void)setTtViewType:(TTFullScreenErrorViewType)ttViewType {
    
    [self.view setTtViewType:ttViewType];
}

- (TTCustomEmptyErrorMsgBlock)customEmptyErrorMsgBlock{
    return [self.view customEmptyErrorMsgBlock];
}

- (void)setCustomEmptyErrorMsgBlock:(TTCustomEmptyErrorMsgBlock)customEmptyErrorMsgBlock{
    [self.view setCustomEmptyErrorMsgBlock:customEmptyErrorMsgBlock];
}

- (TTCustomEmptyErrorImageNameBlock)customEmptyErrorImageNameBlock{
    return [self.view customEmptyErrorImageNameBlock];
}

- (void)setCustomEmptyErrorImageNameBlock:(TTCustomEmptyErrorImageNameBlock)customEmptyErrorImageNameBlock{
    [self.view setCustomEmptyErrorImageNameBlock:customEmptyErrorImageNameBlock];
}

- (TTCustomFullScreenErrorViewBlock)customFullScreenErrorViewBlock{
    return [self.view customFullScreenErrorViewBlock];
}

- (void)setCustomFullScreenErrorViewBlock:(TTCustomFullScreenErrorViewBlock)customFullScreenErrorViewBlock{
    [self.view setCustomFullScreenErrorViewBlock:customFullScreenErrorViewBlock];
}

- (void)tt_registerLoadingViewWithNib:(UINib *)nib {
    
    self.view.ttLoadingView = [nib instantiateWithOwner:self options:nil].firstObject;
}
- (void)tt_registerLoadingViewWithClass:(Class)className {
    
    self.view.ttLoadingView = [[className alloc] init];
}


- (void)tt_registerErrorViewWithNib:(UINib *)nib {

    self.view.ttErrorView = [nib instantiateWithOwner:self options:nil].firstObject;
}

- (void)tt_registerErrorViewWithClass:(Class)className {
    self.view.ttErrorView = [[className alloc] init];

}

- (void)tt_registerErrorToastViewWithClass:(Class)className {
    self.view.ttErrorToastView = [[className alloc] init];
    
}


- (void)tt_startUpdate
{
    [self.view tt_startUpdate];
}


- (void)tt_endUpdataData {
    
    [self.view tt_endUpdataData];
}

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error {
    
    [self.view tt_endUpdataData:isCache error:error];
}

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error tip:(NSString*)tip tipTouchBlock:(TipTouchBlock)block
{
    [self.view tt_endUpdataData:isCache error:error tip:tip tipTouchBlock:block];
}

- (void)tt_ShowTip:(NSString*)tip duration:(CGFloat)duration tipTouchBlock:(TipTouchBlock)block {
    
    [self.view tt_ShowTip:tip duration:duration tipTouchBlock:block];
    
}

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error tip:(NSString*)tip duration:(CGFloat)duration tipTouchBlock:(TipTouchBlock)block {
    [self.view tt_endUpdataData:isCache error:error tip:tip duration:duration tipTouchBlock:block];

}

@end
