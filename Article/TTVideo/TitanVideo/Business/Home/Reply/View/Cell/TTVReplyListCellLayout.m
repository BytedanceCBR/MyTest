//
//  TTVReplyListCellLayout.m
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVReplyListCellLayout.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "TTAccountManager.h"
#import "TTLAbelTextHelper.h"
#import <TTThemed/SSThemed.h>
#import "TTAccountManager.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Comment.h"
#import "TTVCommentListLayout.h"
#import <BDTFactoryConfigurator/BDTFactoryConfigurator.h>

extern NSInteger tt_ssusersettingsManager_fontSettingIndex();

#pragma mark TTVReplyListCellHelper

@implementation TTVReplyListCellHelper

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

+ (CGFloat)sizeWithFontSetting:(CGFloat)normalSize {
    switch (tt_ssusersettingsManager_fontSettingIndex()) {
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

@implementation TTVReplyListCellNameLayout
@end

@implementation TTVReplyListCellContentLayout
@end

@implementation TTVReplyListCellDeleteLayout
@end

@implementation TTVReplyListCellDiggLayout
@end

@implementation TTVReplyListCellUserInfoLayout
@end

@implementation TTVReplyListCellTimeLayout
@end

@implementation TTVReplyListCellLayout

#pragma mark - public
- (instancetype)initWithCommentModel:(id <TTVReplyModelProtocol>)model containViewWidth:(CGFloat)width {
    if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)]) {
        return nil;
    }
    self = [super init];
    if (self) {
        [self setCellLayoutWithCommentModel:model containViewWidth:width];
    }
    return self;
}

