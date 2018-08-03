//
//  EssayHDRecommendView.h
//  Essay
//
//  Created by 于天航 on 12-9-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSFlipContainerView.h"
#import "SSTitleBarView.h"

@interface PadWebView : SSFlipContainerView {
}

@property (nonatomic, retain) SSTitleBarView *titleBar;

@property (nonatomic, assign) id closeTarget;
@property (nonatomic, assign) SEL closeSelector;
@property (nonatomic, retain, readonly) UIButton *hdBackButton;
- (void)startLoadURL:(NSURL*)url;
@end
