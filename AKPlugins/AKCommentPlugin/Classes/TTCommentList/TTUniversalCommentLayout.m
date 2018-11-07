//
//  TTUniversalCommentLayout.m
//  Article
//
//  Created by zhaoqin on 08/11/2016.
//
//

#import "TTUniversalCommentLayout.h"
#import "TTCommentReplyListView.h"
#import "TTCommentUIHelper.h"
#import <TTThemed/SSThemed.h>
#import <TTAccountBusiness.h>
#import <TTBaseLib/TTLAbelTextHelper.h>
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import <TTUGCFoundation/TTRichSpanText+Comment.h>
#import <TTUGCFoundation/TTRichSpanText+Link.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>



#pragma mark TTUniversalCommentCellLiteHelper

@implementation TTUniversalCommentCellLiteHelper

+ (CGFloat)cellVerticalPadding {
    return [self fitSizeWithiPhone6:14.f iPhone5:13.f];
}

+ (CGFloat)cellHorizontalPadding {
    return [self fitSizeWithiPhone6:15.f iPhone5:15.f];
}

+ (CGFloat)cellRightPadding {
    return [self fitSizeWithiPhone6:18.f iPhone6P:21.f iPhone5:17.f];
//    return [self fitSizeWithiPhone6:18.f iPhone5:17.f];
}
#pragma mark avatar
+ (CGFloat)avatarNormalSize{
    return 36.f;
}
+ (CGSize)verifyLogoSize:(CGSize)standardSize{
    CGFloat vWidth = ceil([self avatarSize] / [self avatarNormalSize] * standardSize.width);
    CGFloat vHeight = ceil([self avatarSize] / [self avatarNormalSize] * standardSize.height);
    return CGSizeMake(vWidth, vHeight);
}

+ (CGFloat)avatarSize {
    return [self fitSizeWithiPhone6:28 iPhone5:25];
}

+ (CGFloat)avatarRightPadding  {
    return [self fitSizeWithiPhone6:8 iPhone5:8];
}
#pragma mark nameView
+ (CGFloat)nameViewBottomPadding {
    return [self fitSizeWithiPhone6:-1.f iPhone5:0.f];
}

+ (CGFloat)nameViewFontSize {
    return [self fitSizeWithiPhone6:14.f iPhone5:13.f];
}

+ (CGFloat)nameViewRightPadding {
    return [self fitSizeWithiPhone6:15.f iPhone5:15.f];
    
}
#pragma mark userInfoLabel

+ (CGFloat)userInfoLabelTopPadding {
    return [self fitSizeWithiPhone6:1.5f iPhone5:1.5f];
}

+ (UIFont *)userInfoLabelFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:12.f]];
}

#pragma mark contentLabel
+ (CGFloat)contentLabelPadding {
    return [self fitSizeWithiPhone6:10.f iPhone5:10.f];
}

+ (CGFloat)contentLabelRightPadding {
    return [self fitSizeWithiPhone6:15.f iPhone5:15.f];
}

+ (UIFont *)contentLabelFont {
//    return [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]]];
    return [UIFont fontWithName:@"PingFangSC-Regular" size:[TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]]] ? : [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]]];
}

+ (UIColor *)contentLabelTextColor {
    return SSGetThemedColorWithKey(kColorText1);
}

+ (NSParagraphStyle *)contentLabelParagraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = [TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]] * 1.4f;
    paragraphStyle.maximumLineHeight = [TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]] * 1.4f;
    paragraphStyle.lineSpacing = 0;
    return paragraphStyle;
}

+ (CGFloat)fitSizeWithiPhone6:(CGFloat)size6 iPhone5:(CGFloat)size5 {
    return [self fitSizeWithiPhone6:size6 iPhone6P:size6 iPhone5:size5];
}

+ (CGFloat)fitSizeWithiPhone6:(CGFloat)size6 iPhone6P:(CGFloat)size6p iPhone5:(CGFloat)size5 {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
            return ceil(size6 * 1.3);
        case TTDeviceMode736:
            return ceil(size6p);
        case TTDeviceMode812:
        case TTDeviceMode667:
            return ceil(size6);
        case TTDeviceMode568:
        case TTDeviceMode480:
            return ceil(size5);
        default:
            return ceil(size6);
    }
}

