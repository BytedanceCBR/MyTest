//
//  TTNovelRecordManager.h
//  Article
//
//  Created by muhuai on 16/7/29.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"

@interface TTNovelRecordManager : NSObject

- (instancetype)initWithArticle:(Article *)article;

- (void)fetchPaidNovelIfNeed:(void(^)(NSError *, Article *))completion;

//设置这本小说最后一次读的章节.
+ (void)setLastestReadChapter:(NSString *)itemId inBook:(NSString *)bookId;

//没读过的小说 和 已读小说的last章节都返回YES
+ (BOOL)isLastReadChapter:(NSString *)itemId inBook:(NSString *)bookId;
@end
