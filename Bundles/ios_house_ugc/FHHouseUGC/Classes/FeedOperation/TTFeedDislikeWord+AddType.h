//
//  TTFeedDislikeWord+AddType.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/16.
//

#import "TTFeedDislikeWord.h"

typedef NS_ENUM(NSUInteger, TTFeedDislikeWordType) {
    TTFeedDislikeWordTypeOthers = 0, // 取消关注来源
    TTFeedDislikeWordTypeCategory1 = 1, // 屏蔽
    TTFeedDislikeWordTypeCategory2 = 2, // 屏蔽
    TTFeedDislikeWordTypeCategory3 = 3, // 屏蔽
    TTFeedDislikeWordTypeCategory4 = 4, // 屏蔽
    TTFeedDislikeWordTypeSource = 5, // 拉黑来源
    TTFeedDislikeWordTypeKeyword = 6, // 屏蔽
    TTFeedDislikeWordTypeLabledTopic = 7, // 低俗/标题党复用一个
    TTFeedDislikeWordTypeDuplicaton = 8, // 看过了
    TTFeedDislikeWordTypeQuality = 9, // 太水了
};

@interface TTFeedDislikeWord (AddType)
@property (nonatomic, readonly) TTFeedDislikeWordType type;
@end
