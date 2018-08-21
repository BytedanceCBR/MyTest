//
//  SSWebViewWrapper.h
//  Article
//
//  Created by Chen Hong on 15/11/4.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
// iPad上webView页两边留白处理，将留白处的滚动事件传递到webView上

@interface TTViewWrapper : SSThemedView

+ (instancetype)viewWithFrame:(CGRect)frame targetView:(UIView *)targetView;

@property(nonatomic, strong)UIView *targetView;

@end
