//
//  TTVCommentListLayout.m
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVCommentListLayout.h"
#import "TTLabelTextHelper.h"
#import "TTAccountManager.h"
#import "SSTTTAttributedLabel.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTVCommentListReplyView.h"
#import "TTVideoCommentResponse.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Comment.h"
#import <BDTFactoryConfigurator/BDTFactoryConfigurator.h>

#pragma mark TTVCommentListCellHelper

@implementation TTVCommentListCellHelper

+ (CGFloat)cellVerticalPadding {
    return [self fitSizeWithiPhone6:14.f iPhone5:13.f];
}

+ (CGFloat)cellHorizontalPadding {
    return [self fitSizeWithiPhone6:15.f iPhone5:15.f];
}

+ (CGFloat)cellRightPadding {
    return [self fitSizeWithiPhone6:18.f iPhone6P:21.f iPhone5:17.f];
}
#pragma mark avatar
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
    return [UIFont systemFontOfSize:[self sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]]];
}

+ (UIColor *)contentLabelTextColor {
    return SSGetThemedColorWithKey(kColorText1);
}

+ (NSParagraphStyle *)contentLabelParagraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = [self sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]] * 1.4f;
    paragraphStyle.maximumLineHeight = [self sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]] * 1.4f;
    paragraphStyle.lineSpacing = 0;
    return paragraphStyle;
}

