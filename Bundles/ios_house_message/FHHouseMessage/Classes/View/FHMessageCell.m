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

    if (msg.state == ChatMsgStateFail) {
        [self.msgStateView setImage:[UIImage imageNamed:@"chat_state_fail_ic"]];
        [self.msgStateView setHidden:NO];
    } else if (msg.state == ChatMsgStateSending) {
        [self.msgStateView setImage:[UIImage imageNamed:@"chat_state_message_sending_ic"]];
        [self.msgStateView setHidden:NO];
    } else {
        [self.msgStateView setHidden:YES];
    }
    
    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (msg.state != ChatMsgStateSuccess) {
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
}

- (void)updateWithChat:(IMConversation*)conversation {
    IMConversation* conv = conversation;
    self.unreadView.badgeNumber = conv.unreadCount;
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:conv.icon] placeholder:[UIImage imageNamed:@"chat_business_icon_c"]];

    self.titleLabel.text = conv.conversationDisplayName;
    if (isEmptyString(conv.conversationDisplayName)) {
        NSString *targetUserId = [conv getTargetUserId:[[TTAccount sharedAccount] userIdString]];
        self.titleLabel.text = [[FHChatUserInfoManager shareInstance] getUserInfo:targetUserId].username;
    }
    if (!isEmptyString([conv getDraft])) {
        self.subTitleLabel.attributedText = [self getDraftAttributeString:[conv getDraft]];
    } else {
        self.subTitleLabel.text = [conv lastMessage];
    }
    ChatMsg *lastMsg = [conv lastChatMsg];

    [self displaySendState:lastMsg];
    self.timeLabel.text = [self timeLabelByDate:conv.updatedAt];
}

-(NSAttributedString*)getDraftAttributeString:(NSString*)draft {

    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@", draft]];
    NSRange theRange = NSMakeRange(0, 4);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

    NSDictionary<NSString *, id> *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                 NSForegroundColorAttributeName : [UIColor redColor] ,
                                                 NSParagraphStyleAttributeName : paragraphStyle};
    [attrStr addAttributes:attributes range:theRange];
    return attrStr;
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
