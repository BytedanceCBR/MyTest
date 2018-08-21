//
//  SSRecommendWebView.h
//  Essay
//
//  Created by Dianwei on 12-9-6.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@interface SSRecommendWebView : SSViewBase

- (void)startLoadWithURL:(NSURL*)url;
- (void)show;
- (void)close;
@end
