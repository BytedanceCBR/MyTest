//
//  TTLiveCellBaseContentView.h
//  TTLive
//
//  Created by matrixzk on 3/30/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTLabel.h"

@class TTLiveMessage;

@interface TTLiveCellMetaInfoView : UIView
- (void)setupInfoWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming;
@end


@interface TTLiveCellMetaTextView : TTLabel
@end


@interface TTLiveCellBaseContentView : SSThemedView

@property (nonatomic, strong, readonly) TTLiveCellMetaInfoView *topInfoView;
@property (nonatomic, strong, readonly) TTLiveMessage *message;
@property (nonatomic, assign, readonly) BOOL isIncomingMsg;
@property (nonatomic, assign, readonly) BOOL isReplyedMsg;

/// NOTE: must call `super`.
- (void)showContentWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming;

@end
