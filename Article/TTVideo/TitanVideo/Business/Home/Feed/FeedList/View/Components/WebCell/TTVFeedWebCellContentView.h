//
//  TTVFeedWebCellContentView.h
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "TTVFeedListWebItem.h"

#define kTTVWebCellDidUpdateNotification @"com.bytedance.kTTVWebCellDidUpdateNotification"

@interface TTVFeedWebCellContentView : SSViewBase

@property (nonatomic, strong) TTVFeedListWebItem *webItem;

+ (CGFloat)obtainHeightForFeed:(TTVFeedListWebItem *)cellEntity cellWidth:(CGFloat)width;

@end
