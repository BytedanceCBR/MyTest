//
//  TTWechatTimelineActivity.h
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTActivityProtocol.h"
#import "TTWechatTimelineContentItem.h"

extern NSString * const TTActivityTypePostToWechatTimeline;

@interface TTWechatTimelineActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTWechatTimelineContentItem *contentItem;

@end
