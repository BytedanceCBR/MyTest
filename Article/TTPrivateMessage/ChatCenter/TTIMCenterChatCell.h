//
//  TTIMCenterChatCell.h
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTIMChatCenterModel;
@protocol TTIMChatCenterCellDelegate <NSObject>
@optional
- (void)ttimChatCenterDeleteChat:(TTIMChatCenterModel *)chatCenterModel; // 删除
- (void)ttimChatCenterStickChat:(TTIMChatCenterModel *)chatCenterModel;  // 置顶
@end


@interface TTIMCenterChatCell : UITableViewCell
@property (nonatomic, weak) id<TTIMChatCenterCellDelegate> delegate;

- (void)setUnreadNumber:(NSUInteger)number;
- (void)setupCellWithModel:(TTIMChatCenterModel *)model;

@end
