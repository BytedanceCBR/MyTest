//
//  FHMessageCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import "UIImageView+BDWebImage.h"
#import "TTAccount.h"
#import "FHChatUserInfoManager.h"
#import "TTRichSpanText.h"
#import "TIMOMessage.h"
#import "TIMMessageStoreBridge.h"
#import "FHShadowLabel.h"
#import "FHMessageEditView.h"
#import <Heimdallr/HMDTTMonitor.h>
#import "ByteDanceKit.h"
#import "IMManager.h"
#import "FHMessageCellTagsView.h"
#import "FIMDebugManager+Utils.h"
#import "TTSandBoxHelper.h"

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface FHMessageCell()

@property(nonatomic, strong) UIView *backView;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UIImageView *iconCoverView;// 关黑经纪人提示视图
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *scoreLabel;
@property(nonatomic, strong) FHMessageCellTagsView *tagsView;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIImageView *msgStateView;
@property(nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic) BOOL lastPanStateIsEnd;
@property (assign, nonatomic) CGFloat currentOffset;
@property (assign, nonatomic) CGFloat maxOffset;
@property (assign, nonatomic) BOOL cancelAnimationCompletion;
@property (nonatomic, assign) BOOL index;
@end

@implementation FHMessageCell

- (UILabel *)indexLabel {
    if(!_indexLabel) {
        _indexLabel = [UILabel new];
        _indexLabel.textColor = [UIColor themeRed];
        _indexLabel.font = [UIFont themeFontMedium:14];
        _indexLabel.text = @"0/0";
        _indexLabel.backgroundColor = [UIColor themeBlack];
        _indexLabel.hidden = YES;
        _indexLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIndexLabelAction:)];
        [_indexLabel addGestureRecognizer:tap];
    }
    return _indexLabel;
}

- (FHMessageCellTagsView *)tagsView {
    if(!_tagsView) {
        _tagsView = [FHMessageCellTagsView new];
        _tagsView.isPassthrough = YES; // 点击事件透传到父视图
    }
    return _tagsView;
}

