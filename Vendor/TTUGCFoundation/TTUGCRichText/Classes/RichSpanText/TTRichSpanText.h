//
//  TTRichSpanText.h
//  Article
//
//  Created by 徐霜晴 on 17/3/13.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM (NSInteger, TTRichSpanLinkType) {
    TTRichSpanLinkTypeUnknown = 0,
    TTRichSpanLinkTypeAt = 1,
    TTRichSpanLinkTypeHashtag = 2,
    TTRichSpanLinkTypeLink = 3,

    //客户端使用的自定义的值写在此之后
    TTRichSpanLinkTypeQuotedCommentUser = 1000, // 评论回复作者, 客户端拼接
    TTRichSpanLinkTypeAutoDetectLink = 1001, // 客户端自动检测链接类型
};

@interface TTRichSpanLink : NSObject

@property (nonatomic, assign, readonly) NSUInteger start;
@property (nonatomic, assign, readonly) NSUInteger length;
@property (nonatomic, copy, readonly) NSString *link;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, assign, readonly) TTRichSpanLinkType type;

@property (nonatomic, strong) NSDictionary *userInfo; // 仅供临时读写使用，不作为持久化字段

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link;

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text type:(TTRichSpanLinkType)type;

/*
 * RichSpan和dictionary的转换
 */
+ (NSDictionary *)dictionaryForRichSpanLink:(TTRichSpanLink *)link;
+ (NSArray<NSDictionary *> *)arrayForRichSpanLinks:(NSArray<TTRichSpanLink *> *)links;
+ (NSString *)JSONStringForRichSpanLinks:(NSArray<TTRichSpanLink *> *)links;

+ (TTRichSpanLink *)richSpanLinkForDictionary:(NSDictionary *)dictionary;
+ (NSArray<TTRichSpanLink *> *)richSpanLinksForDictionaries:(NSArray<NSDictionary *>*)linkDictionaries;
+ (NSArray<TTRichSpanLink *> *)richSpanLinksForJSONString:(NSString *)linksJSONString;


@end

@interface TTRichSpans : NSObject

@property (nonatomic, strong, readonly) NSArray<TTRichSpanLink *> *links;

- (instancetype)initWithRichSpanLinks:(NSArray<TTRichSpanLink *> *)links;

+ (NSDictionary *)dictionaryForRichSpans:(TTRichSpans *)richSpans;
+ (NSString *)JSONStringForRichSpans:(TTRichSpans *)richSpans;

+ (TTRichSpans *)richSpansForDictionary:(NSDictionary *)dictionary;
+ (TTRichSpans *)richSpansForJSONString:(NSString *)JSONString;

+ (NSString *)filterValidRichSpanString:(NSString *)richSpanString;

+ (NSInteger)richSpanCountRichSpans:(TTRichSpans *)richSpans forRichSpanLinkType:(TTRichSpanLinkType)linkType;

@end

@interface TTRichSpanText : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, strong, readonly) TTRichSpans *richSpans;

- (instancetype)initWithText:(NSString *)text richSpansJSONString:(NSString *)richSpansJSONString;
- (instancetype)initWithText:(NSString *)text richSpans:(TTRichSpans *)richSpans;
- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links;

- (void)appendRichSpanText:(TTRichSpanText *)aRichSpanText;
- (void)insertRichSpanText:(TTRichSpanText *)aRichSpanText atIndex:(NSUInteger)atIndex;
- (void)appendText:(NSString *)aText;
- (void)insertText:(NSString *)aText atIndex:(NSUInteger)atIndex;

/**
 * 替换内容
 * @param range
 * @param aText
 * @return brokenLinks
 */
- (NSArray <TTRichSpanLink *> *)replaceCharactersInRange:(NSRange)range withText:(NSString *)aText;

- (void)trimmingCharactersInSet:(NSCharacterSet *)characterSet;
- (void)trimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (void)trimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

/**
 *  将富文本中的第一个startIndex对应的hashtag去掉，小视频变态需求
 */
- (void)trimmingHashtagsWithStartIndex:(NSInteger)startIndex;

/**
 * 会检测 text 中的超链接，并自动增加在 richSpans 中
 */
- (void)detectAndAddLinks;
@end
