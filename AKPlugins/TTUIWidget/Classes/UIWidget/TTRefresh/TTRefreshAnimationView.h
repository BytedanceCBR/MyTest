//
//  ZDLoadingView.h
//  PullToRefreshControlDemo
//
//  Created by Nick Yu on 12/26/13.
//  Copyright (c) 2013 Zhang Kai Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRefreshView.h"
#import "SSThemed.h"

@interface TTRefreshAnimationView : UIView

@property (nonatomic,assign) CGFloat percent;
 
- (void)startLoading;
- (void)stopLoading;

@end

@interface TTRefreshAnimationContainerView : SSThemedView<TTRefreshAnimationDelegate>

-(id)initWithFrame:(CGRect)frame WithLoadingHeight:(CGFloat)loadingHeight WithinitText:(NSString *)initText WithpullText:(NSString *)pullText
   WithloadingText:(NSString *)loadingText WithnoMoreText:(NSString *)noMoreText;

@end
