//
//  TTRepostOriginModels.h
//  Article
//
//  Created by jinqiushi on 2018/1/30.
//  几个自定义的用于转发的类。对应于article等等等

#import <Foundation/Foundation.h>

@class Article, Thread, FRImageInfoModel, TSVShortVideoOriginalData, WDAnswerEntity, TTShortVideoModel;


@interface TTRepostOriginArticle : NSObject

@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) FRImageInfoModel *thumbImage;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, strong) NSNumber *showOrigin;
@property (nonatomic, copy) NSString *showTips;

- (instancetype)initWithArticle:(Article *)article;

@end

@interface TTRepostOriginThread : NSObject

@property (nonatomic, copy) NSString *threadID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentRichSpanJSONString;
@property (nonatomic, strong) FRImageInfoModel *thumbImage;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, strong) NSNumber *showOrigin;
@property (nonatomic, copy) NSString *showTips;

- (instancetype)initWithThread:(Thread *)thread;

@end

@interface TTRepostOriginShortVideoOriginalData : NSObject

@property (nonatomic, copy) NSString *shortVideoID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) FRImageInfoModel *thumbImage;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, strong) NSNumber *showOrigin;
@property (nonatomic, copy) NSString *showTips;

- (instancetype)initWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData;
- (instancetype)initWithShortVideoModel:(TTShortVideoModel *)shortVideoModel;

@end

@interface TTRepostOriginTTWendaAnswer : NSObject

@property (nonatomic, copy) NSString *wendaAnswerID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) FRImageInfoModel *thumbImage;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, assign) BOOL isDeleted;       // 是否被删的
@property (nonatomic, strong) NSNumber *showOrigin; // 是否可能被封禁，问答暂时不会
@property (nonatomic, copy) NSString *showTips;

- (instancetype)initWithAnswerEntity:(WDAnswerEntity *)answer;

@end
