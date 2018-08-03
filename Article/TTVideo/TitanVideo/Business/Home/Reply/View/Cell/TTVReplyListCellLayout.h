//
//  TTVReplyListCellLayout.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import <Foundation/Foundation.h>
#import "TTVReplyModelProtocol.h"


@class TTRichSpanText;

@interface TTVReplyListCellHelper : NSObject
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
@end

@interface TTVReplyListCellNameLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@end

@interface TTVReplyListCellContentLayout : NSObject
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) TTRichSpanText *richSpanText;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat top;
@end

@interface TTVReplyListCellDeleteLayout : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTVReplyListCellDiggLayout : NSObject
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTVReplyListCellUserInfoLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTVReplyListCellTimeLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTVReplyListCellLayout : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) TTVReplyListCellNameLayout *nameLayout;
@property (nonatomic, strong) TTVReplyListCellContentLayout *contentLayout;
@property (nonatomic, strong) TTVReplyListCellDeleteLayout *deleteLayout;
@property (nonatomic, strong) TTVReplyListCellDiggLayout *diggLayout;
@property (nonatomic, strong) TTVReplyListCellUserInfoLayout *userInfoLayout;
@property (nonatomic, strong) TTVReplyListCellTimeLayout *timeLayout;
@property (nonatomic, assign) BOOL hasQuotedContent;

- (instancetype)initWithCommentModel:(id <TTVReplyModelProtocol>)model containViewWidth:(CGFloat)width;

- (void)setCellLayoutWithCommentModel:(id <TTVReplyModelProtocol>)model containViewWidth:(CGFloat)width;

+ (CGFloat)heightForContentLabel:(NSAttributedString *)attributedText
                constraintsWidth:(CGFloat)constraintsWidth
          limitedToNumberOfLines:(NSUInteger)limitedToNumberOfLines;

+ (NSArray<TTVReplyListCellLayout *> *)arrayOfLayoutsFromModels:(NSArray<id <TTVReplyModelProtocol>> *)models containViewWidth:(CGFloat)width;
@end
