//
//  FHMessageCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"
#import "UIImageView+BDWebImage.h"
#import "TTAccount.h"
#import "FHChatUserInfoManager.h"
#import <TTRichSpanText.h>
#import <TIMOMessage.h>
#import <TIMMessageStoreBridge.h>

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface FHMessageCell()

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIImageView *msgStateView;

@end

@implementation FHMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs
{
    [self initViews];
    [self initConstraints];
}

- (void)initViews
{
    self.iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:_iconView];
    _iconView.layer.masksToBounds = YES;
    _iconView.layer.cornerRadius = 27;
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.msgStateView = [[UIImageView alloc] init];
    [self.contentView addSubview:_msgStateView];
    self.msgStateView.hidden = YES;
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_subTitleLabel];
    
    self.timeLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_timeLabel];
    
    self.unreadView = [[TTBadgeNumberView alloc] init];
    self.unreadView.badgeNumberPointSize = 12;
    _unreadView.badgeViewStyle = TTBadgeNumberViewStyleDefaultWithBorder;
    [self.contentView addSubview:_unreadView];
}

- (void)initConstraints
{
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.bottom.mas_equalTo(-14);
        make.width.height.mas_equalTo(54);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(19);
        make.right.mas_equalTo(-100);
        make.top.mas_equalTo(self.iconView.mas_top).offset(3);
        make.height.mas_equalTo(22);
    }];
    
    [self.msgStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(20);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.height.mas_equalTo(17);
    }];
    
    [self.unreadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.iconView.mas_right);
        make.top.mas_equalTo(self.iconView.mas_top);
    }];
}

-(void)displaySendState:(ChatMsg *)msg {
    if (msg.type == ChatMstTypeNotice) {
        [self.msgStateView setHidden:YES];
        [self updateLayoutForMsgState:ChatMsgStateSuccess];
    } else if (msg.state == ChatMsgStateFail) {
        [self.msgStateView setImage:[UIImage imageNamed:@"chat_state_fail_ic"]];
        [self.msgStateView setHidden:NO];
        [self updateLayoutForMsgState:msg.state];
    } else if (msg.state == ChatMsgStateSending) {
        [self.msgStateView setImage:[UIImage imageNamed:@"chat_state_message_sending_ic"]];
        [self.msgStateView setHidden:NO];
        [self updateLayoutForMsgState:msg.state];
    } else {
        [self.msgStateView setHidden:YES];
        [self updateLayoutForMsgState:msg.state];
    }
}

-(void)updateLayoutForMsgState:(ChatMsgState)state
{
    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (state != ChatMsgStateSuccess) {
            make.left.mas_equalTo(self.titleLabel.mas_left).offset(16);
        } else {
            make.left.mas_equalTo(self.titleLabel.mas_left);
        }
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(20);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return label;
}

- (void)updateWithModel:(FHUnreadMsgDataUnreadModel *)model
{
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.content;
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:[model.timestamp doubleValue]];
    self.timeLabel.text = [self timeLabelByDate:date];
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:model.icon] placeholder:[UIImage imageNamed:@"default_image"]];
    self.unreadView.badgeNumber = [model.unread integerValue] == 0 ? TTBadgeNumberHidden : [model.unread integerValue];
    if(!_msgStateView.hidden){
        //im 复用cell
        self.msgStateView.hidden = YES;
        [self updateLayoutForMsgState:ChatMsgStateSuccess];
    }
}

