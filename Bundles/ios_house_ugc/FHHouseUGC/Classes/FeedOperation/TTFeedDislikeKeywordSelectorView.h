//
//  TTFeedDislikeContentPopoverView.h
//  Bytedancebase-BDOpenSDK
//
//  Created by 曾凯 on 2018/7/13.
//

#import <UIKit/UIKit.h>
#import "TTFeedDislikeOption.h"

extern NSString *const FeedDislikeNeedReportNotification;

@class TTFeedDislikeKeywordSelectorView;

@interface TTFeedDislikeKeywordSelectorView : UIView
@property (nonatomic, copy) void (^selectionFinished)(TTFeedDislikeWord *keyword);
- (void)refreshWithOption:(TTFeedDislikeOption *)option;
@end