- (UIImageView *)iconCoverView {
    if(!_iconCoverView) {
        _iconCoverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_business_icon_c"]];
        _iconCoverView.layer.masksToBounds = YES;
        _iconCoverView.layer.cornerRadius = 25;
        _iconCoverView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [[UIColor colorWithHexStr:@"#B2B2B2"] colorWithAlphaComponent:0.6];
        [_iconCoverView addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.iconCoverView);
        }];
        
        UILabel *textLabel = [UILabel new];
        textLabel.font = [UIFont themeFontMedium:10];
        textLabel.textColor = [UIColor themeWhite];
        textLabel.text = @"暂无法\n服务";
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 2;
        [_iconCoverView addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.iconCoverView);
            make.centerY.equalTo(self.iconCoverView).offset(1);
        }];
        
        _iconCoverView.hidden = YES;
    }
    return _iconCoverView;
}
- (void)tapIndexLabelAction:(UITapGestureRecognizer *)tap {
    [FIMDebugManager browserConversation:self.conv];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _maxOffset = -88;
        self.state = SliderMenuClose;
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initViews
{
    self.contentView.backgroundColor = [UIColor themeGray7];
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor themeWhite];
    self.backView.layer.cornerRadius = 10;
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.equalTo(self.contentView);
        make.bottom.mas_equalTo(-12);
        make.width.mas_equalTo(self.contentView.mas_width).mas_offset(-30);
    }];
    
    self.iconView = [[UIImageView alloc] init];
    [self.backView addSubview:_iconView];
    _iconView.layer.masksToBounds = YES;
    _iconView.layer.cornerRadius = 25;
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.iconView addSubview:self.iconCoverView];
    [self.iconCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconView);
    }];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self.backView addSubview:_titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(12);
        make.top.mas_equalTo(self.backView.mas_top).offset(20);
        make.height.mas_equalTo(22);
    }];
    
    self.scoreLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
    [self.backView addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
    }];
    
    self.timeLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.backView addSubview:_timeLabel];
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.backView.mas_right).offset(-16);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.height.mas_equalTo(17);
    }];
        
    // 标签视图
    [self.backView addSubview:self.tagsView];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scoreLabel.mas_right).offset(4);
        make.right.equalTo(self.timeLabel.mas_left).offset(-4);
        make.height.mas_offset(16);
        make.centerY.mas_equalTo(self.scoreLabel.mas_centerY);
    }];
    //---
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.backView addSubview:_subTitleLabel];
    
    self.muteImageView = [[UIImageView alloc] init];
    [self.backView addSubview:self.muteImageView];
    self.muteImageView.image = [UIImage imageNamed:@"chat_status_mute"];
    self.muteImageView.hidden = YES;
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(12);
        make.right.mas_equalTo(self.muteImageView.mas_left).offset(-5);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(20);
    }];
    
    [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(14, 14));
        make.centerY.mas_equalTo(self.subTitleLabel.mas_centerY);
        make.right.mas_equalTo(-16);
    }];
    
    self.msgStateView = [[UIImageView alloc] init];
    [self.backView addSubview:_msgStateView];
    self.msgStateView.hidden = YES;
    [self.msgStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.centerY.mas_equalTo(self.subTitleLabel.mas_centerY);
        make.width.height.mas_equalTo(14);
    }];
            
    self.unreadView = [[TTBadgeNumberView alloc] init];
    //self.unreadView.badgeNumberPointSize = 12;
    [self.unreadView setBadgeLabelFontSize:10];
    _unreadView.badgeViewStyle = TTBadgeNumberViewStyleDefaultWithBorder;
    [self.backView addSubview:_unreadView];
    [self.unreadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.iconView.mas_right).offset(4);
        make.top.mas_equalTo(self.iconView.mas_top).offset(1);
    }];
         
    self.editView = [[FHMessageEditView alloc] init];
    self.editView.backgroundColor = [UIColor themeOrange1];
    self.editView.frame = CGRectMake(CGRectGetMaxX(self.backView.frame) - 20, CGRectGetMinY(self.backView.frame), -_maxOffset + 20, self.backView.frame.size.height);
    self.editView.layer.cornerRadius = 10;
    __weak typeof(self)wself = self;
    self.editView.clickDeleteBtn = ^{
        [wself delete];
    };
    [self.backView addSubview:self.editView];
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(108);
        make.top.mas_equalTo(self.backView.mas_top);
        make.height.mas_equalTo(self.backView.mas_height);
        make.right.mas_equalTo(0);
    }];
    self.editView.hidden = YES;
    
    // 内测包受调试开关控制展示
    if([TTSandBoxHelper isInHouseApp]) {
        [self.contentView addSubview:self.indexLabel];
        [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backView);
            make.left.equalTo(self.contentView);
        }];
    }
}

-(void)displaySendState:(ChatMsg *)msg isMute:(BOOL)isMute {
    
    if(!msg.isDisplaySendingState) {
        return;
    }
    
    if (msg.type == ChatMstTypeNotice) {
        [self.msgStateView setHidden:YES];
        [self updateLayoutForMsgState:ChatMsgStateSuccess isMute:isMute];
    } else if (msg.state == ChatMsgStateFail) {
        [self.msgStateView setImage:[UIImage imageNamed:@"chat_state_fail_orange_ic"]];
        [self.msgStateView setHidden:NO];
        [self updateLayoutForMsgState:msg.state isMute:isMute];
    } else if (msg.state == ChatMsgStateSending) {
        [self.msgStateView setImage:[UIImage imageNamed:@"chat_state_message_sending_ic"]];
        [self.msgStateView setHidden:NO];
        [self updateLayoutForMsgState:msg.state isMute:isMute];
    } else {
        [self.msgStateView setHidden:YES];
        [self updateLayoutForMsgState:msg.state isMute:isMute];
    }
}

-(void)updateLayoutForMsgState:(ChatMsgState)state isMute:(BOOL)isMute
{
    self.muteImageView.hidden = !isMute;
    
    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (state != ChatMsgStateSuccess) {
            make.left.mas_equalTo(self.titleLabel.mas_left).offset(16);
        } else {
            make.left.mas_equalTo(self.titleLabel.mas_left);
        }
        if (isMute) {
            make.right.mas_equalTo(self.muteImageView.mas_left).offset(-5);
        } else {
            make.right.mas_equalTo(self.backView.mas_right).offset(-16);
        }
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
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
    self.subTitleLabel.attributedText = nil;
    self.subTitleLabel.text = model.content;
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:[model.timestamp doubleValue]];
    self.timeLabel.text = [self timeLabelByDate:date];
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:model.icon] placeholder:[UIImage imageNamed:@"default_image"]];
    self.unreadView.badgeNumber = [model.unread integerValue] == 0 ? TTBadgeNumberHidden : [model.unread integerValue];
    if(!_msgStateView.hidden){
        //im 复用cell
        self.msgStateView.hidden = YES;
        [self updateLayoutForMsgState:ChatMsgStateSuccess isMute:NO];
    }
    self.scoreLabel.hidden = YES;
    // 消除tags
    [self.tagsView updateWithTags:nil];
    self.iconCoverView.hidden = YES;
    self.muteImageView.hidden = YES;
}

