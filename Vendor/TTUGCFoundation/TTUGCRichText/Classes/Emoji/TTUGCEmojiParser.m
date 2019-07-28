//
//  TTUGCEmojiParser.m
//  Article
//
//  Created by Jiyee Sheng on 5/15/17.
//
//

#import <CoreText/CoreText.h>
#import "TTUGCEmojiParser.h"
#import "TTUGCEmojiTextAttachment.h"
#import "TTUGCRichTextPodBridge.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTModuleBridge.h>
#import "YYCache.h"

@interface TTUGCEmoji : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *emojiId;
@property (nonatomic, strong) NSNumber *count;

@end

@implementation TTUGCEmoji

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeObject:self.emojiId forKey:@"emojiId"];
    [coder encodeObject:self.count forKey:@"count"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.key = [coder decodeObjectForKey:@"key"];
        self.emojiId = [coder decodeObjectForKey:@"emojiId"];
        self.count = [coder decodeObjectForKey:@"count"];
    }

    return self;
}

@end

typedef NS_ENUM(NSUInteger, TTUGCEmojiContext) {
    TTUGCEmojiCoreTextContext,
    TTUGCEmojiTextKitContext,
};

static CGFloat ascentCallback(void *ref) {
    TTUGCEmojiTextAttachment *textAttachment = (__bridge TTUGCEmojiTextAttachment *)ref;

    return textAttachment.emojiSize + textAttachment.descender;
}

static CGFloat descentCallback(void *ref) {
    TTUGCEmojiTextAttachment *textAttachment = (__bridge TTUGCEmojiTextAttachment *)ref;

    return textAttachment.descender;
}

static CGFloat widthCallback(void *ref) {
    TTUGCEmojiTextAttachment *textAttachment = (__bridge TTUGCEmojiTextAttachment *)ref;

    return textAttachment.coreTextImage.size.width / textAttachment.coreTextImage.size.height * textAttachment.emojiSize + textAttachment.padding * 2;
}

static void deallocationCallback(void *ref) {
    if (ref) {
        CFRelease((CFTypeRef)ref); // TTUGCEmojiTextAttachment
        ref = NULL;
    }
}

#define kTTUsedEmojisKey @"TTUsedEmojiKey"
#define kTTMostUsedEmojisKey @"TTMostUsedEmojiKey"
#define kTTUserExpressionConfigSortArrayKey @"TTUserExpressionConfigSortArrayKey"
#define kTTUserExpressionConfigEmojiDicKey @"TTUserExpressionConfigEmojiDicKey"
#define kTTUserExpressionConfigEmojiMappingKey @"TTUserExpressionConfigEmojiMappingKey"
#define kTTUserExpressionConfigRequestDateKey @"TTUserExpressionConfigRequestDateKey"
#define kTTUGCEmojiVersionKey @"TTUGCEmojiVersionKey"

#define kFHUGCEmojiCahcePathKey @"kFHUGCEmojiCahcePathKey"


NSString *const kTTUGCEmojiLinkReplacementText = @"[链接]";
NSString *const kTTUGCEmojiInactiveLinkReplacementText = @"[链接2]";
NSString *const kTTUGCEmojiImageReplacementText = @"[图片]";
//NSString *const kTTUGCEmojiMicroAppReplacementText = @"[小程序]";
//NSString *const kTTUGCEmojiInactiveMicroAppReplacementText = @"[小程序2]";

NSString *const kTTUGCEmojiDiggReplacementText = @"[点赞]";
NSString *const kTTUGCEmojiGoldVipReplacementText = @"[金V]";
NSString *const kTTUGCEmojiYellowVipReplacementText = @"[黄V]";
NSString *const kTTUGCEmojiBlueVipReplacementText = @"[蓝V]";
NSString *const kTTUGCEmojiShowMoreReplacementText = @"[查看更多]";
NSString *const kTTUGCEmojiManyPeopleReplacementText = @"[多人]";

static TTUGCEmojiParser *shareManager;
static NSRegularExpression *emojiRegex;

@interface TTUGCEmojiParser ()

