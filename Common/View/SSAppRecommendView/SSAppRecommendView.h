//
//  SSAppRecommendView.h
//  Essay
//
//  Created by Dianwei on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@interface SSAppRecommendView : SSViewBase

- (void)startGetAppInfo;
- (void)setRecommendButtonTarget:(id)target selector:(SEL)selector;
- (void)closeWebView;
@end