- (void)updateWithChat:(IMConversation*)conversation {
    // debug: 内测包，并且调试开关打开时，才展示
    if([TTSandBoxHelper isInHouseApp]) {
        self.indexLabel.hidden = !([[FIMDebugManager shared] isEnableForEntry:FIMDebugOptionEntrySwitchShowDebugInfo]);
    }
    // --
    
    IMConversation* conv = conversation;
    self.conv = conversation;
    if (conv.mute) {
        if (conv.unreadCount > 0) {
            self.unreadView.badgeNumber = TTBadgeNumberPoint;
        } else {
            self.unreadView.badgeNumber = 0;
        }
        self.muteImageView.hidden = NO;
    } else {
        self.unreadView.badgeNumber = conv.unreadCount;
        self.muteImageView.hidden = YES;
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
            self.subTitleLabel.attributedText = nil;
            self.subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", roleHintText, recallHintText];
        }
        else if (isGroupChat) {
            NSString *lastMessage = [conv lastMessage];
            NSString *cutStr = [self cutLineBreak:lastMessage];
            
            
            NSNumber *uid =[NSNumber numberWithLongLong: [[[TTAccount sharedAccount] userIdString] longLongValue]];
            if (lastMsg.isCurrentUser || lastMsg.type == ChatMstTypeNotice) {
                if ([lastMsg.mentionedUsers containsObject:uid] && ![self lastMsgHasReadInConversation:conv]) {
                    self.subTitleLabel.attributedText = [self getAtAttributeString:cutStr];;
                } else {
                    [self composeSubTitleLabelTextForConversation:conv msgText:cutStr isCutLineBreak:NO];
                }
            } else {
                [[FHChatUserInfoManager shareInstance] getUserInfoSync:[[NSNumber numberWithLongLong:lastMsg.userId] stringValue] block:^(NSString * _Nonnull userId, FHChatUserInfo * _Nonnull userInfo) {
                    NSString *tipMsg = [NSString stringWithFormat:@"%@: %@", userInfo.username, cutStr];
                    if ([lastMsg.mentionedUsers containsObject:uid] && ![self lastMsgHasReadInConversation:conv]) {
                        self.subTitleLabel.attributedText = [self getAtAttributeString:tipMsg];;
                    } else {
                        [self composeSubTitleLabelTextForConversation:conv msgText:tipMsg isCutLineBreak:NO];
                    }
                }];
            }
        } else {
            NSString *lastMessage = [conv lastMessage];
            [self composeSubTitleLabelTextForConversation:conv msgText:lastMessage isCutLineBreak:YES];
        }
    }
    
    if (conv.type == IMConversationType1to1Chat) {
        if (!isEmptyString(conv.realtorScore)) {
            self.scoreLabel.hidden = NO;
            self.scoreLabel.text = conv.realtorScore;
        } else {
            self.scoreLabel.hidden = YES;
            self.scoreLabel.text = @"";
        }
        
        // 配置标签
        NSMutableArray *tags = [NSMutableArray array];
        // 经纪公司tag
        if (!isEmptyString(conv.companyName)) {
            FHMessageCellTagModel *companyTag = [[FHMessageCellTagModel alloc] initWithName:conv.companyName];
            [tags btd_addObject:companyTag];
        }
        [self.tagsView updateWithTags:tags.copy];
        
        
        // 添加关黑tag
        BOOL isBlackmail = conv.isRealtorBlackmailed;
        self.iconCoverView.hidden = !isBlackmail;
        
    } else {
        self.scoreLabel.hidden = YES;
        [self.tagsView updateWithTags:nil];
        self.iconCoverView.hidden = YES;
    }

    [self displaySendState:lastMsg isMute:conv.mute];
    self.timeLabel.text = [self timeLabelByDate:conv.updatedAt];
    // 监牢会话更新日期无效问题
    [self monitorConversatonUpdateDateInvalidFor:conv];
}

