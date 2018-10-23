//
//  TTCommentDetailCellLayout.m
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import "TTCommentDetailCellLayout.h"
#import "TTCommentUIHelper.h"
#import <TTAccountBusiness.h>
#import <TTBaseLib/TTLAbelTextHelper.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTUGCFoundation/TTRichSpanText+Comment.h>
#import <TTUGCFoundation/TTRichSpanText+Link.h>
#import <TTUGCFoundation/TTRichSpanText+Emoji.h>


#pragma mark TTCommentDetailCellHelper

@implementation TTCommentDetailCellHelper

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
+ (CGFloat)avatarNormalSize{
    return 36.f;
}

+ (CGSize)verifyLogoSize:(CGSize)standardSize{
    CGFloat vWidth = ceil([self avatarSize] / [self avatarNormalSize] * standardSize.width);
    CGFloat vHeight = ceil([self avatarSize] / [self avatarNormalSize] * standardSize.height);
    return CGSizeMake(vWidth, vHeight);
}

+ (CGFloat)avatarSize {
    return [self fitSizeWithiPhone6:36.f iPhone5:32.f];
}

+ (CGFloat)avatarRightPadding  {
    return [self fitSizeWithiPhone6:12.f iPhone5:12.f];
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
    return [self fitSizeWithiPhone6:15.f iPhone5:15.f];
}

+ (UIFont *)contentLabelFont {
    return [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]]];
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
        case TTDeviceMode667:
            return ceil(size6);
        case TTDeviceMode568:
        case TTDeviceMode480:
            return ceil(size5);
        default:
            return ceil(size6);
    }
}

#pragma mark replyButton

+ (UIFont *)replyButtonFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:14.f iPhone5:13.f]];
}

+ (UIFont *)timeLabelFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:11.f]];
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

@implementation TTCommentDetailCellNameLayout
@end

@implementation TTCommentDetailCellContentLayout
@end

@implementation TTCommentDetailCellDeleteLayout
@end

@implementation TTCommentDetailCellDiggLayout
@end

@implementation TTCommentDetailCellUserInfoLayout
@end

@implementation TTCommentDetailCellTimeLayout
@end

@implementation TTCommentDetailCellLayout

