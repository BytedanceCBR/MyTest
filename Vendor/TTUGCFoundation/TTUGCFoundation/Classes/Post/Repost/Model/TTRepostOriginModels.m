//
//  TTRepostOriginModels.m
//  Article
//
//  Created by jinqiushi on 2018/1/30.
//

#import "TTRepostOriginModels.h"
#import <Article.h>
#import <Thread.h>
#import <TTShortVideoModel.h>
#import <ExploreOriginalData.h>
#import <WDAnswerEntity.h>
#import <FRImageInfoModel.h>


@implementation TTRepostOriginArticle

- (instancetype)initWithArticle:(Article *)article {
    self = [super init];
    if (self) {
        self.groupID = [@(article.uniqueID) stringValue];
        self.itemID = article.itemID;
        self.title = article.title;
        self.userID = [article.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString([article.userInfo tt_stringValueForKey:@"name"])) {
            self.userName = [article.userInfo tt_stringValueForKey:@"name"];
        } else if (!isEmptyString([article.userInfo tt_stringValueForKey:@"screen_name"])) {
            self.userName = [article.userInfo tt_stringValueForKey:@"screen_name"];
        } else if (!isEmptyString(article.source)) {
            self.userName = article.source;
        }
        self.isVideo = article.hasVideo.boolValue;
        if (!isEmptyString(article.sourceAvatar)) {
            self.userAvatar = article.sourceAvatar;
        } else if (!isEmptyString([article.userInfo tt_stringValueForKey:@"avatar_url"])) {
            self.userAvatar = [article.userInfo tt_stringValueForKey:@"avatar_url"];
        } else if (!isEmptyString([article.mediaInfo tt_stringValueForKey:@"avatar_url"])) {
            self.userAvatar = [article.mediaInfo tt_stringValueForKey:@"avatar_url"];
        }
        self.isDeleted = [[article articleDeleted] boolValue];
        TTImageInfosModel *thumbImage = nil;
        if ([[article middleImageDict] count] > 0) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
        } else if ([[article largeImageDict] count] > 0) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
        } else if ([article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"].count > 0) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"]];
        }
        self.thumbImage = [[FRImageInfoModel alloc] initWithTTImageInfosModel:thumbImage];
        self.showOrigin = @(!self.isDeleted);
    }
    
    return self;
}

@end


@implementation TTRepostOriginThread

- (instancetype)initWithThread:(Thread *)thread {
    self = [super init];
    if (self) {
        self.threadID = thread.threadId;
        self.title = thread.title;
        self.content = thread.content;
        self.contentRichSpanJSONString = thread.contentRichSpanJSONString;
        self.userID = thread.userID;
        self.userName = thread.screenName;
        self.userAvatar = [thread.user tt_stringValueForKey:@"avatar_url"];
        self.isDeleted = thread.actionDataModel.hasDelete;
        FRImageInfoModel *thumbImage = nil;
        NSArray<FRImageInfoModel *> *thumbImageModels = [thread getThumbImageModels];
        if ([thumbImageModels count] > 0) {
            thumbImage = [thumbImageModels firstObject];
        }
        self.thumbImage = thumbImage;
        self.showOrigin = thread.showOrigin;
        self.showTips = thread.showTips;
    }
    return self;
}

@end


@implementation TTRepostOriginShortVideoOriginalData

- (instancetype)initWithShortVideoOriginalData:(ExploreOriginalData *)shortVideoOriginalData {
    TTShortVideoModel *shortVideo = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([shortVideoOriginalData respondsToSelector:NSSelectorFromString(@"shortVideo")]) {
        NSObject *shortVideoObject = [shortVideoOriginalData performSelector:NSSelectorFromString(@"shortVideo")];
#pragma clang diagnostic pop
        if ([shortVideoObject isKindOfClass:[TTShortVideoModel class]]) {
            shortVideo = (TTShortVideoModel *)shortVideoObject;
        }
    }
    return [self initWithShortVideoModel:shortVideo];
}

- (instancetype)initWithShortVideoModel:(TTShortVideoModel *)shortVideoModel {
    self = [super init];
    if (self) {
        self.shortVideoID = shortVideoModel.itemID;
        self.title = shortVideoModel.title;
        self.thumbImage = [[FRImageInfoModel alloc] initWithTTImageInfosModel:shortVideoModel.detailCoverImageModel];
        self.userID = shortVideoModel.author.userID;
        self.userName = shortVideoModel.author.name;
        self.userAvatar = shortVideoModel.author.avatarURL;
        self.showOrigin = shortVideoModel.showOrigin;
        self.showTips = shortVideoModel.showTips;
    }
    
    return self;
}

@end


@implementation TTRepostOriginTTWendaAnswer

- (instancetype)initWithAnswerEntity:(WDAnswerEntity *)answer {
    self = [super init];
    if (self) {
        self.wendaAnswerID = answer.ansid;
        self.title = answer.questionTitle;
        TTImageInfosModel *imageModel = nil;
        if (answer.thumbImageList && answer.thumbImageList.count > 0) {
            imageModel = answer.thumbImageList.firstObject;
        }
        else if (answer.contentThumbImageList && answer.contentThumbImageList.count > 0) {
            imageModel = answer.contentThumbImageList.firstObject;
        }
        if (imageModel) {
            self.thumbImage = [[FRImageInfoModel alloc] initWithTTImageInfosModel:imageModel];
        }
        self.userID = answer.user.userID;
        self.userName = answer.user.name;
        self.userAvatar = answer.user.avatarURLString;
        self.isDeleted = answer.answerDeleted;
        self.showOrigin = nil;
        self.showTips = nil;
    }
    
    return self;
}

@end