- (void)setCellLayoutWithCommentModel:(id <TTVReplyModelProtocol>)model containViewWidth:(CGFloat)width {
    if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)]) {
        NSAssert(NO, @"TTVReplyListCellLayout 必须使用TTCommentDetailReplyCommentModel");
        return;
    }
    self.identifier = model.commentID;
    self.cellWidth = width;
    self.hasQuotedContent = !isEmptyString(model.tt_qutoedCommentStructModel.user_id.stringValue) && !isEmptyString(model.tt_qutoedCommentStructModel.user_name);
    
    self.nameLayout = [[TTVReplyListCellNameLayout alloc] init];
    self.nameLayout.left = [TTVReplyListCellHelper cellHorizontalPadding] + [TTVReplyListCellHelper avatarRightPadding] + [TTVReplyListCellHelper avatarSize];
    self.nameLayout.bottom = [TTVReplyListCellHelper cellVerticalPadding] + [TTVReplyListCellHelper avatarSize] / 2 - [TTVReplyListCellHelper nameViewBottomPadding];
    
    self.contentLayout = [[TTVReplyListCellContentLayout alloc] init];
    self.contentLayout.width = self.cellWidth - self.nameLayout.left - [TTVReplyListCellHelper contentLabelPadding];
    if (self.hasQuotedContent) {
        /*
         * 回复引用的评论格式 -> COMMENT//@USERNAME：QUOTED COMMENT
         */
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                                        richSpansJSONString:model.contentRichSpanJSONString];
        [richSpanText appendCommentQuotedUserName:model.tt_qutoedCommentStructModel.user_name userId:model.tt_qutoedCommentStructModel.user_id.stringValue];
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.tt_qutoedCommentStructModel.text
                                                              richSpansJSONString:model.tt_qutoedCommentStructModel.content_rich_span];
        [richSpanText appendRichSpanText:quotedRichSpanText];

        self.contentLayout.richSpanText = richSpanText;
    } else {
        self.contentLayout.richSpanText = [[TTRichSpanText alloc] initWithText:model.content richSpansJSONString:model.contentRichSpanJSONString];
    }

    __block NSAttributedString *commentAttributedText = nil;
    [[BDTFactoryConfigurator sharedConfigurator] enumerateFactoryBlockForKey:@"TTUGC" usingBlock:^void(NSAttributedString * (^factoryBlock)(NSString *, NSDictionary *), BOOL *stop) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.contentLayout.richSpanText.text forKey:@"text"];
        [params setValue:@([TTVReplyListCellHelper contentLabelFont].pointSize) forKey:@"fontSize"];
        commentAttributedText = factoryBlock(@"TTUGCEmojiParser/parseInCoreTextContext", [params copy]);
        *stop = !!commentAttributedText;
    }];
    NSMutableAttributedString *attributedString = [commentAttributedText mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTVReplyListCellHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTVReplyListCellHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTVReplyListCellHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLayout.attributedText = attributedString;

    self.contentLayout.height = ceilf([TTVReplyListCellLayout heightForContentLabel:self.contentLayout.attributedText
                                                                   constraintsWidth:self.contentLayout.width
                                                             limitedToNumberOfLines:0]);

    self.deleteLayout = [[TTVReplyListCellDeleteLayout alloc] init];
    self.deleteLayout.hidden = ![self isSelfComment:model];
    self.deleteLayout.right = self.cellWidth - [TTVReplyListCellHelper cellRightPadding];
    self.deleteLayout.width = ceilf([TTLabelTextHelper sizeOfText:@"删除" fontSize:[TTVReplyListCellHelper fitSizeWithiPhone6:14.f iPhone5:13.f] forWidth:CGFLOAT_MAX forLineHeight:[TTVReplyListCellHelper deleteButtonFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter].width);
    
    self.diggLayout = [[TTVReplyListCellDiggLayout alloc] init];
    self.diggLayout.width = [TTDeviceUIUtils tt_newPadding:50];
    self.diggLayout.right = self.cellWidth - [TTVReplyListCellHelper cellRightPadding];
    
    self.userInfoLayout = [[TTVReplyListCellUserInfoLayout alloc] init];
    self.userInfoLayout.top = [TTVReplyListCellHelper cellVerticalPadding] + [TTVReplyListCellHelper avatarSize] / 2 + [TTVReplyListCellHelper userInfoLabelTopPadding];
    self.userInfoLayout.text = [self userInfoLabelTextWith:model];
    self.userInfoLayout.left = self.nameLayout.left;
    if (self.userInfoLayout.text.length > 0) {
        CGSize userInfoSize = [TTLabelTextHelper sizeOfText:self.userInfoLayout.text fontSize:[TTVReplyListCellHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTVReplyListCellHelper userInfoLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        self.userInfoLayout.width = ceilf(userInfoSize.width);
        self.userInfoLayout.height = ceilf(userInfoSize.height);
        self.contentLayout.top = self.userInfoLayout.top + self.userInfoLayout.height + [TTDeviceUIUtils tt_newPadding:5];
    }
    else {
        self.userInfoLayout.width = 0;
        self.userInfoLayout.height = 0;
        self.contentLayout.top = self.nameLayout.bottom + [TTDeviceUIUtils tt_newPadding:9.f];
    }
    
    
    self.timeLayout = [[TTVReplyListCellTimeLayout alloc] init];
    self.timeLayout.top = self.contentLayout.top + self.contentLayout.height + [TTVReplyListCellHelper fitSizeWithiPhone6:8.f iPhone6P:12.f iPhone5:8.f];
    NSString *timeText = [TTBusinessManager customtimeStringSince1970:model.createTime];
    self.timeLayout.text = [timeText stringByAppendingString:@" · "];
    
    //如果userInfo和time超出指定长度，重新调整userinfo宽度
    CGFloat resetWidth = self.diggLayout.right - self.diggLayout.width - [TTVReplyListCellHelper digButtonLeftPadding] - [TTVReplyListCellHelper cellHorizontalPadding] - [TTVReplyListCellHelper avatarSize] - [TTVReplyListCellHelper avatarRightPadding];
    if (self.userInfoLayout.width > resetWidth) {
        self.userInfoLayout.width = resetWidth - 2.f;
    }
    self.timeLayout.left = self.nameLayout.left;
    self.timeLayout.text = [self.timeLayout.text stringByAppendingString:@"回复"];
    CGSize timeSize = [TTLabelTextHelper sizeOfText:self.timeLayout.text fontSize:[TTVReplyListCellHelper fitSizeWithiPhone6:12.f iPhone5:12.f] forWidth:self.contentLayout.width forLineHeight:[TTVReplyListCellHelper timeLabelFont].lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.timeLayout.width = ceilf(timeSize.width);
    self.timeLayout.height = ceilf(timeSize.height);
    
    self.cellHeight = self.timeLayout.top + self.timeLayout.height + [TTDeviceUIUtils tt_newPadding:12];
}

+ (NSArray<TTVReplyListCellLayout *> *)arrayOfLayoutsFromModels:(NSArray<id <TTVReplyModelProtocol>> *)models containViewWidth:(CGFloat)width {
    NSMutableArray *layouts = [[NSMutableArray alloc] init];
    for (id <TTVReplyModelProtocol> model in models) {
        if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)]) {
            continue;
        }
        TTVReplyListCellLayout *layout = [[TTVReplyListCellLayout alloc] init];
        [layout setCellLayoutWithCommentModel:model containViewWidth:width];
        [layouts addObject:layout];
    }
    return [layouts copy];
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

- (BOOL)isSelfComment:(id <TTVReplyModelProtocol>)model {
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    if ([[TTAccountManager userID] longLongValue] != [model.user.ID longLongValue]) {
        return NO;
    }
    return YES;
}

- (NSString *)userInfoLabelTextWith:(id <TTVReplyModelProtocol>)model {
    NSString *text = @"";
    if (!isEmptyString(model.user.verifiedReason)) {
        text = isEmptyString(text)? [text stringByAppendingString:model.user.verifiedReason]: [text stringByAppendingFormat:@", %@", model.user.verifiedReason];
    }
    return text;
}

@end
