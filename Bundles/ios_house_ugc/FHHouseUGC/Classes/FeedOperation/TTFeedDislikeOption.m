//
//  TTFeedDislikeOption.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/13.
//

#import "TTFeedDislikeOption.h"
#import "TTFeedDislikeWord.h"
#import "TTFeedDislikeWord+AddType.h"
#import "FHFeedOperationView.h"
#import "TTBaseMacro.h"

@implementation TTFeedReportWord

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.ID = [NSString stringWithFormat:@"%@", dict[@"type"]];
        self.name = dict[@"text"];
    }
    return self;
}

@end


@implementation TTFeedDislikeOption

+ (TTFeedDislikeOptionType)optionTypeForKeyword:(TTFeedDislikeWord *)keyword {
    if ([keyword conformsToProtocol:@protocol(TTFeedDislikeCommand)]) {
        return TTFeedDislikeOptionTypeCommand;
    }
    if ([keyword isMemberOfClass:[TTFeedReportWord class]]) {
        return TTFeedDislikeOptionTypeReport;
    }
    
    switch (keyword.type) {
        case TTFeedDislikeWordTypeOthers:
            return TTFeedDislikeOptionTypeUnfollow;
        case TTFeedDislikeWordTypeCategory1:
        case TTFeedDislikeWordTypeCategory2:
        case TTFeedDislikeWordTypeCategory3:
        case TTFeedDislikeWordTypeCategory4:
        case TTFeedDislikeWordTypeKeyword:
            return TTFeedDislikeOptionTypeShield;
        case TTFeedDislikeWordTypeSource:
            return TTFeedDislikeOptionTypeSource;
        case TTFeedDislikeWordTypeLabledTopic:
        case TTFeedDislikeWordTypeDuplicaton:
        case TTFeedDislikeWordTypeQuality:
            return TTFeedDislikeOptionTypeFeedback;
    }
}

- (NSString *)strForSubTitleWithKeywords {
    NSMutableString *str = [NSMutableString string];
    int i = 0;
    for (TTFeedDislikeWord *w in self.words) {
        if (i > 0 && i < 2) {
            [str appendString:@"、"];
        } else if (i == 2) {
            [str appendString:@"等"];
            break;
        }
        if (!isEmptyString(w.name)) {
            NSString *name = w.name;
            if (self.type == TTFeedDislikeOptionTypeShield) {
                NSString *header = @"不想看:";
                NSRange r = [name rangeOfString:header];
                if (r.location == 0) {
                    name = [name stringByReplacingCharactersInRange:r withString:@""];
                }
            }
            [str appendString:name];
            i++;
        }
    }
    return [str copy];
}

@end
