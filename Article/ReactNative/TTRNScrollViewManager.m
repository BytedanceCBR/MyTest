//
//  TTRNScrollViewManager.m
//  Article
//
//  Created by yin on 2017/7/27.
//
//

#import "TTRNScrollViewManager.h"
#import "TTRNScrollView.h"

@implementation TTRNScrollViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    TTRNScrollView *scrollView = [[TTRNScrollView alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
    return scrollView;
}

RCT_EXPORT_VIEW_PROPERTY(scrollList, NSArray)

@end
