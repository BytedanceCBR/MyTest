//
//  FHMessageCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import <UIKit/UIKit.h>
#import "FHUnreadMsgModel.h"
#import "TTBadgeNumberView.h"
#import "IMConversation.h"
#import "FHMessageEditView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FHMessageCellClick)(id data);

@interface FHMessageCell : UITableViewCell

@property(nonatomic, strong) TTBadgeNumberView *unreadView;
@property (nonatomic, assign) SliderMenuState state;
@property (nonatomic, copy) FHMessageCellClick deleteConversation;
@property (nonatomic, copy) FHMessageCellClick stateIsClose;
@property (nonatomic, copy) FHMessageCellClick openEditTrack;
@property (nonatomic, copy) FHMessageCellClick closeEditTrack;
@property (nonatomic, strong) IMConversation *conv;

- (void)updateWithModel:(FHUnreadMsgDataUnreadModel *)model;
- (void)updateWithChat:(IMConversation*)conversation;
-(void)displaySendState:(ChatMsg *)msg;
- (void)initGestureWithData:(id)data index:(NSInteger)index;
- (void)close;
- (void)initGesture;
@end

NS_ASSUME_NONNULL_END