@property (nonatomic, strong) NSArray <NSString *> *emojiSortArray;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *emojiDictionary;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *emojiMappingDictionary; // 用于微博、微信表情映射
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *customEmojiDictionary; // 仅供内部字符替换，实现诸如网页链接之类的需求

@property (nonatomic, strong)   YYCache       *emojiCache;

@end

@implementation TTUGCEmojiParser


+ (void)load
{
//    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.stringify" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//        NSAttributedString *text = (NSAttributedString *)[params valueForKey:@"stringifyText"];
//        NSString *result = nil;
//        if ([text isKindOfClass:[NSAttributedString class]]) {
//            result = [TTUGCEmojiParser stringify:text];
//        }
//        return result;
//    }];
//
//    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTUGCEmojiParser.parseInTextKitContext" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//        NSString *text = (NSString *)[params valueForKey:@"text"];
//        CGFloat fontSize = (CGFloat) [(NSNumber *)[params valueForKey:@"fontSize"] doubleValue];
//        NSAttributedString *result = nil;
//        if (!isEmptyString(text)) {
//            result = [TTUGCEmojiParser parseInTextKitContext:text fontSize:fontSize];
//        }
//        return result;
//    }];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
        NSString *emojiPattern = @"\\[[^ \\[\\]]+\\]"; // 表情文本正则表达式，形如 [微笑]
        emojiRegex = [NSRegularExpression regularExpressionWithPattern:emojiPattern
                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                 error:nil];
        [shareManager requestUpdateEmojiConfig];
        shareManager.customEmojiDictionary = @{
            kTTUGCEmojiLinkReplacementText : @"link",
            kTTUGCEmojiInactiveLinkReplacementText : @"link2",
            kTTUGCEmojiImageReplacementText : @"image",
            kTTUGCEmojiMicroAppReplacementText : @"ugc_tma",
            kTTUGCEmojiInactiveMicroAppReplacementText : @"ugc_tma2",
            kTTUGCEmojiDiggReplacementText : @"digg",
            kTTUGCEmojiGoldVipReplacementText : @"gold_vip",
            kTTUGCEmojiYellowVipReplacementText : @"yellow_vip",
            kTTUGCEmojiBlueVipReplacementText : @"blue_vip",
            kTTUGCEmojiShowMoreReplacementText : @"show_more",
            kTTUGCEmojiManyPeopleReplacementText : @"many_people",
        };
    });
    return shareManager;
}

- (void)requestUpdateEmojiConfig {
    [TTUGCRichTextPodBridge requestUpdateEmojiConfig:^(NSArray *emojiSort, NSDictionary *emojiDic, NSDictionary *emojiMapping) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (emojiSort != nil && emojiDic != nil && emojiMapping != nil ) {
                self.emojiSortArray = emojiSort;
                self.emojiDictionary = emojiDic;
                self.emojiMappingDictionary = emojiMapping;
            } else {
                //读取 bundle 里面的表情配置
                NSString *sortPlistFilePath = [TTUGCEmojiParser pathForFileName:@"emoji_sort"];
                NSArray *backupSortArray = [[NSArray alloc] initWithContentsOfFile:sortPlistFilePath];
                NSString *emojiPath = [TTUGCEmojiParser pathForFileName:@"emoji"];
                NSDictionary *backupEmojiDic = [[NSDictionary alloc] initWithContentsOfFile:emojiPath];
                NSString *emojiMappingPath = [TTUGCEmojiParser pathForFileName:@"emoji_mapping"];
                NSDictionary *backupEmojiMappingDic = [[NSDictionary alloc] initWithContentsOfFile:emojiMappingPath];

                self.emojiSortArray = backupSortArray;
                self.emojiDictionary = backupEmojiDic;
                self.emojiMappingDictionary = backupEmojiMappingDic;
            }
            [self.emojiCache setObject:self.emojiSortArray forKey:kTTUserExpressionConfigSortArrayKey];
            [self.emojiCache setObject:self.emojiDictionary forKey:kTTUserExpressionConfigEmojiDicKey];
            [self.emojiCache setObject:self.emojiMappingDictionary forKey:kTTUserExpressionConfigEmojiMappingKey];
        });
    }];
}