+ (NSUInteger)contentLabelLimitToNumberOfLines {
    return 6;
}

#pragma mark - replyButton

+ (UIFont *)replyButtonFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:11.f]];
}

+ (UIFont *)timeLabelFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:12.f]];
}

+ (CGFloat)replyButtonFontTopPadding {
    return [self fitSizeWithiPhone6:10.f iPhone5:8.f];
}

+ (CGFloat)digButtonLeftPadding {
    return [TTDeviceUIUtils tt_newPadding:15.f];
}

+ (UIFont *)deleteButtonFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:11.f]];
}

@end

@implementation TTUniversalCommentNameLayout


@end

@implementation TTUniversalCommentContentLayout

@end

@implementation TTUniversalCommentDeleteLayout


@end

@implementation TTUniversalCommentDiggLayout

@end

@implementation TTUniversalCommentUserInfoLayout


@end

@implementation TTUniversalCommentTimeLayout


@end

@implementation TTUniversalCommentReplyLayout


@end

@implementation TTUniversalCommentReplyListLayout


@end

@implementation TTUniversalCommentLayout

#pragma mark - Public Methods

- (void)setCommentCellLayoutWithCommentModel:(id <TTCommentModelProtocol>)model constraintWidth:(CGFloat)constraintWidth {
    if (![model conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
        return;
    }
    self.isUnFold = NO;
    self.identifier = model.commentID;
    self.cellWidth = constraintWidth;
    self.hasQuotedContent = !isEmptyString(model.quotedComment.userID) && !isEmptyString(model.quotedComment.userName);

    self.nameLayout = [[TTUniversalCommentNameLayout alloc] init];
    self.nameLayout.left = [TTUniversalCommentCellLiteHelper cellHorizontalPadding] + [TTUniversalCommentCellLiteHelper avatarRightPadding] + [TTUniversalCommentCellLiteHelper avatarSize];
    self.nameLayout.bottom = [TTUniversalCommentCellLiteHelper cellVerticalPadding] + [TTUniversalCommentCellLiteHelper avatarSize] / 2 - [TTUniversalCommentCellLiteHelper nameViewBottomPadding];

    self.contentLayout = [[TTUniversalCommentContentLayout alloc] init];
    self.contentLayout.width = self.cellWidth - self.nameLayout.left - [TTUniversalCommentCellLiteHelper contentLabelRightPadding];
    if (self.hasQuotedContent) {
        /*
         * 回复引用的评论格式 -> COMMENT//@USERNAME：QUOTED COMMENT
         */
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:model.commentContent
                                                        richSpansJSONString:model.commentContentRichSpanJSONString];
        [richSpanText appendCommentQuotedUserName:model.quotedComment.userName userId:model.quotedComment.userID];
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.quotedComment.commentContent
                                                              richSpansJSONString:model.quotedComment.commentContentRichSpanJSONString];
        [richSpanText appendRichSpanText:quotedRichSpanText];

        self.contentLayout.richSpanText = richSpanText;
    } else {
        self.contentLayout.richSpanText = [[TTRichSpanText alloc] initWithText:model.commentContent richSpansJSONString:model.commentContentRichSpanJSONString];
    }
    self.contentLayout.richSpanText = [self.contentLayout.richSpanText replaceWhitelistLinks];

    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:self.contentLayout.richSpanText.text
                                                                                   fontSize:[TTUniversalCommentCellLiteHelper contentLabelFont].pointSize] mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTUniversalCommentCellLiteHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTUniversalCommentCellLiteHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTUniversalCommentCellLiteHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLayout.attributedText = attributedString;
    self.contentLayout.height = ceilf([TTUniversalCommentLayout heightForContentLabel:self.contentLayout.attributedText
                                                                           constraintsWidth:self.contentLayout.width
                                                                     limitedToNumberOfLines:[TTUniversalCommentCellLiteHelper contentLabelLimitToNumberOfLines]]);
    self.contentLayout.unfoldHeight = ceilf([TTUniversalCommentLayout heightForContentLabel:self.contentLayout.attributedText
                                                                                 constraintsWidth:self.contentLayout.width
                                                                           limitedToNumberOfLines:0]);

    self.deleteLayout = [[TTUniversalCommentDeleteLayout alloc] init];
    self.deleteLayout.hidden = !([self isSelfComment:model] || self.showDelete);
    self.deleteLayout.right = self.cellWidth - [TTUniversalCommentCellLiteHelper cellRightPadding];
    self.deleteLayout.width = ceilf([TTLabelTextHelper sizeOfText:@"删除" fontSize:[TTUniversalCommentCellLiteHelper fitSizeWithiPhone6:14.f iPhone5:13.f] forWidth:CGFLOAT_MAX forLineHeight:[TTUniversalCommentCellLiteHelper deleteButtonFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter].width);
    
    self.diggLayout = [[TTUniversalCommentDiggLayout alloc] init];
    self.diggLayout.width = [TTDeviceUIUtils tt_newPadding:50];
    self.diggLayout.right = self.cellWidth - [TTUniversalCommentCellLiteHelper cellRightPadding];
    
    self.userInfoLayout = [[TTUniversalCommentUserInfoLayout alloc] init];
    self.userInfoLayout.top = [TTUniversalCommentCellLiteHelper cellVerticalPadding] + [TTUniversalCommentCellLiteHelper avatarSize] / 2 + [TTUniversalCommentCellLiteHelper userInfoLabelTopPadding];
    self.userInfoLayout.text = [self userInfoLabelTextWith:model];
    self.userInfoLayout.left = self.nameLayout.left;
    if (self.userInfoLayout.text.length > 0) {
        CGSize userInfoSize = [TTLabelTextHelper sizeOfText:self.userInfoLayout.text fontSize:[TTUniversalCommentCellLiteHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTUniversalCommentCellLiteHelper userInfoLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        self.userInfoLayout.width = ceilf(userInfoSize.width);
        self.userInfoLayout.height = ceilf(userInfoSize.height);
        self.contentLayout.top = self.userInfoLayout.top + self.userInfoLayout.height + [TTDeviceUIUtils tt_newPadding:5];
    }
    else {
        self.userInfoLayout.width = 0;
        self.userInfoLayout.height = 0;
        self.contentLayout.top = self.nameLayout.bottom + [TTDeviceUIUtils tt_newPadding:9.f];
    }
    
    
    self.timeLayout = [[TTUniversalCommentTimeLayout alloc] init];
    NSString *timeText = [TTBusinessManager customtimeStringSince1970:[model.commentCreateTime doubleValue]];
//    self.timeLayout.text = [timeText stringByAppendingString:@" · "];
    self.timeLayout.text = [timeText stringByAppendingString:@"   "];
    //如果userInfo和time超出指定长度，重新调整userinfo宽度
    CGFloat resetWidth = self.diggLayout.right - self.diggLayout.width - [TTUniversalCommentCellLiteHelper digButtonLeftPadding] - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding];
    if (self.userInfoLayout.width > resetWidth) {
        self.userInfoLayout.width = resetWidth - 2.f;
    }
    self.timeLayout.left = self.nameLayout.left;
 
    self.replyLayout = [[TTUniversalCommentReplyLayout alloc] init];
    
    if ([model.replyCount intValue] > 0) {
        NSString *replyText = [NSString stringWithFormat:@"%@回复", [TTBusinessManager formatCommentCount:[model.replyCount intValue]]];
        self.replyLayout.hidden = NO;
        self.replyLayout.width = [TTLabelTextHelper sizeOfText:replyText fontSize:[TTUniversalCommentCellLiteHelper fitSizeWithiPhone6:14.f iPhone5:13.f] forWidth:CGFLOAT_MAX forLineHeight:[TTUniversalCommentCellLiteHelper replyButtonFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter].width + [TTDeviceUIUtils tt_newPadding:19];
        self.replyLayout.text = replyText;
        self.replyLayout.height = [TTDeviceUIUtils tt_newPadding:24.f];
        self.timeLayout.top = self.contentLayout.top + self.contentLayout.height + [TTUniversalCommentCellLiteHelper fitSizeWithiPhone6:13.f iPhone6P:16.f iPhone5:12.f];
    } else {
        self.replyLayout.hidden = YES;
        self.timeLayout.text = [self.timeLayout.text stringByAppendingString:@"回复"];
        self.timeLayout.top = self.contentLayout.top + self.contentLayout.height + [TTUniversalCommentCellLiteHelper fitSizeWithiPhone6:8.f iPhone6P:12.f iPhone5:8.f];
    }
    
    self.replyLayout.top = self.timeLayout.top - 5.f + ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]? [TTDeviceHelper ssOnePixel]: -[TTDeviceHelper ssOnePixel]);
    
    CGSize timeSize = [TTLabelTextHelper sizeOfText:self.timeLayout.text fontSize:[TTUniversalCommentCellLiteHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTUniversalCommentCellLiteHelper timeLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.timeLayout.width = ceilf(timeSize.width);
    self.timeLayout.height = ceilf(timeSize.height);
    
    self.cellHeight = self.timeLayout.top + [TTUniversalCommentCellLiteHelper timeLabelFont].pointSize;
    if (!self.replyLayout.hidden) {
        self.cellHeight = self.replyLayout.top + self.replyLayout.height;
    }
    self.cellHeight += [TTDeviceUIUtils tt_newPadding:14];
    
    if ([model hasReply]) {
        self.replyListLayout = [[TTUniversalCommentReplyListLayout alloc] init];
        self.replyListLayout.width = self.cellWidth - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper cellRightPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding];
        CGFloat contentWidth = self.cellWidth - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper cellRightPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding];
        self.cellHeight += [TTUniversalCommentCellLiteHelper contentLabelPadding] + [TTCommentReplyListView heightForListViewWithReplyArr:model.replyModelArr width:contentWidth toComment:model];
    }
    
    self.cellHeight = ceilf(self.cellHeight);
    
    self.isUnFold = model.isUnFold;
}