- (void)monitorConversatonUpdateDateInvalidFor:(IMConversation *)conv {
    
    if(conv && conv.type == IMConversationType1to1Chat) {
        
        NSString *currentUserId = [TTAccount sharedAccount].userIdString;
        NSDate *updatedDate = conv.updatedAt;
        if([updatedDate isEqual:[NSDate dateWithTimeIntervalSince1970:0]]) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            extra[@"conversation_id"] = conv.identifier;
            extra[@"uid"] = currentUserId;
            IMConversation *con = [[IMManager shareInstance].chatService conversationWithIdentifier:conv.identifier];
            if(con) {
                extra[@"updateLabelText"] = [self timeLabelByDate:updatedDate];
            }
            [[HMDTTMonitor defaultManager] hmdTrackService:@"im_conversation_invalid" metric:nil category:@{@"category": @"updateDateInvalid"} extra:extra];
        }
        
        if(currentUserId.length > 0) {
            __block BOOL isValid = NO;
            [conv.someParticipants enumerateObjectsUsingBlock:^(BaseChatUser * _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
                if([user.userId isEqual:currentUserId]) {
                    isValid = YES;
                    *stop = YES;
                }
            }];
            if(!isValid) {
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                extra[@"conversation_id"] = conv.identifier;
                extra[@"uid"] = currentUserId;
                [[HMDTTMonitor defaultManager] hmdTrackService:@"im_conversation_invalid" metric:nil category:@{@"category": @"wrongConversation"} extra:extra];
            }
        }
    }
    

}
- (void)composeSubTitleLabelTextForConversation:(IMConversation *)conv msgText: (NSString *)text isCutLineBreak:(BOOL)cutLineBreak {
    switch ([conv lastChatMsg].type) {
        case ChatMsgTypeVoiceSegment:
        {
            [self processVoiceLastMessage:conv lastMessage:text];
        }
            break;
        default:
        {
            self.subTitleLabel.attributedText = nil;
            self.subTitleLabel.text = cutLineBreak?[self cutLineBreak:text]:text;
        }
            break;
    }
}
- (void)processVoiceLastMessage:(IMConversation *)conv lastMessage:(NSString *)lastMessage {
        NSRange range = [lastMessage rangeOfString:@"[语音]"];
        NSMutableAttributedString *attributeLastMessage = [[NSMutableAttributedString alloc] initWithString:lastMessage];
        UIColor *attributeColor = [self isLastVoiceMessageReadByCurrentUser:conv] ? [UIColor themeGray3] : [UIColor colorWithHexStr:@"FE5500"];
        [attributeLastMessage addAttributes:@{NSForegroundColorAttributeName: attributeColor, NSFontAttributeName:self.subTitleLabel.font} range:range];
        self.subTitleLabel.attributedText = attributeLastMessage;
}
- (BOOL)isLastVoiceMessageReadByCurrentUser:(IMConversation *)conv {
    BOOL ret = NO;
    ChatMsg *lastMsg = [conv lastChatMsg];
    if(lastMsg.type == ChatMsgTypeVoiceSegment && (lastMsg.isCurrentUser || lastMsg.isReadByCurrentUser)) {
        ret = YES;
    }
    return ret;
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

    NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName: [UIFont themeFontRegular:12],
                                                 NSForegroundColorAttributeName : [UIColor themeOrange1] ,
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
    
    NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName: [UIFont themeFontRegular:12],
                                                 NSForegroundColorAttributeName : [UIColor themeOrange1] ,
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
    return @"昨天";
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

//自定义左滑编辑
- (void)initGestureWithData:(id)data index:(NSInteger)index{
    self.index = index;
    if ([data isKindOfClass:[IMConversation class]]) {
        self.conv = data;
        if (!_panGesture) {
            _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
            _panGesture.delegate = self;
            [self.contentView addGestureRecognizer:_panGesture];
        }
    }
}

- (void)delete {
    if (self.deleteConversation) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
        self.deleteConversation(indexPath.row);
    }
}

- (void)openCompleted {
    if (self.openEditTrack) {
        self.openEditTrack(nil);
    }
}

- (void)dealloc
{
    
}
@end
