//
//  TTIMMessageCell.h
//  EyeU
//
//  Created by matrixzk on 10/20/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTIMMessage;

@protocol TTIMMessageCellEventDelegate <NSObject>
@optional
- (void)ttimMessageCellAvatarDidTapped:(TTIMMessage *)message;
- (void)ttimMessageCellImageDidTapped:(TTIMMessage *)message convertedFrame:(CGRect)convertedFrame;
- (void)ttimMessageCellVideoDidTapped:(TTIMMessage *)message convertedFrame:(CGRect)convertedFrame;
- (void)ttimMessageCellMagicExpressionDidTapped:(TTIMMessage *)message;
- (void)ttimMessageCellHandleResendEvent:(TTIMMessage *)message;
// 单条对话长按举报事件
- (void)ttimMessageCellHandleReportEvent:(TTIMMessage *)message;
// 单条对话长按拉黑事件
- (void)ttimMessageCellHandleBlockEvent:(TTIMMessage *)message;
// 单条对话点击超链接事件
- (void)ttimMessageCellHandleLinkEvent:(TTIMMessage *)message URL:(NSURL *)URL;
- (void)ttimMessageCellTapped;
@end

@interface TTIMMessageCell : UITableViewCell

@property (nonatomic, weak) id<TTIMMessageCellEventDelegate> delegate;

- (void)setupCellWithMessage:(TTIMMessage *)message;

/// CellReuseIdentifier
+ (NSString *)TTIMIncomingTextCellReuseIdentifier;
+ (NSString *)TTIMOutgoingTextCellReuseIdentifier;
+ (NSString *)TTIMIncomingMediaCellReuseIdentifier;
+ (NSString *)TTIMOutgoingMediaCellReuseIdentifier;

@end
