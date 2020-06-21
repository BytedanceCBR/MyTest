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
    TTRichSpanLinkTypeImage = 5,
    TTRichSpanLinkTypeMicroApp = 6,
    TTRichSpanLinkTypeMicroGame = 7,
    
    //客户端使用的自定义的值写在此之后
    TTRichSpanLinkTypeQuotedCommentUser = 1000, // 评论回复作者, 客户端拼接
    TTRichSpanLinkTypeAutoDetectLink = 1001, // 客户端自动检测链接类型
};

typedef NS_ENUM (NSInteger, TTRichSpanLinkFlagType) {
    TTRichSpanLinkFlagTypeDefault = 0,
    TTRichSpanLinkFlagTypeHide = 1 << 0, // 隐藏整个富文本的显示，目前image在使用（见评论区里图片已经展示了，就不需要再显示查看图片）
    TTRichSpanLinkFlagTypeHideIcon = 1 << 1, // 隐藏 link image microApp microGame 前面的icon小图标
};

@interface TTRichSpanImage : NSObject

@property (nonatomic, strong) NSString *uri;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSString *format;

- (instancetype) initWithDictionary:(NSDictionary *)imageDictionary;

- (NSDictionary *)imageInfoDictionary;

@end

@interface TTRichSpanLink : NSObject

@property (nonatomic, assign, readonly) NSUInteger start;
@property (nonatomic, assign, readonly) NSUInteger length;
@property (nonatomic, copy, readonly) NSString *link;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, assign, readonly) TTRichSpanLinkType type;
@property (nonatomic, assign, readonly) TTRichSpanLinkFlagType flagType;
@property (nonatomic, strong, readonly) NSArray<TTRichSpanImage*> *imageInfoModels;

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, copy) NSString *idStr;


- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link;

- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text type:(TTRichSpanLinkType)type;

//新增的带图片信息的link类型，使用 已有 link 构造 新的link 时,必须调用此方法*********
- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text imageInfoModels:(NSArray<TTRichSpanImage*> *)imageInfoModels type:(TTRichSpanLinkType)type flagType:(TTRichSpanLinkFlagType)flagType;

//新增的带图片信息的link类型
- (instancetype)initWithStart:(NSUInteger)start length:(NSUInteger)length link:(NSString *)link text:(NSString *)text imageInfoDicts:(NSArray<NSDictionary *> *)imageInfoDicts type:(TTRichSpanLinkType)type flagType:(TTRichSpanLinkFlagType)flagType;

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

@class TTRichTextImageInfoModel;

@interface TTRichSpans : NSObject

@property (nonatomic, strong, readonly) NSArray<TTRichSpanLink *> *links;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, TTRichTextImageInfoModel *> *imageInfoModesDict;

- (instancetype)initWithRichSpanLinks:(NSArray<TTRichSpanLink *> *)links imageInfoModelsDict:(NSDictionary<NSString *, TTRichTextImageInfoModel *> *)imageInfoModeDict;

- (NSArray<TTRichTextImageInfoModel *> *)imageInfoModelArray;

- (TTRichTextImageInfoModel *)imageInfoModelWithURI:(NSString *)imageUri;

- (NSArray<TTRichTextImageInfoModel *> *)imageInfoModelArrayWithRichSpanLink:(TTRichSpanLink *)richSpanLink;

+ (NSDictionary *)dictionaryForRichSpans:(TTRichSpans *)richSpans;
+ (NSString *)JSONStringForRichSpans:(TTRichSpans *)richSpans;

+ (TTRichSpans *)richSpansForDictionary:(NSDictionary *)dictionary;
+ (TTRichSpans *)richSpansForJSONString:(NSString *)JSONString;

+ (NSString *)filterValidRichSpanString:(NSString *)richSpanString;

+ (NSInteger)richSpanCountRichSpans:(TTRichSpans *)richSpans forRichSpanLinkType:(TTRichSpanLinkType)linkType;

+ (BOOL)richSpanJsonStringHasImageInfoLink:(NSString *)jsonString;


@end

@interface TTRichSpanText : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, strong, readonly) TTRichSpans *richSpans;
- (NSString *)base64EncodedString;
- (instancetype)initWithBase64EncodedString:(NSString *)base64String;
- (instancetype)initWithText:(NSString *)text richSpansJSONString:(NSString *)richSpansJSONString;
- (instancetype)initWithText:(NSString *)text richSpans:(TTRichSpans *)richSpans;
//- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links;

- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links imageInfoModelDictionary:(NSDictionary<NSString *, TTRichTextImageInfoModel *> *)imageInfoModelDictionary;
- (instancetype)initWithText:(NSString *)text richSpanLinks:(NSArray <TTRichSpanLink *>*)links imageInfoModelArray:(NSArray<TTRichTextImageInfoModel *> *)imageInfoModelArray;

- (void)appendRichSpanText:(TTRichSpanText *)aRichSpanText;
- (void)insertRichSpanText:(TTRichSpanText *)aRichSpanText atIndex:(NSUInteger)atIndex;
- (void)appendText:(NSString *)aText;
- (void)insertText:(NSString *)aText atIndex:(NSUInteger)atIndex;
+ (NSInteger)richSpanCountRichSpanText:(TTRichSpanText *)richSpanText forRichSpanLinkType:(TTRichSpanLinkType)linkType;
+ (NSInteger)richSpanCountWithContentString:(NSString *)contentString richSpanString:(NSString *)richSpanString forRichSpanLinkType:(TTRichSpanLinkType)linkType;
+ (BOOL)richSpanJsonStringHasImageInfoWithContentString:(NSString *)contentString richSpanString:(NSString *)richSpanString;


/**
 * 替换内容
 * @param range 位置
 * @param aText 文本
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

/**
 * 会根据range进行links排序
 */
- (NSArray <TTRichSpanLink *> *)sortedRichSpanLinks:(NSArray <TTRichSpanLink *> *)richSpanLinks;
@end


@interface  TTRichTextImageURLInfoModel : NSObject
@property (strong, nonatomic) NSString *url;
@end

@interface TTRichTextImageInfoModel : NSObject

@property (assign, nonatomic) int64_t height;
@property (assign, nonatomic) int64_t width;
@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray<TTRichTextImageURLInfoModel *>* url_list;
@property (assign, nonatomic) int type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;

@end
