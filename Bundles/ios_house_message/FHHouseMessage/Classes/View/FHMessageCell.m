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
#import "FHMessageEditHelp.h"

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface FHMessageCell()

@property(nonatomic, strong) UIView *backView;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *scoreLabel;
@property(nonatomic, strong) FHShadowLabel *companyLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIImageView *msgStateView;
@property(nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic) BOOL lastPanStateIsEnd;
@property (assign, nonatomic) CGFloat currentOffset;
@property (assign, nonatomic) CGFloat maxOffset;
@property (assign, nonatomic) BOOL cancelAnimationCompletion;
@property (nonatomic, strong) FHMessageEditView *editView;
@property (nonatomic, assign) BOOL index;
@property (nonatomic, strong) IMConversation *conv;

@end

@implementation FHMessageCell

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
    
    self.companyLabel = [[FHShadowLabel alloc] initWithEdgeInsets:UIEdgeInsetsMake(3, 4, 3, 4)];
    [self.backView addSubview:self.companyLabel];
    self.companyLabel.font = [UIFont themeFontRegular:10];
    self.companyLabel.textColor = [UIColor themeGray2];
    self.companyLabel.textAlignment = NSTextAlignmentCenter;
    self.companyLabel.layer.backgroundColor = [UIColor themeGray7].CGColor;
    self.companyLabel.layer.cornerRadius = 8;
    self.companyLabel.hidden = YES;
    [self.companyLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.scoreLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.scoreLabel.mas_centerY);
        make.width.mas_lessThanOrEqualTo(118);
        make.right.mas_lessThanOrEqualTo(self.timeLabel.mas_left).offset(-4);
    }];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.backView addSubview:_subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(12);
        make.right.mas_equalTo(self.muteImageView.mas_left).offset(-5);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(20);
    }];
    
    self.muteImageView = [[UIImageView alloc] init];
    [self.backView addSubview:self.muteImageView];
    self.muteImageView.image = [UIImage imageNamed:@"chat_status_mute"];
    self.muteImageView.hidden = YES;
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
    [self.contentView insertSubview:self.editView belowSubview:self.backView];
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView.mas_right).mas_offset(-20);
        make.top.mas_equalTo(self.backView.mas_top);
        make.height.mas_equalTo(self.backView.mas_height);
        make.right.mas_equalTo(-15);
    }];
}

-(void)displaySendState:(ChatMsg *)msg isMute:(BOOL)isMute {
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
    self.companyLabel.hidden = YES;
    self.muteImageView.hidden = YES;
}

- (void)updateWithChat:(IMConversation*)conversation {
    IMConversation* conv = conversation;
    self.conv = conversation;
    if ([[FHMessageEditHelp shared].conversation.identifier isEqualToString:conversation.identifier]) {
        //更新 删除 layout
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15 + self.maxOffset);
        }];
    } else {
        if (self.state == SliderMenuOpen) {
            NSLog(@"11122 %@ %@", [FHMessageEditHelp shared].conversation.identifier, self.conv.identifier);
        }
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
        }];
    }
    
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
                    if([conv lastChatMsg].type != ChatMsgTypeVoiceSegment) {
                        self.subTitleLabel.attributedText = nil;
                        self.subTitleLabel.text = cutStr;
                    } else {
                        [self processVoiceLastMessage:conv lastMessage:cutStr];
                    }
                }
            } else {
                [[FHChatUserInfoManager shareInstance] getUserInfoSync:[[NSNumber numberWithLongLong:lastMsg.userId] stringValue] block:^(NSString * _Nonnull userId, FHChatUserInfo * _Nonnull userInfo) {
                    NSString *tipMsg = [NSString stringWithFormat:@"%@: %@", userInfo.username, cutStr];
                    if ([lastMsg.mentionedUsers containsObject:uid] && ![self lastMsgHasReadInConversation:conv]) {
                        self.subTitleLabel.attributedText = [self getAtAttributeString:tipMsg];;
                    } else {
                        
                        if([conv lastChatMsg].type != ChatMsgTypeVoiceSegment) {
                            self.subTitleLabel.attributedText = nil;
                            self.subTitleLabel.text = tipMsg;
                        } else {
                            [self processVoiceLastMessage:conv lastMessage:tipMsg];
                        }
                    }
                }];
            }
        } else {
            NSString *lastMessage = [conv lastMessage];
            if([conv lastChatMsg].type != ChatMsgTypeVoiceSegment) {
                self.subTitleLabel.attributedText = nil;
                self.subTitleLabel.text = [self cutLineBreak:lastMessage];
            } else {
                [self processVoiceLastMessage:conv lastMessage:lastMessage];
            }
        }
    }
    
    if (conv.type == IMConversationType1to1Chat) {
        if (!isEmptyString(conv.realtorScore)) {
            self.scoreLabel.hidden = NO;
            self.scoreLabel.text = conv.realtorScore;
        } else {
            self.scoreLabel.hidden = YES;
        }
        if (!isEmptyString(conv.companyName)) {
            self.companyLabel.hidden = NO;
            self.companyLabel.text = conv.companyName;
        } else {
            self.companyLabel.hidden = YES;
        }
    } else {
        self.scoreLabel.hidden = YES;
        self.companyLabel.hidden = YES;
    }

    [self displaySendState:lastMsg isMute:conv.mute];
    self.timeLabel.text = [self timeLabelByDate:conv.updatedAt];
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

- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (![FHMessageEditHelp shared].currentCell) {
        [FHMessageEditHelp shared].currentCell = self;
        [FHMessageEditHelp shared].conversation = self.conv;
    }
//    if (_lastPanStateIsEnd && self.state == SliderMenuSlider && [[FHMessageEditHelp shared].currentCell isEqual:self]) {
//        _cancelAnimationCompletion = true;
//        self.currentOffset = 0;
//        [pan setTranslation:CGPointMake(self.layer.presentationLayer.frame.origin.x, 0) inView:pan.view];
//        [self move:self.layer.presentationLayer.frame.origin.x];
//        [self.layer removeAllAnimations];
//        [self removeAnimations];
//    }
    if (![[FHMessageEditHelp shared].currentCell isEqual:self]) {
        [[FHMessageEditHelp shared].currentCell openMenu:false time:0.35 springX:0];
        [FHMessageEditHelp shared].currentCell = self;
        [FHMessageEditHelp shared].conversation = self.conv;
    }
    CGFloat panX = [pan translationInView:pan.view].x;
    if (self.state == SliderMenuClose && panX >= 0) {
        return;
    }
    CGFloat offsetX = panX + _currentOffset;
    if (offsetX > 0) {
        offsetX = 0;
    }

    if (pan.state == UIGestureRecognizerStateBegan) {
//        [self.layer removeAllAnimations];
//        [self removeAnimations];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (panX > 0) {
            if (self.state == SliderMenuOpen) {
                [self cancelPan];
                [self openMenu:false time:0.35 springX:3];
            }
            return;
        }
        self.state = SliderMenuSlider;
        [self move:offsetX];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint speed = [pan velocityInView:self];
        CGFloat time = 0.4;
        if (offsetX < 0.3 * _maxOffset || offsetX < -30) {
            if (offsetX < _maxOffset) {
                [self openMenu:true time:time springX:3];
            } else {
                [self openMenu:true time:time springX:-10];
            }
        } else {
            time = MAX(MIN( ABS(offsetX*1.8/speed.x),time),0.25);
            [self openMenu:false time:time springX:3];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == _panGesture) {
        
        CGFloat panY = [_panGesture translationInView:gestureRecognizer.view].y;
        if (ABS(panY) > 0) {
            if ([FHMessageEditHelp shared].currentCell) {
                [[FHMessageEditHelp shared].currentCell openMenu:false time:0.4 springX:0];
            }
            return false;
        }
        if (CGRectGetWidth(self.backView.frame) - [self.panGesture locationInView:self.backView].x > 120) {
            return NO;
        }
    }
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return true;
}

- (void)close {
    [FHMessageEditHelp clear];
    [self openMenu:false time:0.35 springX:0];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    CGPoint newP = [self convertPoint:point toView:_editView];
    if ( [_editView pointInside:newP withEvent:event])
    {
        return [_editView hitTest:newP withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}

- (void)delete {
    if (self.deleteConversation) {
        self.deleteConversation(self.conv);
    }
}

//- (void)removeEditView {
//    if (self.editView) {
//        for (UIView *view in self.editView.subviews) {
//            [view removeFromSuperview];
//        }
//        [self.editView removeFromSuperview];
//        self.editView = nil;
//    }
//}

- (void)openMenu:(BOOL)open time:(NSTimeInterval)time springX:(CGFloat)springX {
    if (!open) {
        [FHMessageEditHelp clear];
    }
    CGFloat moveX = open ? _maxOffset : 0;
    self.state = SliderMenuSlider;
    [FHMessageEditHelp shared].isCanReloadData = NO;
    [self.layer removeAllAnimations];
    [self removeAnimations];
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration |  UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:time delay:0 options:options animations:^{
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15 + moveX + springX);
        }];
        if (!open) {
            [self.contentView layoutIfNeeded];
        }
        //[self move:moveX + springX];
    } completion:^(BOOL finished) {
//        if (self.cancelAnimationCompletion) {
//            [self removeAnimations];
//            self.cancelAnimationCompletion = NO;
//            return;
//        }
        if (finished) {
            [FHMessageEditHelp shared].isCanReloadData = YES;
            if (self.stateIsClose) {
                self.stateIsClose(nil);
            }
//            if (_lastPanStateIsEnd && [[FHMessageEditHelp shared].currentCell isEqual:self] && !open) {
//                [FHMessageEditHelp shared].isCanReloadData = YES;
//            }
            if (springX != 0) {
                [UIView animateWithDuration:0.3 delay:0 options:options animations:^{
                    [self move:moveX];
                } completion:nil];
            }
            if (open) {
                self.state = SliderMenuOpen;
                NSLog(@"11122 %@", self.conv.identifier);
                self.currentOffset = self.maxOffset;
                if (self.openEditTrack) {
                    self.openEditTrack(nil);
                }
            } else {
                self.state = SliderMenuClose;
                self.currentOffset = 0;
                if (self.closeEditTrack) {
                    //self.closeEditTrack(nil);
                }
            }
        }
    }];
}

- (void)removeAnimations {
    [_editView.layer removeAllAnimations];
}

- (void)cancelPan{
    _panGesture.enabled = false;
    _panGesture.enabled = true;
}

- (void)move:(CGFloat)x {
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15 + x);
    }];
    [self.contentView layoutIfNeeded];
//    [self.backView layoutIfNeeded];
//    [UIView commitAnimations];
//    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end
