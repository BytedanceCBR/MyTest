//
//  TTUniversalCommentLayout.h
//  Article
//
//  Created by zhaoqin on 08/11/2016.
//
//

#import <Foundation/Foundation.h>
#import <TTUIWidget/TTUGCAttributedLabel.h>
#import "TTCommentModelProtocol.h"

@class TTRichSpanText;

@interface TTUniversalCommentCellLiteHelper : NSObject
+ (CGFloat)cellVerticalPadding;
+ (CGFloat)cellHorizontalPadding;
+ (CGFloat)cellRightPadding;
+ (CGFloat)avatarNormalSize;
+ (CGSize)verifyLogoSize:(CGSize)standardSize;
+ (CGFloat)avatarSize;
+ (CGFloat)avatarRightPadding;
+ (CGFloat)digButtonLeftPadding;
+ (UIFont *)contentLabelFont;
+ (CGFloat)nameViewRightPadding;
+ (CGFloat)nameViewFontSize;
+ (UIFont *)userInfoLabelFont;
+ (UIFont *)timeLabelFont;
+ (UIFont *)replyButtonFont;
+ (UIFont *)deleteButtonFont;
+ (NSParagraphStyle *)contentLabelParagraphStyle;
+ (UIColor *)contentLabelTextColor;
+ (CGFloat)nameViewBottomPadding;
+ (CGFloat)userInfoLabelTopPadding;
+ (CGFloat)contentLabelPadding;
+ (CGFloat)replyButtonFontTopPadding;
+ (NSUInteger)contentLabelLimitToNumberOfLines;
@end

@interface TTUniversalCommentNameLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@end

@interface TTUniversalCommentContentLayout : NSObject
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) TTRichSpanText *richSpanText;
@property (nonatomic, assign) CGFloat height; //折叠高度
@property (nonatomic, assign) CGFloat unfoldHeight; //全部展开高度
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat top;
@end

@interface TTUniversalCommentDeleteLayout : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTUniversalCommentDiggLayout : NSObject
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTUniversalCommentUserInfoLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTUniversalCommentTimeLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTUniversalCommentReplyLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) NSString *text;
@end

@interface TTUniversalCommentReplyListLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end

@interface TTUniversalCommentLayout : NSObject
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) TTUniversalCommentNameLayout *nameLayout;
@property (nonatomic, strong) TTUniversalCommentContentLayout *contentLayout;
@property (nonatomic, strong) TTUniversalCommentDeleteLayout *deleteLayout;
@property (nonatomic, strong) TTUniversalCommentDiggLayout *diggLayout;
@property (nonatomic, strong) TTUniversalCommentUserInfoLayout *userInfoLayout;
@property (nonatomic, strong) TTUniversalCommentTimeLayout *timeLayout;
@property (nonatomic, strong) TTUniversalCommentReplyLayout *replyLayout;
@property (nonatomic, strong) TTUniversalCommentReplyListLayout *replyListLayout;
@property (nonatomic, assign) BOOL hasQuotedContent;
@property (nonatomic, assign) BOOL isUnFold;
@property (nonatomic, assign) BOOL showDelete;

- (void)setCommentCellLayoutWithCommentModel:(id <TTCommentModelProtocol>)model constraintWidth:(CGFloat)constraintWidth;

+ (CGFloat)heightForContentLabel:(NSAttributedString *)attributedText
                constraintsWidth:(CGFloat)constraintsWidth
          limitedToNumberOfLines:(NSUInteger)limitedToNumberOfLines;

@end
