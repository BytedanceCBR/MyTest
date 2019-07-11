//
//  TTFeedDislikeContentPopoverView.h
//  Bytedancebase-BDOpenSDK
//
//  Created by 曾凯 on 2018/7/13.
//

#import <UIKit/UIKit.h>
#import "FHFeedOperationOption.h"

extern NSString *const FeedDislikeNeedReportNotification;

@class TTFeedDislikeKeywordSelectorView;

@interface TTFeedDislikeKeywordSelectorView : UIView
@property (nonatomic, copy) void (^selectionFinished)(FHFeedOperationWord *keyword);
- (void)refreshWithOption:(FHFeedOperationOption *)option;
@end