#pragma mark - private

+ (CGFloat)heightForContentLabel:(NSAttributedString *)attributedText
                constraintsWidth:(CGFloat)constraintsWidth
          limitedToNumberOfLines:(NSUInteger)limitedToNumberOfLines {

    if (isEmptyString(attributedText.string)) {
        return 0;
    }

    return [TTUGCAttributedLabel sizeThatFitsAttributedString:attributedText
                                              withConstraints:CGSizeMake(constraintsWidth, CGFLOAT_MAX)
                                       limitedToNumberOfLines:limitedToNumberOfLines].height;
}

- (BOOL)isSelfComment:(id<TTCommentModelProtocol>)model {
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    if ([TTAccountManager userIDLongInt] != [model.userID longLongValue]) {
        return NO;
    }
    return YES;
}

- (NSString *)userInfoLabelTextWith:(id<TTCommentModelProtocol>)model {
    NSString *text = @"";
    if (!isEmptyString(model.mediaName)) {
        text = [text stringByAppendingString:model.mediaName];
    }
    if (!isEmptyString(model.verifiedInfo)) {
        text = isEmptyString(text)? [text stringByAppendingString:model.verifiedInfo]: [text stringByAppendingFormat:@", %@", model.verifiedInfo];
    }
    return text;
}

- (void)setIsUnFold:(BOOL)isUnFold {
    if (_isUnFold == isUnFold) {
        return;
    }

    CGFloat diff = isUnFold ? self.contentLayout.unfoldHeight - self.contentLayout.height : self.contentLayout.height - self.contentLayout.unfoldHeight;
    self.timeLayout.top += diff;
    self.replyLayout.top += diff;
    self.replyListLayout.top += diff;
    self.cellHeight += diff;

    _isUnFold = isUnFold;
}

@end
