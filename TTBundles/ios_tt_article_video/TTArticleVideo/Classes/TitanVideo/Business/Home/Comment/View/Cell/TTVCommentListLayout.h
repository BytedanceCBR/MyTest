//
//  TTVCommentListLayout.h
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import <Foundation/Foundation.h>
#import "TTVCommentModelProtocol.h"


@class TTRichSpanText;

@interface TTVCommentListCellHelper : NSObject
+ (CGFloat)cellVerticalPadding;
+ (CGFloat)cellHorizontalPadding;
+ (CGFloat)cellRightPadding;
+ (CGFloat)avatarSize;
+ (CGFloat)avatarRightPadding;
+ (CGFloat)sizeWithFontSetting:(CGFloat)normalSize;
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

@interface TTVCommentListNameLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@end

@interface TTVCommentListContentLayout : NSObject
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) TTRichSpanText *richSpanText;

@property (nonatomic, assign) CGFloat height; //折叠高度
@property (nonatomic, assign) CGFloat unfoldHeight; //全部展开高度
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat top;
@end

@interface TTVCommentListDeleteLayout : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTVCommentListDiggLayout : NSObject
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTVCommentListUserInfoLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTVCommentListTimeLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTVCommentListReplyLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) NSString *text;
@end

@interface TTVCommentListReplyListLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end

@interface TTVCommentListLayout : NSObject
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) TTVCommentListNameLayout *nameLayout;
@property (nonatomic, strong) TTVCommentListContentLayout *contentLayout;
@property (nonatomic, strong) TTVCommentListDeleteLayout *deleteLayout;
@property (nonatomic, strong) TTVCommentListDiggLayout *diggLayout;
@property (nonatomic, strong) TTVCommentListUserInfoLayout *userInfoLayout;
@property (nonatomic, strong) TTVCommentListTimeLayout *timeLayout;
@property (nonatomic, strong) TTVCommentListReplyLayout *replyLayout;
@property (nonatomic, strong) TTVCommentListReplyListLayout *replyListLayout;
@property (nonatomic, assign) BOOL hasQuotedContent;
@property (nonatomic, assign) BOOL isUnFold;

- (void)setCellLayoutWithCommentModel:(id <TTVCommentModelProtocol>)model containViewWidth:(CGFloat)width;

+ (CGFloat)heightForContentLabel:(NSAttributedString *)attributedText
                constraintsWidth:(CGFloat)constraintsWidth
          limitedToNumberOfLines:(NSUInteger)limitedToNumberOfLines;

@end
