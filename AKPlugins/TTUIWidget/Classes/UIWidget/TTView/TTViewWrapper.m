//
//  SSWebViewWrapper.m
//  Article
//
//  Created by Chen Hong on 15/11/4.
//
//

#import "TTViewWrapper.h"
#import "UIColor+TTThemeExtension.h"

@implementation TTViewWrapper

+ (instancetype)viewWithFrame:(CGRect)frame targetView:(UIView *)targetView {
    TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:frame];
    [wrapperView addSubview:targetView];
    wrapperView.targetView = targetView;
    return wrapperView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    
    [super themeChanged:notification];
    if (!self.backgroundColorThemeKey) {
        self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    }
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.targetView) {
        return [super hitTest:point withEvent:event];
    }
    
    if (CGRectContainsPoint(self.targetView.frame, point)) {
        return [super hitTest:point withEvent:event];
    }
    
    // 不管是左边还是右边，如果超出区域都截断到1px
    CGPoint webViewPoint = [self convertPoint:point toView:self.targetView];
    if (webViewPoint.x < 0) {
        webViewPoint.x = 1;
    }
    else if (webViewPoint.x >= self.targetView.bounds.size.width) {
        webViewPoint.x = self.targetView.bounds.size.width - 1;
    }
    
    return [self.targetView hitTest:webViewPoint withEvent:event];
}


@end
