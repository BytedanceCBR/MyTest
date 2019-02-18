//
//  FHMessageCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import <UIKit/UIKit.h>
#import "FHUnreadMsgModel.h"
#import "TTBadgeNumberView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageCell : UITableViewCell

@property(nonatomic, strong) TTBadgeNumberView *unreadView;

- (void)updateWithModel:(FHUnreadMsgDataUnreadModel *)model;

@end

NS_ASSUME_NONNULL_END