static NSString *const kUserExpressionConfigTimeInterval = @"tt_user_expression_config_time_interval";
+ (void)setUserExpressionConfigTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval == 0) {
        timeInterval = 8 * 60 * 60;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(timeInterval) forKey:kUserExpressionConfigTimeInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)userExpressionConfigTimeInterval {
    NSTimeInterval timeInterval = 8 * 60 * 60;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserExpressionConfigTimeInterval]) {
        timeInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserExpressionConfigTimeInterval] doubleValue];
    }
    return timeInterval;
}

- (NSDictionary<NSString *,NSString *> *)emojiDictionary {
    if (_emojiDictionary.count > 0) {
        return _emojiDictionary;
    }
    NSDictionary *emojiDic = (NSDictionary *)[self.emojiCache objectForKey:kTTUserExpressionConfigEmojiDicKey];
    if (emojiDic == nil) {
        NSString *emojiPath = [TTUGCEmojiParser pathForFileName:@"emoji"];
        emojiDic = [[NSDictionary alloc] initWithContentsOfFile:emojiPath];
        [self.emojiCache setObject:emojiDic forKey:kTTUserExpressionConfigEmojiDicKey];
    }
    _emojiDictionary = emojiDic;
    return emojiDic;
}

- (NSArray<NSString *> *)emojiSortArray {
    if (_emojiSortArray.count > 0) {
        return _emojiSortArray;
    }
    NSArray *emojiSort = (NSArray *)[self.emojiCache objectForKey:kTTUserExpressionConfigSortArrayKey];
    if (emojiSort == nil) {
        NSString *emojiPath = [TTUGCEmojiParser pathForFileName:@"emoji_sort"];
        emojiSort = [[NSArray alloc] initWithContentsOfFile:emojiPath];
        [self.emojiCache setObject:emojiSort forKey:kTTUserExpressionConfigSortArrayKey];
    }
    _emojiSortArray = emojiSort;
    return emojiSort;
}

- (NSDictionary<NSString *,NSString *> *)emojiMappingDictionary {
    if (_emojiMappingDictionary) {
        return _emojiMappingDictionary;
    }
    NSDictionary *emojiMappingDic = (NSDictionary *)[self.emojiCache objectForKey:kTTUserExpressionConfigEmojiMappingKey];
    if (emojiMappingDic == nil) {
        NSString *emojiPath = [TTUGCEmojiParser pathForFileName:@"emoji_mapping"];
        emojiMappingDic = [[NSDictionary alloc] initWithContentsOfFile:emojiPath];
        [self.emojiCache setObject:emojiMappingDic forKey:kTTUserExpressionConfigEmojiMappingKey];
    }
    _emojiMappingDictionary = emojiMappingDic;
    return emojiMappingDic;
}

- (YYCache *)emojiCache
{
    if (!_emojiCache) {
        _emojiCache = [YYCache cacheWithName:kFHUGCEmojiCahcePathKey];
    }
    return _emojiCache;
}

+ (NSArray <TTUGCEmojiTextAttachment *> *)top4EmojiTextAttachments {
    [TTUGCEmojiParser sharedManager];

    NSMutableArray *top4EmojiNames = [[NSMutableArray alloc] initWithCapacity:4];

    // 默认出 2, 7, 6, 21
    NSArray *defaultTop4EmojiNames = @[@"[爱慕]", @"[发怒]", @"[流泪]", @"[大笑]"];

    NSArray *mostUsedEmojis = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMostUsedEmojisKey];
    [top4EmojiNames addObjectsFromArray:mostUsedEmojis];

    // 用默认表情补全
    for (NSUInteger j = 0; j < 4; ++j) {
        if (top4EmojiNames.count < 4 && ![top4EmojiNames containsObject:defaultTop4EmojiNames[j]]) {
            [top4EmojiNames addObject:defaultTop4EmojiNames[j]];
        }
    }

    NSMutableArray *as = [[NSMutableArray alloc] init];
    for (NSString *plainText in top4EmojiNames) {
        TTUGCEmojiTextAttachment *at = [[TTUGCEmojiTextAttachment alloc] init];
        NSString *emojiId = [TTUGCEmojiParser sharedManager].emojiDictionary[plainText];

        at.idx = 1;
        at.imageName = [NSString stringWithFormat:@"emoji_%@", emojiId];
        at.plainText = plainText;
        at.padding = 1.f;

        [as addObject:at];
    }

    return [as copy];
}

