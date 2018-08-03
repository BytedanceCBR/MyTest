//
//  TTIMSystemMessageCell.m
//  EyeU
//
//  Created by matrixzk on 10/31/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMSystemMessageCell.h"
#import "TTIMCellHelper.h"
#import "TTIMMessage.h"
// Utils
#import "UIView-Extension.h"
#import "TTUGCSimpleRichLabel.h"

@implementation TTIMSystemMessageCell
{
    SSThemedLabel *_timeLabel;
    TTUGCSimpleRichLabel *_textLabel;
    TTIMMessage   *_message;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];

        _timeLabel = [TTIMCellHelper createLabelWithFontSize:12
                                                   textColor:[UIColor tt_themedColorForKey:kColorText9]];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_timeLabel];
        
        _textLabel = [[TTUGCSimpleRichLabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:kFontSizeOfSystemMsgCellText()];
        _textLabel.textColorThemeKey = kColorText10;
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.numberOfLines = 0;
        _textLabel.textInsets = UIEdgeInsetsMake(kTopPaddingOfSystemMsgCellTextBg(), kSideMinPaddingOfSystemMsgCellTextBg(), kTopPaddingOfSystemMsgCellTextBg(), kSideMinPaddingOfSystemMsgCellTextBg());
        _textLabel.layer.cornerRadius = 4;
        _textLabel.layer.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1].CGColor;
        [self.contentView addSubview:_textLabel];
        
        [self tt_addThemeNotification];
    }
    return self;
}

- (void)dealloc {
    [self tt_removeThemeNotification];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _timeLabel.backgroundColor = backgroundColor;
    _textLabel.backgroundColor = backgroundColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originY = 0;
    if (_message.formattedSendDate.length > 0) {
        _timeLabel.text = _message.formattedSendDate;
        _timeLabel.hidden = NO;
        _timeLabel.frame = CGRectMake(0, kTopPaddingOfCellTopLabel(), CGRectGetWidth(self.contentView.frame), kHeightOfCellTopLabel());
        originY = CGRectGetMaxY(_timeLabel.frame) + kBottomPaddingOfCellTopLabel();
    } else {
        _timeLabel.text = nil;
        _timeLabel.hidden = YES;
    }
    
    CGSize textSize = [TTIMCellHelper textSizeWithMessage:_message];
    CGSize textSizeWithInsets = CGSizeMake(textSize.width + 2 * kSideMinPaddingOfSystemMsgCellTextBg(), textSize.height + 2 * kTopPaddingOfSystemMsgCellTextBg());
    _textLabel.frame = CGRectMake(0, originY + kTopPaddingOfSystemMsgCellTextLabel(), textSizeWithInsets.width, textSizeWithInsets.height);
    _textLabel.centerX = self.centerX;
}

- (void)setupCellWithMessage:(TTIMMessage *)message
{
    _message = message;
    [_textLabel setText:message.msgText textRichSpans:message.msgTextContentRichSpans];
}

+ (NSString *)TTIMSystemMsgCellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

#pragma mark Theme
- (void)tt_selfThemeChanged:(NSNotification *)notification {
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _textLabel.layer.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1].CGColor;
}

@end
