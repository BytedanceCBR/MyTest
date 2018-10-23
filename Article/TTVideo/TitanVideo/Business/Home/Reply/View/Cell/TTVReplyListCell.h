//
//  TTVReplyListCell.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVReplyListItem.h"

extern NSString *const kTTVReplyListCellIdentifier;

@protocol TTVReplyListCellDelegate <NSObject>

@optional

- (void)replyListCell:(UITableViewCell *)view replyButtonClickedWithModel:(id <TTVReplyModelProtocol>)model;
- (void)replyListCell:(UITableViewCell *)view avatarTappedWithModel:(id <TTVReplyModelProtocol>)model;
- (void)replyListCell:(UITableViewCell *)view deleteCommentWithModel:(id <TTVReplyModelProtocol>)model;
- (void)replyListCell:(UITableViewCell *)view digCommentWithModel:(id <TTVReplyModelProtocol>)model;
- (void)replyListCell:(UITableViewCell *)view nameViewonClickedWithModel:(id <TTVReplyModelProtocol>)model;
- (void)replyListCell:(UITableViewCell *)view quotedNameOnClickedWithModel:(id <TTVReplyModelProtocol>)model;
@end


@interface TTVReplyListCell : TTVTableViewCell
@property (nonatomic, weak) id<TTVReplyListCellDelegate> delegate;
@property (nonatomic, assign) BOOL impressionShown;

@property (nonatomic, strong) TTVReplyListItem *item;

@end