#pragma mark - public
- (instancetype)initWithCommentModel:(TTCommentDetailReplyCommentModel *)model containViewWidth:(CGFloat)width {
    if (![model isKindOfClass:[TTCommentDetailReplyCommentModel class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        [self setCellLayoutWithCommentModel:model containViewWidth:width];
    }
    return self;
}

- (void)setCellLayoutWithCommentModel:(TTCommentDetailReplyCommentModel *)model containViewWidth:(CGFloat)width {
    if (![model isKindOfClass:[TTCommentDetailReplyCommentModel class]]) {
        NSAssert(NO, @"TTCommentDetailCellLayout 必须使用TTCommentDetailReplyCommentModel");
        return;
    }
    self.identifier = model.commentID;
    self.cellWidth = width;
    self.hasQuotedContent = !isEmptyString(model.qutoedCommentModel.userID) && !isEmptyString(model.qutoedCommentModel.userName);

    self.nameLayout = [[TTCommentDetailCellNameLayout alloc] init];
    self.nameLayout.left = [TTCommentDetailCellHelper cellHorizontalPadding] + [TTCommentDetailCellHelper avatarRightPadding] + [TTCommentDetailCellHelper avatarSize];
    self.nameLayout.bottom = [TTCommentDetailCellHelper cellVerticalPadding] + [TTCommentDetailCellHelper avatarSize] / 2 - [TTCommentDetailCellHelper nameViewBottomPadding];
    
    self.contentLayout = [[TTCommentDetailCellContentLayout alloc] init];
    self.contentLayout.width = self.cellWidth - self.nameLayout.left - [TTCommentDetailCellHelper contentLabelPadding];
    if (self.hasQuotedContent) {
        /*
         * 回复引用的评论格式 -> COMMENT//@USERNAME：QUOTED COMMENT
         */
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                                        richSpansJSONString:model.contentRichSpanJSONString];
        [richSpanText appendCommentQuotedUserName:model.qutoedCommentModel.userName userId:model.qutoedCommentModel.userID];
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.qutoedCommentModel.commentContent
                                                              richSpansJSONString:model.qutoedCommentModel.commentContentRichSpanJSONString];
        [richSpanText appendRichSpanText:quotedRichSpanText];

        self.contentLayout.richSpanText = richSpanText;
    } else {
        self.contentLayout.richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                                           richSpansJSONString:model.contentRichSpanJSONString];
    }

    self.contentLayout.richSpanText = [self.contentLayout.richSpanText replaceWhitelistLinks];

    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:self.contentLayout.richSpanText.text
                                                                                   fontSize:[TTCommentDetailCellHelper contentLabelFont].pointSize] mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTCommentDetailCellHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTCommentDetailCellHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTCommentDetailCellHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLayout.attributedText = attributedString;

    NSArray <TTRichSpanLink *> *richSpanLinks = [self.contentLayout.richSpanText richSpanLinksOfAttributedString];

    self.contentLayout.height = ceilf([TTCommentDetailCellLayout heightForContentLabel:self.contentLayout.attributedText
                                                                      constraintsWidth:self.contentLayout.width]);

    self.deleteLayout = [[TTCommentDetailCellDeleteLayout alloc] init];
    self.deleteLayout.hidden = ![self isSelfComment:model];
    self.deleteLayout.right = self.cellWidth - [TTCommentDetailCellHelper cellRightPadding];
    self.deleteLayout.width = ceilf([TTLabelTextHelper sizeOfText:@"删除" fontSize:[TTCommentDetailCellHelper fitSizeWithiPhone6:14.f iPhone5:13.f] forWidth:CGFLOAT_MAX forLineHeight:[TTCommentDetailCellHelper deleteButtonFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter].width);
    
    self.diggLayout = [[TTCommentDetailCellDiggLayout alloc] init];
    self.diggLayout.width = [TTDeviceUIUtils tt_newPadding:50];
    self.diggLayout.right = self.cellWidth - [TTCommentDetailCellHelper cellRightPadding];
    
    self.userInfoLayout = [[TTCommentDetailCellUserInfoLayout alloc] init];
    self.userInfoLayout.top = [TTCommentDetailCellHelper cellVerticalPadding] + [TTCommentDetailCellHelper avatarSize] / 2 + [TTCommentDetailCellHelper userInfoLabelTopPadding];
    self.userInfoLayout.text = [self userInfoLabelTextWith:model];
    self.userInfoLayout.left = self.nameLayout.left;
    if (self.userInfoLayout.text.length > 0) {
        CGSize userInfoSize = [TTLabelTextHelper sizeOfText:self.userInfoLayout.text fontSize:[TTCommentDetailCellHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTCommentDetailCellHelper userInfoLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        self.userInfoLayout.width = ceilf(userInfoSize.width);
        self.userInfoLayout.height = ceilf(userInfoSize.height);
        self.contentLayout.top = self.userInfoLayout.top + self.userInfoLayout.height + [TTDeviceUIUtils tt_newPadding:5];
    }
    else {
        self.userInfoLayout.width = 0;
        self.userInfoLayout.height = 0;
        self.contentLayout.top = self.nameLayout.bottom + [TTDeviceUIUtils tt_newPadding:9.f];
    }
    
    
    self.timeLayout = [[TTCommentDetailCellTimeLayout alloc] init];
    self.timeLayout.top = self.contentLayout.top + self.contentLayout.height + [TTCommentDetailCellHelper fitSizeWithiPhone6:8.f iPhone6P:12.f iPhone5:8.f];
    NSString *timeText = [TTBusinessManager customtimeStringSince1970:model.createTime];
    self.timeLayout.text = [timeText stringByAppendingString:@" · "];
    
    //如果userInfo和time超出指定长度，重新调整userinfo宽度
    CGFloat resetWidth = self.diggLayout.right - self.diggLayout.width - [TTCommentDetailCellHelper digButtonLeftPadding] - [TTCommentDetailCellHelper cellHorizontalPadding] - [TTCommentDetailCellHelper avatarSize] - [TTCommentDetailCellHelper avatarRightPadding];
    if (self.userInfoLayout.width > resetWidth) {
        self.userInfoLayout.width = resetWidth - 2.f;
    }
    self.timeLayout.left = self.nameLayout.left;
    self.timeLayout.text = [self.timeLayout.text stringByAppendingString:@"回复"];
    CGSize timeSize = [TTLabelTextHelper sizeOfText:self.timeLayout.text fontSize:[TTCommentDetailCellHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTCommentDetailCellHelper timeLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.timeLayout.width = ceilf(timeSize.width);
    self.timeLayout.height = ceilf(timeSize.height);
    
    self.cellHeight = self.timeLayout.top + self.timeLayout.height + [TTDeviceUIUtils tt_newPadding:12];
}

+ (NSArray<TTCommentDetailCellLayout *> *)arrayOfLayoutsFromModels:(NSArray<TTCommentDetailReplyCommentModel *> *)models containViewWidth:(CGFloat)width {
    NSMutableArray *layouts = [[NSMutableArray alloc] init];
    for (TTCommentDetailReplyCommentModel *model in models) {
        if (![model isKindOfClass:[TTCommentDetailReplyCommentModel class]]) {
            continue;
        }
        TTCommentDetailCellLayout *layout = [[TTCommentDetailCellLayout alloc] init];
        [layout setCellLayoutWithCommentModel:model containViewWidth:width];
        [layouts addObject:layout];
    }
    return [layouts copy];
}

#pragma mark - private

+ (CGFloat)heightForContentLabel:(NSAttributedString *)attributedText constraintsWidth:(CGFloat)width {
    if (isEmptyString(attributedText.string)) {
        return 0;
    }

    return [TTUGCAttributedLabel sizeThatFitsAttributedString:attributedText withConstraints:CGSizeMake(width, CGFLOAT_MAX) limitedToNumberOfLines:0].height;
}

- (BOOL)isSelfComment:(TTCommentDetailReplyCommentModel *)model {
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    if ([TTAccountManager userIDLongInt] != [model.user.ID longLongValue]) {
        return NO;
    }
    return YES;
}

- (NSString *)userInfoLabelTextWith:(TTCommentDetailReplyCommentModel *)model {
    NSString *text = @"";
    if (!isEmptyString(model.user.verifiedReason)) {
        text = isEmptyString(text)? [text stringByAppendingString:model.user.verifiedReason]: [text stringByAppendingFormat:@", %@", model.user.verifiedReason];
    }
    return text;
}

@end
