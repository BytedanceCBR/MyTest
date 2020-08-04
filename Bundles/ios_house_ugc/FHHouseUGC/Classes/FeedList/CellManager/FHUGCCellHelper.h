//
//  FHUGCCellHelper.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import <Foundation/Foundation.h>
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText.h"
#import "TTBaseMacro.h"
#import "TTUGCEmojiParser.h"
#import "FHFeedUGCContentModel.h"
#import "FHFeedUGCCellModel.h"
#import "TTVFeedListItem.h"
#import "AWECommentModel.h"
#import "TTUGCAsyncLabel.h"

NS_ASSUME_NONNULL_BEGIN

#define defaultTruncationLinkURLString @"www.bytedance.contentTruncationLinkURLString"
#define kUGCPaddingLeft 20
#define kUGCPaddingRight 20

@interface FHUGCCellHelper : NSObject

+ (NSAttributedString *)truncationFont:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color;

+ (NSAttributedString *)truncationFont:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color linkUrl:(NSString *)linkUrl;

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model numberOfLines:(NSInteger)numberOfLines;
//感兴趣的小区使用
+ (void)setRichContent:(TTUGCAttributedLabel *)label content:(NSString *)content font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines color:(UIColor *)color;

+ (void)setRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

+ (void)setArticleRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width;

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model;

+ (void)setOriginRichContent:(TTUGCAsyncLabel *)label model:(FHFeedUGCCellModel *)model numberOfLines:(NSInteger)numberOfLines;

+ (void)setOriginContentAttributeString:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

+ (void)setVoteContentString:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

// UGC 新投票类型
+ (void)setUGCVoteContentString:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attrStr
                       withConstraints:(CGSize)size
                      maxNumberOfLines:(NSUInteger)maxLine
                limitedToNumberOfLines:(NSUInteger *)numberOfLines;

+ (NSAttributedString *)convertRichContentWithModel:(AWECommentModel *)model;

//cellModel转视频模型
+ (TTVFeedListItem *)configureVideoItem:(FHFeedUGCCellModel *)cellModel;

+ (TTImageInfosModel *)convertTTImageInfosModel:(FHFeedContentImageListModel *)imageModel;

+ (NSArray *)convertToImageUrls:(FHFeedContentImageListModel *)imageModel;

//小区问答
+ (void)setQuestionRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

+ (void)setAnswerRichContentWithModel:(FHFeedUGCCellModel *)model width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

////
+ (void)setAsyncRichContent:(TTUGCAsyncLabel *)label model:(FHFeedUGCCellModel *)model;

@end

NS_ASSUME_NONNULL_END