+ (NSArray <TTUGCEmojiTextAttachment *> *)emojiTextAttachments {
    [TTUGCEmojiParser sharedManager];

    NSArray <NSString *> *sortArray = [[TTUGCEmojiParser sharedManager] emojiSortArray];//[[NSUserDefaults standardUserDefaults] objectForKey:kTTUserExpressionConfigSortArrayKey];
    if (!sortArray) {
        NSString *sortPlistFilePath = [self pathForFileName:@"emoji_sort"];
        sortArray = [[NSArray alloc] initWithContentsOfFile:sortPlistFilePath];
    }

    NSDictionary<NSString *, NSString *> *dic = [[TTUGCEmojiParser sharedManager] emojiDictionary];
    if (!dic) {
        NSString *emojiPlistFilePath = [self pathForFileName:@"emoji"];
        dic = [[NSDictionary alloc] initWithContentsOfFile:emojiPlistFilePath];
    }
    
    NSMutableArray *as = [[NSMutableArray alloc] init];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *imageName, BOOL *stop) {
        NSInteger idx = 0;
        NSUInteger value = [sortArray indexOfObject:imageName];
        if (value != NSNotFound) {
            idx = value + 1;
        } else {
            return;
        }

        TTUGCEmojiTextAttachment *at = [[TTUGCEmojiTextAttachment alloc] init];
        at.idx = idx;
        at.imageName = [NSString stringWithFormat:@"emoji_%@", imageName];
        at.plainText = key;
        at.padding = 1.f;

        [as addObject:at];
    }];

    // 根据 idx 排序
    // 排序数据结构，设置 idx 作为排序依据，排序结果输出到数组:
    // {微笑:1, 送心:2, 委屈:3}
    [as sortUsingComparator:^NSComparisonResult(TTUGCEmojiTextAttachment *att1, TTUGCEmojiTextAttachment *att2) {
        return att1.idx < att2.idx ? NSOrderedAscending : NSOrderedDescending;
    }];

    return [as copy];
}

+ (NSString *)stringify:(NSAttributedString *)attributedText {
    return [TTUGCEmojiParser stringify:attributedText ignoreCustomEmojis:NO];
}

+ (NSString *)stringify:(NSAttributedString *)attributedText ignoreCustomEmojis:(BOOL)ignoreCustomEmojis {
    if (!attributedText) return nil;

    NSMutableString *plainString = [NSMutableString stringWithString:attributedText.string];
    __block NSUInteger location = 0;

    [attributedText enumerateAttribute:NSAttachmentAttributeName
                               inRange:NSMakeRange(0, attributedText.length)
                               options:0
                            usingBlock:^(id value, NSRange range, __unused BOOL *stop) {
                                if (value && [value isKindOfClass:[TTUGCEmojiTextAttachment class]]) {
                                    for (int i = 0; i < range.length; ++i) { // 相同的 Emoji 合并返回
                                        NSString *plainText = ((TTUGCEmojiTextAttachment *) value).plainText;
                                        if (ignoreCustomEmojis && [TTUGCEmojiParser sharedManager].customEmojiDictionary[plainText]) {
                                            plainText = @"";
                                        }

                                        [plainString replaceCharactersInRange:NSMakeRange(range.location + location + i, 1)
                                                                   withString:plainText];
                                        location += plainText.length - 1;
                                    }
                                }
                            }];

    return [plainString copy];
}

+ (NSAttributedString *)parseInTextKitContext:(NSString *)text fontSize:(CGFloat)fontSize {
    return [[self class] parse:text context:TTUGCEmojiTextKitContext fontSize:fontSize];
}

+ (NSAttributedString *)parseInCoreTextContext:(NSString *)text fontSize:(CGFloat)fontSize {
    return [[self class] parse:text context:TTUGCEmojiCoreTextContext fontSize:fontSize];
}

