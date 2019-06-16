//
//  TTFeedDislikeOption.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/13.
//

#import <Foundation/Foundation.h>
#import "TTFeedDislikeWord.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTFeedDislikeOptionType) {
    TTFeedDislikeOptionTypeUnfollow = 0,
    TTFeedDislikeOptionTypeUninterest,
    TTFeedDislikeOptionTypeReport,
    TTFeedDislikeOptionTypeFeedback,
    TTFeedDislikeOptionTypeSource,
    TTFeedDislikeOptionTypeShield,
    TTFeedDislikeOptionTypeCommand
};


@interface TTFeedReportWord : TTFeedDislikeWord
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end


@interface TTFeedDislikeOption : NSObject

@property (nonatomic) TTFeedDislikeOptionType type;
@property (nonatomic, strong) NSArray<TTFeedDislikeWord *> *words;

+ (TTFeedDislikeOptionType)optionTypeForKeyword:(TTFeedDislikeWord *)keyword;

- (NSString *)strForSubTitleWithKeywords;

@end

NS_ASSUME_NONNULL_END