- (void)updateWithChat:(IMConversation*)conversation {
    IMConversation* conv = conversation;
    if (conv.mute) {
        if (conv.unreadCount > 0) {
            self.unreadView.badgeNumber = TTBadgeNumberPoint;
        } else {
            self.unreadView.badgeNumber = 0;
        }
    } else {
        self.unreadView.badgeNumber = conv.unreadCount;
    }
    BOOL isGroupChat = (conv.type == IMConversationTypeGroupChat);
    ChatMsg *lastMsg = [conv lastChatMsg];
    
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:conv.icon] placeholder:[UIImage imageNamed:isGroupChat ? @"chat_group_icon_default" : @"chat_business_icon_c"]];

    self.titleLabel.text = conv.conversationDisplayName;
    if (isEmptyString(conv.conversationDisplayName)) {
        NSString *targetUserId = [conv getTargetUserId:[[TTAccount sharedAccount] userIdString]];
        self.titleLabel.text = [[FHChatUserInfoManager shareInstance] getUserInfo:targetUserId].username;
    }
    TTRichSpanText *richSpanTextDraft = [[TTRichSpanText alloc] initWithBase64EncodedString:[conv getDraft]];
    NSString *draftText = richSpanTextDraft.text;
    if (!isEmptyString(draftText)) {
        self.subTitleLabel.attributedText = [self getDraftAttributeString:draftText];
    } else {
        if(lastMsg.isRecalled) {
            NSString *recallHintText = @"撤回了一条消息";
            __block NSString *roleHintText = @"";
            
            BOOL recallUserIsOwner = (lastMsg.recalledUid == conv.owner.userId.longLongValue);
            BOOL recallMsgSenderIsOwner = (lastMsg.userId == conv.owner.userId.longLongValue);
        
            if(lastMsg.isCurrentUser) {
                if(recallUserIsOwner && !recallMsgSenderIsOwner) {
                    roleHintText = @"群主";
                } else{
                    roleHintText = @"你";
                }
            } else {
                if(recallUserIsOwner && !recallMsgSenderIsOwner) {
                    roleHintText = @"群主";
                } else {
                    [[FHChatUserInfoManager shareInstance] getUserInfoSync:[[NSNumber numberWithLongLong:lastMsg.userId] stringValue] block:^(NSString * _Nonnull userId, FHChatUserInfo * _Nonnull userInfo) {
                        roleHintText = userInfo.username;
                    }];
                }
            }
            self.subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", roleHintText, recallHintText];
        }
        else if (isGroupChat) {
            NSString *cutStr = [self cutLineBreak:[conv lastMessage]];
            NSNumber *uid =[NSNumber numberWithLongLong: [[[TTAccount sharedAccount] userIdString] longLongValue]];
            if (lastMsg.isCurrentUser || lastMsg.type == ChatMstTypeNotice) {
                if ([lastMsg.mentionedUsers containsObject:uid] && ![self lastMsgHasReadInConversation:conv]) {
                    self.subTitleLabel.attributedText = [self getAtAttributeString:cutStr];;
                } else {
                    self.subTitleLabel.text = cutStr;
                }
            } else {
                [[FHChatUserInfoManager shareInstance] getUserInfoSync:[[NSNumber numberWithLongLong:lastMsg.userId] stringValue] block:^(NSString * _Nonnull userId, FHChatUserInfo * _Nonnull userInfo) {
                    NSString *tipMsg = [NSString stringWithFormat:@"%@: %@", userInfo.username, cutStr];
                    if ([lastMsg.mentionedUsers containsObject:uid] && ![self lastMsgHasReadInConversation:conv]) {
                        self.subTitleLabel.attributedText = [self getAtAttributeString:tipMsg];;
                    } else {
                         self.subTitleLabel.text = tipMsg;
                    }
                }];
            }
        } else {
            self.subTitleLabel.text = [self cutLineBreak:[conv lastMessage]];
        }
    }
    

    [self displaySendState:lastMsg];
    self.timeLabel.text = [self timeLabelByDate:conv.updatedAt];
}

-(BOOL)lastMsgHasReadInConversation:(IMConversation *)conv {
    return conv.unreadCount == 0; // 会话的未读数为0时即为最后一条消息已读状态
}

-(NSAttributedString*)getDraftAttributeString:(NSString*)draft {

    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@", [self cutLineBreak:draft]]];
    NSRange theRange = NSMakeRange(0, 4);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;

    NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                 NSForegroundColorAttributeName : [UIColor redColor] ,
                                                 NSParagraphStyleAttributeName : paragraphStyle};
    [attrStr addAttributes:attributes range:theRange];
    return attrStr;
}

-(NSAttributedString*)getAtAttributeString:(NSString*)draft {
    
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[有人@你]%@", [self cutLineBreak:draft]]];
    NSRange theRange = NSMakeRange(0, 6);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                 NSForegroundColorAttributeName : [UIColor themeRed3] ,
                                                 NSParagraphStyleAttributeName : paragraphStyle};
    [attrStr addAttributes:attributes range:theRange];
    return attrStr;
}

-(NSString*)cutLineBreak:(NSString*)content {
    int length = 0;
    while (length != content.length) {
        length = content.length;
        content = [self cutLineBreak2:content];
        content = [self cutLineBreak3:content];
    }
    return content;
}

- (NSString*)cutLineBreak2:(NSString *)content {
    NSRange range2 = [content rangeOfString:@"\n"];
    if (range2.location == 0 && content.length > 1) {
        return [NSString stringWithFormat:@" %@", [self cutLineBreak:[content substringFromIndex:range2.location + 1]]];
    } else {
        return content;
    }
}

- (NSString*)cutLineBreak3:(NSString *)content {
    NSRange range = [content rangeOfString:@"\r"];
    if (range.location == 0 && content.length > 1) {
        return [NSString stringWithFormat:@" %@", [self cutLineBreak:[content substringFromIndex:range.location + 1]]];
    } else {
        return content;
    }
}


-(NSString*)timeLabelByDate:(NSDate*)date {
    NSDateComponents* components = [CURRENT_CALENDAR components:NSCalendarUnitCalendar fromDate:[NSDate new]];
    components.day = components.day - 7;
    NSDate* dayTimeInOneWeek = [CURRENT_CALENDAR dateFromComponents:components];
    if ([CURRENT_CALENDAR isDateInToday:date]) {
        return [self shortTimeLabel:date];
    } else if([CURRENT_CALENDAR isDateInYesterday:date]) {
        return [self timeWithYesterdayTime:date];
    } else if([self isThisYear:date]) {
        return [self shortDayLabel:date];
    } else {
        return [self longTimeLabel:date];
    }
}

-(NSString*)shortTimeLabel:(NSDate*)date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:date];
}

-(NSString*)shortDayLabel:(NSDate*)date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd";
    return [formatter stringFromDate:date];
}

-(NSString*)timeWithYesterdayTime:(NSDate*)date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";

    return [NSString stringWithFormat:@"昨天 %@", [formatter stringFromDate:date]];
}

-(NSString*)longTimeLabel:(NSDate*)date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy/MM/dd";
    return [formatter stringFromDate:date];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate ofDate:(NSDate*)date
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:date];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}


- (BOOL)isThisYear:(NSDate*)date
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date] ofDate:date];
}


@end