+ (NSAttributedString *)parse:(NSString *)text context:(TTUGCEmojiContext)context fontSize:(CGFloat)fontSize {
    if (!text) return nil;

    [TTUGCEmojiParser sharedManager];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    UIFont *font = [UIFont systemFontOfSize:fontSize];

    NSArray *emojiMatches = [emojiRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    // 文本处理位置
    NSUInteger location = 0;
    for (NSTextCheckingResult *match in emojiMatches) {
        // 处理非表情 prefix 字符
        NSRange range = match.range;
        if (range.location != location) {
            NSString *substring = [text substringWithRange:NSMakeRange(location, range.location - location)];
            NSMutableAttributedString *prefixAttributedString = [[NSMutableAttributedString alloc] initWithString:substring];
            [attributedString appendAttributedString:prefixAttributedString];
        }

        // 处理下一段
        location = range.location + range.length;

        // 获取表情图片名字
        NSString *key = [text substringWithRange:range];
        NSString *imageName = [TTUGCEmojiParser sharedManager].emojiDictionary[key];

        // 判断是否是映射表情
        if (!imageName) {
            imageName = [TTUGCEmojiParser sharedManager].emojiMappingDictionary[key];
        }

        // 判断是否是自定义字符
        if (!imageName) {
            imageName = [TTUGCEmojiParser sharedManager].customEmojiDictionary[key];
        }

        if (!imageName) {
            // 处理非预制表情文本
            NSMutableAttributedString *plainAttributedString = [[NSMutableAttributedString alloc] initWithString:key];
            [attributedString appendAttributedString:plainAttributedString];
        } else {
            // 替换预制表情文本
            // 重设 Emoji 尺寸，同步页面字体大小设置
            TTUGCEmojiTextAttachment *emojiTextAttachment = [[TTUGCEmojiTextAttachment alloc] init];
            emojiTextAttachment.imageName = [NSString stringWithFormat:@"emoji_%@", imageName];
            emojiTextAttachment.fontSize = font.pointSize;
            emojiTextAttachment.descender = font.descender;
            emojiTextAttachment.padding = 1.f;
            emojiTextAttachment.plainText = key;
            [emojiTextAttachment coreTextImage]; // 预存储 UIImage

            if (context == TTUGCEmojiTextKitContext) {
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];
                [attributedString appendAttributedString:emojiAttributedString];
            } else if (context == TTUGCEmojiCoreTextContext) {
                CTRunDelegateCallbacks callbacks;
                memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));

                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocationCallback;

                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)emojiTextAttachment);
                unichar objectReplacementChar = 0xFFFC;
                NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
                NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
                CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef) space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
                CFRelease(delegate);

                [attributedString appendAttributedString:space];
            }
        }
    }

    // 处理非表情 suffix 字符
    if (location < text.length) {
        NSRange range = NSMakeRange(location, text.length - location);
        NSString *substring = [text substringWithRange:range];
        NSMutableAttributedString *suffixAttributeString = [[NSMutableAttributedString alloc] initWithString:substring];
        [attributedString appendAttributedString:suffixAttributeString];
    }

    return [attributedString copy];
}