+ (CGFloat)sizeWithFontSetting:(CGFloat)normalSize {  //TOD§O:名字起得不好...
    switch ((NSInteger)[TTUserSettingsManager settingFontSize]) {
        case 0:
            return normalSize - 2.f;
            break;
        case 1:
            return normalSize;
            break;
        case 2:
            return normalSize + 2.f;
            break;
        case 3:
            return normalSize + 5.f;
            break;
        default:
            return normalSize;
            break;
    }
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

@implementation TTVCommentListNameLayout


@end

@implementation TTVCommentListContentLayout

@end

@implementation TTVCommentListDeleteLayout


@end

@implementation TTVCommentListDiggLayout

@end

@implementation TTVCommentListUserInfoLayout


@end

@implementation TTVCommentListTimeLayout


@end

@implementation TTVCommentListReplyLayout


@end

@implementation TTVCommentListReplyListLayout


@end

@implementation TTVCommentListLayout

#pragma mark - public
- (void)setCellLayoutWithCommentModel:(id <TTVCommentModelProtocol>)model containViewWidth:(CGFloat)width {
    if (![model conformsToProtocol:@protocol(TTVCommentModelProtocol)]) {
        return;
    }
    
    self.identifier = model.commentIDNum;
    self.cellWidth = width;
    self.hasQuotedContent = !isEmptyString(model.quotedComment.user_id.stringValue) && !isEmptyString(model.quotedComment.user_name);
    
    self.nameLayout = [[TTVCommentListNameLayout alloc] init];
    self.nameLayout.left = [TTVCommentListCellHelper cellHorizontalPadding] + [TTVCommentListCellHelper avatarRightPadding] + [TTVCommentListCellHelper avatarSize];
    self.nameLayout.bottom = [TTVCommentListCellHelper cellVerticalPadding] + [TTVCommentListCellHelper avatarSize] / 2 - [TTVCommentListCellHelper nameViewBottomPadding];
    
    self.contentLayout = [[TTVCommentListContentLayout alloc] init];
    self.contentLayout.width = self.cellWidth - self.nameLayout.left - [TTVCommentListCellHelper contentLabelRightPadding];
    if (self.hasQuotedContent) {
        /*
         * 回复引用的评论格式 -> COMMENT//@USERNAME：QUOTED COMMENT
         */
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:model.commentContent
                                                        richSpansJSONString:model.commentContentRichSpanJSONString];
        [richSpanText appendCommentQuotedUserName:model.quotedComment.user_name userId:model.quotedComment.user_id.stringValue];
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.quotedComment.text
                                                              richSpansJSONString:model.quotedComment.content_rich_span];
        [richSpanText appendRichSpanText:quotedRichSpanText];

        self.contentLayout.richSpanText = richSpanText;
    } else {
        self.contentLayout.richSpanText = [[TTRichSpanText alloc] initWithText:model.commentContent richSpansJSONString:model.commentContentRichSpanJSONString];
    }

    __block NSAttributedString *commentAttributedText = nil;
    [[BDTFactoryConfigurator sharedConfigurator] enumerateFactoryBlockForKey:@"TTUGC" usingBlock:^void(NSAttributedString * (^factoryBlock)(NSString *, NSDictionary *), BOOL *stop) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.contentLayout.richSpanText.text forKey:@"text"];
        [params setValue:@([TTVCommentListCellHelper contentLabelFont].pointSize) forKey:@"fontSize"];
        commentAttributedText = factoryBlock(@"TTUGCEmojiParser/parseInCoreTextContext", [params copy]);
        *stop = !!commentAttributedText;
    }];

    NSMutableAttributedString *attributedString = [commentAttributedText mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTVCommentListCellHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTVCommentListCellHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTVCommentListCellHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLayout.attributedText = attributedString;

    self.contentLayout.height = ceilf([TTVCommentListLayout heightForContentLabel:self.contentLayout.attributedText
                                                                 constraintsWidth:self.contentLayout.width
                                                           limitedToNumberOfLines:[TTVCommentListCellHelper contentLabelLimitToNumberOfLines]]);
    self.contentLayout.unfoldHeight = ceilf([TTVCommentListLayout heightForContentLabel:self.contentLayout.attributedText
                                                                       constraintsWidth:self.contentLayout.width
                                                                 limitedToNumberOfLines:0]);

    CGFloat contentHeight = (self.isUnFold) ? self.contentLayout.unfoldHeight: self.contentLayout.height;
    
    self.deleteLayout = [[TTVCommentListDeleteLayout alloc] init];
    self.deleteLayout.hidden = ![self isSelfComment:model];
    self.deleteLayout.right = self.cellWidth - [TTVCommentListCellHelper cellRightPadding];
    self.deleteLayout.width = ceilf([TTLabelTextHelper sizeOfText:@"删除" fontSize:[TTVCommentListCellHelper fitSizeWithiPhone6:14.f iPhone5:13.f] forWidth:CGFLOAT_MAX forLineHeight:[TTVCommentListCellHelper deleteButtonFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter].width);
    
    self.diggLayout = [[TTVCommentListDiggLayout alloc] init];
    self.diggLayout.width = [TTDeviceUIUtils tt_newPadding:50];
    self.diggLayout.right = self.cellWidth - [TTVCommentListCellHelper cellRightPadding];
    
    self.userInfoLayout = [[TTVCommentListUserInfoLayout alloc] init];
    self.userInfoLayout.top = [TTVCommentListCellHelper cellVerticalPadding] + [TTVCommentListCellHelper avatarSize] / 2 + [TTVCommentListCellHelper userInfoLabelTopPadding];
    self.userInfoLayout.text = [self userInfoLabelTextWith:model];
    self.userInfoLayout.left = self.nameLayout.left;
    if (self.userInfoLayout.text.length > 0) {
        CGSize userInfoSize = [TTLabelTextHelper sizeOfText:self.userInfoLayout.text fontSize:[TTVCommentListCellHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTVCommentListCellHelper userInfoLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        self.userInfoLayout.width = ceilf(userInfoSize.width);
        self.userInfoLayout.height = ceilf(userInfoSize.height);
        self.contentLayout.top = self.userInfoLayout.top + self.userInfoLayout.height + [TTDeviceUIUtils tt_newPadding:5];
    }
    else {
        self.userInfoLayout.width = 0;
        self.userInfoLayout.height = 0;
        self.contentLayout.top = self.nameLayout.bottom + [TTDeviceUIUtils tt_newPadding:9.f];
    }
    
    
    self.timeLayout = [[TTVCommentListTimeLayout alloc] init];
    NSString *timeText = [TTBusinessManager customtimeStringSince1970:[model.commentCreateTime doubleValue]];
    self.timeLayout.text = [timeText stringByAppendingString:@" · "];
    
    //如果userInfo和time超出指定长度，重新调整userinfo宽度
    CGFloat resetWidth = self.diggLayout.right - self.diggLayout.width - [TTVCommentListCellHelper digButtonLeftPadding] - [TTVCommentListCellHelper cellHorizontalPadding] - [TTVCommentListCellHelper avatarSize] - [TTVCommentListCellHelper avatarRightPadding];
    if (self.userInfoLayout.width > resetWidth) {
        self.userInfoLayout.width = resetWidth - 2.f;
    }
    self.timeLayout.left = self.nameLayout.left;
    
    self.replyLayout = [[TTVCommentListReplyLayout alloc] init];
    
    if (model.replyCount.integerValue > 0) {
        NSString *replyText = [NSString stringWithFormat:@"%@回复", [TTBusinessManager formatCommentCount:model.replyCount.integerValue]];
        self.replyLayout.hidden = NO;
        self.replyLayout.width = [TTLabelTextHelper sizeOfText:replyText fontSize:[TTVCommentListCellHelper fitSizeWithiPhone6:14.f iPhone5:13.f] forWidth:CGFLOAT_MAX forLineHeight:[TTVCommentListCellHelper replyButtonFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter].width + [TTDeviceUIUtils tt_newPadding:19];
        self.replyLayout.text = replyText;
        self.replyLayout.height = [TTDeviceUIUtils tt_newPadding:24.f];
        self.timeLayout.top = self.contentLayout.top + contentHeight + [TTVCommentListCellHelper fitSizeWithiPhone6:13.f iPhone6P:16.f iPhone5:12.f];
    } else {
        self.replyLayout.hidden = YES;
        self.timeLayout.text = [self.timeLayout.text stringByAppendingString:@"回复"];
        self.timeLayout.top = self.contentLayout.top + contentHeight + [TTVCommentListCellHelper fitSizeWithiPhone6:8.f iPhone6P:12.f iPhone5:8.f];
    }
    
    self.replyLayout.top = self.timeLayout.top - 5.f + ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]? [TTDeviceHelper ssOnePixel]: -[TTDeviceHelper ssOnePixel]);
    
    CGSize timeSize = [TTLabelTextHelper sizeOfText:self.timeLayout.text fontSize:[TTVCommentListCellHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTVCommentListCellHelper timeLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.timeLayout.width = ceilf(timeSize.width);
    self.timeLayout.height = ceilf(timeSize.height);
    
    self.cellHeight = self.timeLayout.top + [TTVCommentListCellHelper timeLabelFont].pointSize;
    if (!self.replyLayout.hidden) {
        self.cellHeight = self.replyLayout.top + self.replyLayout.height;
    }
    self.cellHeight += [TTDeviceUIUtils tt_newPadding:14];
    
    if ([model hasReply]) {
        self.replyListLayout = [[TTVCommentListReplyListLayout alloc] init];
        self.replyListLayout.width = self.cellWidth - [TTVCommentListCellHelper cellHorizontalPadding] - [TTVCommentListCellHelper cellRightPadding] - [TTVCommentListCellHelper avatarSize] - [TTVCommentListCellHelper avatarRightPadding];
        CGFloat contentWidth = self.cellWidth - [TTVCommentListCellHelper cellHorizontalPadding] - [TTVCommentListCellHelper cellRightPadding] - [TTVCommentListCellHelper avatarSize] - [TTVCommentListCellHelper avatarRightPadding];
        self.cellHeight += [TTVCommentListCellHelper contentLabelPadding] + [TTVCommentListReplyView heightForListViewWithReplyArr:nil width:contentWidth toComment:model];
    }
    
    self.cellHeight = ceilf(self.cellHeight);
}

#pragma mark - private

+ (CGFloat)heightForContentLabel:(NSAttributedString *)attributedText
                constraintsWidth:(CGFloat)constraintsWidth
          limitedToNumberOfLines:(NSUInteger)limitedToNumberOfLines {

    if (isEmptyString(attributedText.string)) {
        return 0;
    }

    return [TTTAttributedLabel sizeThatFitsAttributedString:attributedText
                                            withConstraints:CGSizeMake(constraintsWidth, CGFLOAT_MAX)
                                     limitedToNumberOfLines:limitedToNumberOfLines].height;
}

- (BOOL)isSelfComment:(id <TTVCommentModelProtocol>)model {
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    if ([[TTAccountManager userID] longLongValue] != [model.userID longLongValue]) {
        return NO;
    }
    return YES;
}

- (NSString *)userInfoLabelTextWith:(id <TTVCommentModelProtocol>)model {
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
    
    CGFloat diff = isUnFold? self.contentLayout.unfoldHeight - self.contentLayout.height: self.contentLayout.height - self.contentLayout.unfoldHeight;
    self.timeLayout.top += diff;
    self.replyLayout.top += diff;
    self.replyListLayout.top += diff;
    self.cellHeight += diff;
    
    _isUnFold = isUnFold;
}
@end
