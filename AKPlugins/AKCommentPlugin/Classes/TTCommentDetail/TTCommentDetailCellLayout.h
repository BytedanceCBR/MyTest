//
//  TTCommentDetailCellLayout.h
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import <Foundation/Foundation.h>
#import <TTUIWidget/TTUGCAttributedLabel.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import "TTCommentDetailReplyCommentModel.h"


@interface TTCommentDetailCellHelper : NSObject
+ (CGFloat)cellVerticalPadding;
+ (CGFloat)cellHorizontalPadding;
+ (CGFloat)cellRightPadding;
+ (CGFloat)avatarNormalSize;
+ (CGSize)verifyLogoSize:(CGSize)standardSize;
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

@interface TTCommentDetailCellNameLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@end

@interface TTCommentDetailCellContentLayout : NSObject
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) TTRichSpanText *richSpanText;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat top;
@end

@interface TTCommentDetailCellDeleteLayout : NSObject
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTCommentDetailCellDiggLayout : NSObject
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@end

@interface TTCommentDetailCellUserInfoLayout : NSObject
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTCommentDetailCellTimeLayout : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *text;
@end

@interface TTCommentDetailCellLayout : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) TTCommentDetailCellNameLayout *nameLayout;
@property (nonatomic, strong) TTCommentDetailCellContentLayout *contentLayout;
@property (nonatomic, strong) TTCommentDetailCellDeleteLayout *deleteLayout;
@property (nonatomic, strong) TTCommentDetailCellDiggLayout *diggLayout;
@property (nonatomic, strong) TTCommentDetailCellUserInfoLayout *userInfoLayout;
@property (nonatomic, strong) TTCommentDetailCellTimeLayout *timeLayout;
@property (nonatomic, assign) BOOL hasQuotedContent;

- (instancetype)initWithCommentModel:(TTCommentDetailReplyCommentModel *)model containViewWidth:(CGFloat)width;

- (void)setCellLayoutWithCommentModel:(TTCommentDetailReplyCommentModel *)model containViewWidth:(CGFloat)width;

+ (NSArray<TTCommentDetailCellLayout *> *)arrayOfLayoutsFromModels:(NSArray<TTCommentDetailReplyCommentModel *> *)models containViewWidth:(CGFloat)width;
@end