+ (NSArray <NSValue *> *)parseEmojiRangeValues:(NSString *)text {
    if (!text) return nil;

    [TTUGCEmojiParser sharedManager];

    NSMutableArray *emojis = [[NSMutableArray alloc] init];
    NSArray *emojiMatches = [emojiRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    for (NSTextCheckingResult *match in emojiMatches) {
        // 获取表情图片名字，包含内部表情(如链接)
        NSString *key = [text substringWithRange:match.range];
        if ([TTUGCEmojiParser sharedManager].emojiDictionary[key] || [TTUGCEmojiParser sharedManager].emojiMappingDictionary[key] || [TTUGCEmojiParser sharedManager].customEmojiDictionary[key]) {
            [emojis addObject:[NSValue valueWithRange:match.range]];
        }
    }

    return [emojis copy];
}

+ (NSDictionary <NSString *, NSString *> *)parseEmojis:(NSString *)text {
    if (!text) return nil;

    [TTUGCEmojiParser sharedManager];

    NSMutableDictionary <NSString *, NSString *> *emojis = [[NSMutableDictionary alloc] init];
    NSArray *emojiMatches = [emojiRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    for (NSTextCheckingResult *match in emojiMatches) {
        // 获取表情图片名字
        NSString *key = [text substringWithRange:match.range];
        NSString *emojiId = [TTUGCEmojiParser sharedManager].emojiDictionary[key];
        if (emojiId) {
            emojis[emojiId] = key;
        }
    }

    return [emojis copy];
}

+ (void)markEmojisAsUsed:(NSDictionary <NSString *, NSString *> *)emojis {
    NSArray *mostUsedEmojis = [[NSUserDefaults standardUserDefaults] arrayForKey:kTTMostUsedEmojisKey];
    NSMutableArray *newMostUsedEmojis = [NSMutableArray arrayWithArray:mostUsedEmojis];

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTUsedEmojisKey];
    NSArray <TTUGCEmoji *> *usedEmojis = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray <TTUGCEmoji *> *newUsedEmojis = [NSMutableArray arrayWithArray:usedEmojis];

    NSMutableArray *uniqueEmojiIds = [NSMutableArray array];

    // 数组去重，单次提交多个表情只记一次
    for (NSString *emoji in emojis.allKeys) {
        if (![uniqueEmojiIds containsObject:emoji]) {
            [uniqueEmojiIds addObject:emoji];
        }
    }

    for (NSString *emojiId in uniqueEmojiIds) {
        TTUGCEmoji *aEmoji = nil;

        for (NSUInteger i = 0; i < usedEmojis.count; ++i) {
            TTUGCEmoji *emoji = usedEmojis[i];

            // 找到存在的 emoji
            if ([emoji.emojiId isEqualToString:emojiId]) {
                aEmoji = emoji;
                aEmoji.count = @(aEmoji.count.integerValue + 1);
            }
        }

        if (!aEmoji) {
            aEmoji = [[TTUGCEmoji alloc] init];
            aEmoji.key = emojis[emojiId];
            aEmoji.emojiId = emojiId;
            aEmoji.count = @1;

            [newUsedEmojis addObject:aEmoji];
        }

        // 达到 1 次就清零，并提到头部
        if (aEmoji.count.integerValue >= 1) {
            aEmoji.count = @0;

            if ([newMostUsedEmojis containsObject:aEmoji.key]) {
                [newMostUsedEmojis removeObject:aEmoji.key];
            }

            [newMostUsedEmojis insertObject:aEmoji.key atIndex:0];
        }
    }

    NSArray *top4MostUsedEmojis;
    if (newMostUsedEmojis.count > 4) {
        top4MostUsedEmojis = [newMostUsedEmojis subarrayWithRange:NSMakeRange(0, 4)];
    } else {
        top4MostUsedEmojis = [newMostUsedEmojis copy];
    }

    [[NSUserDefaults standardUserDefaults] setObject:top4MostUsedEmojis forKey:kTTMostUsedEmojisKey];
    NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:newUsedEmojis];
    [[NSUserDefaults standardUserDefaults] setObject:newData forKey:kTTUsedEmojisKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 方法用于处理NSBundle的转换

 @param fileName pod中的plist文件名
 @return 真实地址
 */
+ (NSString *)pathForFileName:(NSString*)fileName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUGCRichText" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [bundle pathForResource:fileName ofType:@"plist"];
    return path;
}

+ (BOOL)isCustomEmojiTextAttachment:(TTUGCEmojiTextAttachment *)attachment {
    NSString *plainText = attachment.plainText;
    if (plainText){
        return [plainText isEqualToString:kTTUGCEmojiLinkReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiInactiveLinkReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiImageReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiMicroAppReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiInactiveMicroAppReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiDiggReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiGoldVipReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiYellowVipReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiBlueVipReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiShowMoreReplacementText] ||
               [plainText isEqualToString:kTTUGCEmojiManyPeopleReplacementText];
    }
    return NO;
}
@end
