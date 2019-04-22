//
//  TTNovelRecordManager.m
//  Article
//
//  Created by muhuai on 16/7/29.
//
//

#import "TTNovelRecordManager.h"
#import "NewsFetchArticleDetailManager.h"
#import "ArticleURLSetting.h"

#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTNetworkManager/TTNetworkManager.h>

typedef enum : NSUInteger {
    TTNovelStatusFree,
    TTNovelStatusPaid,
    TTNovelStatusTempFree,
} TTNovelStatus;

@interface TTNovelRecordManager()

@property (nonatomic, strong) Article *article;
@property (nonatomic, readwrite) Article *paidNovelArticle;

@end

@implementation TTNovelRecordManager

- (instancetype)initWithArticle:(Article *)article {
    self = [self init];
    if (self) {
        _article = article;
    }
    return self;
}

- (void)fetchPaidNovelIfNeed:(void(^)(NSError *, Article *))completion {
    if (![self isPaidNovel]) {
        return;
    }
    
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    NSString *host = [ArticleURLSetting detailPaidNovelFullURLString];
    NSString *version = [ArticleURLSetting detailCDNAPIVersionString];
    NSString *platform = [TTDeviceHelper isPadDevice] ? @"4" : @"2";
    NSString *url = [NSString stringWithFormat:@"%@%@/%@/%@/%@/%ld/", host, version, platform, self.article.groupModel.groupID, self.article.groupModel.itemID, (long)self.article.groupModel.aggrType];
    __weak __typeof(self)weakSelf = self;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        Article *novelArticle;
        
        if (!strongSelf) {
            return;
        }
        
        if (!error) {
            novelArticle = [[Article alloc] init];
            [novelArticle updateWithDictionary:[jsonObj tt_dictionaryValueForKey:@"data"]];
            novelArticle.primaryID = [Article primaryIDByUniqueID:[novelArticle.groupModel.groupID longLongValue] itemID:novelArticle.itemID adID:@"999"]; //在原有的primaryID上追加999, 以免和正常小说串数据
            novelArticle.isSubscribe = strongSelf.article.isSubscribe; //p_full接口不会返回关注态..后端没时间加,客户端先兼容了..
            if (novelArticle.detail.content.length <= 0) {
                novelArticle = nil;
            }
            strongSelf.paidNovelArticle = novelArticle;
        }
        
        if (completion) {
            completion(error, novelArticle);
        }
    }];
}

+ (void)setLastestReadChapter:(NSString *)itemId inBook:(NSString *)bookId {
    if (isEmptyString(itemId) || isEmptyString(bookId)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:itemId forKey:bookId];
}

+ (BOOL)isLastReadChapter:(NSString *)itemId inBook:(NSString *)bookId {
    if (isEmptyString(itemId) || isEmptyString(bookId)) {
        return NO;
    }
    NSString *lastChapter = [[NSUserDefaults standardUserDefaults] stringForKey:bookId];
    if (isEmptyString(lastChapter) || [lastChapter isEqualToString:itemId]) {
        //没读过的小说 和 已读小说的last章节都返回YES
        return YES;
    }
    return NO;
}

- (BOOL)isPaidNovel {
    if (![self isNovel]) {
        return NO;
    }
    
    TTNovelStatus bookStatus = [self.article.novelData tt_integerValueForKey:@"book_free_status"];
    
    return bookStatus != TTNovelStatusFree;
}

- (BOOL)isNovel {
    return self.article.novelData.count > 0;
}
@end
