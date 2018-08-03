//
//  TTIMCenterChatCell.m
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMCenterChatCell.h"
// Views
#import "SSThemed.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "TTPLUnreadNumberView.h"
// Data
#import "TTIMMessage.h"
#import "TTUserData.h"
#import "TTIMChatCenterViewModel.h"
// Utils
#import "UIColor+TTThemeExtension.h"
#import "UIView-Extension.h"

@interface TTIMCenterChatCell ()

/** 头像 */
@property (nonatomic, strong) TTAsyncCornerImageView *avatarImageView;
/** 名称 */
@property (nonatomic, strong) SSThemedLabel *nameLabel;
/** 信息状态 */
@property (nonatomic, strong) SSThemedLabel *messageContentStatusLabel;
/** 信息 */
@property (nonatomic, strong) SSThemedLabel *messageContentLabel;
/** 未读消息数 */
@property (nonatomic, strong) TTPLUnreadNumberView *unreadNumberView;
/** 时间 */
@property (nonatomic, strong) SSThemedLabel *timeLabel;
/** 分割线 */
@property (nonatomic, strong) SSThemedView *bottomLine;

/** 数据源 */
@property (nonatomic, strong) TTIMChatCenterModel *chatCenterModel;

@end

@implementation TTIMCenterChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
        [self tt_addThemeNotification];
    }
    return self;
}

- (void)dealloc {
    [self tt_removeThemeNotification];
}

- (void)setupSubviews {
    CGFloat avatarSide = 42;
    
    _avatarImageView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, avatarSide, avatarSide) allowCorner:YES];
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.cornerRadius = avatarSide / 2;
    _avatarImageView.borderColor = [UIColor tt_themedColorForKey:kColorLine1];
    _avatarImageView.borderWidth = [TTDeviceHelper ssOnePixel];
    _avatarImageView.placeholderName = @"friend_contact_icon";
    [_avatarImageView setupVerifyViewForLength:avatarSide adaptationSizeBlock:nil];
    [self.contentView addSubview:_avatarImageView];
    
    _unreadNumberView = [[TTPLUnreadNumberView alloc] init];
    [self.contentView addSubview:_unreadNumberView];
    
    _nameLabel = [[SSThemedLabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColorThemeKey = kColorText1;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];
    
    _messageContentStatusLabel = [[SSThemedLabel alloc] init];
    _messageContentStatusLabel.font = [UIFont systemFontOfSize:13];
    _messageContentStatusLabel.textColorThemeKey = kColorText4;
    [self.contentView addSubview:_messageContentStatusLabel];
    
    _messageContentLabel = [[SSThemedLabel alloc] init];
    _messageContentLabel.font = [UIFont systemFontOfSize:13];
    _messageContentLabel.textColorThemeKey = kColorText3;
    [self.contentView addSubview:_messageContentLabel];

    _timeLabel = [[SSThemedLabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColorThemeKey = kColorText9;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeLabel];
    
    _bottomLine = [[SSThemedView alloc] init];
    _bottomLine.backgroundColorThemeKey = kColorLine1;
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _avatarImageView.left = 15;
    _avatarImageView.centerY = self.height / 2;

    [_timeLabel sizeToFit];
    _timeLabel.size = CGSizeMake(ceil(_timeLabel.width), ceil(_timeLabel.height));
    _timeLabel.right = self.width - 15;
    _timeLabel.centerY = 25;
    
    [_nameLabel sizeToFit];
    _nameLabel.size = CGSizeMake((_timeLabel.left - 16) - (_avatarImageView.right + 12), ceil(_nameLabel.height));
    _nameLabel.left = _avatarImageView.right + 12;
    _nameLabel.centerY = _timeLabel.centerY;
    
    _unreadNumberView.right = self.width - 15;
    _unreadNumberView.centerY = 47;
    
    if (_chatCenterModel.draft.length > 0) {
        _messageContentStatusLabel.text = @"[草稿]";
    } else if ([_chatCenterModel.latestMsg isSelf] && _chatCenterModel.latestMsg.msgType != IMMsgTypeSystem) {
        switch (_chatCenterModel.latestMsg.status) {
            case IMMsgStatusPending:
            case IMMsgStatusSending:
                _messageContentStatusLabel.text = @"[发送中]";
                break;
            case IMMsgStatusSuccess:
            case IMMsgStatusNormal:
                _messageContentStatusLabel.text = nil;
                break;
            case IMMsgStatusFail:
                _messageContentStatusLabel.text = @"[发送失败]";
                break;
        }
    } else {
        _messageContentStatusLabel.text = nil;
    }
    CGFloat x = _avatarImageView.right + 12;
    [_messageContentStatusLabel sizeToFit];
    if (_messageContentStatusLabel.text) {
        _messageContentStatusLabel.size = CGSizeMake(ceil(_messageContentStatusLabel.width), ceil(_messageContentStatusLabel.height));
        _messageContentStatusLabel.left = x;
        _messageContentStatusLabel.centerY = _unreadNumberView.centerY;
        x = _messageContentStatusLabel.right;
    }
    
    _messageContentLabel.text = _chatCenterModel.draft.length > 0 ? _chatCenterModel.draft : _chatCenterModel.msgDescription;
    [_messageContentLabel sizeToFit];
    _messageContentLabel.size = CGSizeMake((self.width - 49) - 16 - x, ceil(_messageContentLabel.height));
    _messageContentLabel.left = x;
    _messageContentLabel.centerY = _unreadNumberView.centerY;
    
    _bottomLine.frame = CGRectMake(15, self.height - [TTDeviceHelper ssOnePixel], self.width - 15, [TTDeviceHelper ssOnePixel]);
}

- (void)setUnreadNumber:(NSUInteger)number {
    _unreadNumberView.unreadNumber = number;
}

- (void)setupCellWithModel:(TTIMChatCenterModel *)model
{
    _chatCenterModel = model;
    [_avatarImageView tt_setImageWithURLString:model.userModel.avatarUrl];
    [_avatarImageView showOrHideVerifyViewWithVerifyInfo:model.userModel.userAuthInfo decoratorInfo:model.userModel.userDecoration sureQueryWithID:NO userID:nil];

    _nameLabel.text = model.userModel.name.length > 0 ? model.userModel.name : model.sessionId;
    _timeLabel.text = model.displayedDate;
    
    [_unreadNumberView setUnreadNumber:(model.unreadCount >= 0 ? model.unreadCount : 0)];
}

#pragma mark Theme
- (void)tt_selfThemeChanged:(NSNotification *)notification {
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.avatarImageView.borderColor = [UIColor tt_themedColorForKey:kColorLine1];
}

@end
