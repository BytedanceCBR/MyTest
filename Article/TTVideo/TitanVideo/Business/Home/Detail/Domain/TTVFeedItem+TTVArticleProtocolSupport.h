//
//  TTVFeedItem+TTVArticleProtocolSupport.h
//  Article
//
//  Created by pei yun on 2017/4/9.
//
//

#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTVArticleProtocol.h"
#import "Article.h"
@class ArticleDetail;
@interface TTVFeedItem (TTVArticleProtocolSupport) <TTVArticleProtocol>

@property (nonatomic, assign, readonly) int64_t uniqueID;

@property (nonatomic, copy, readonly) NSString *itemID;
@property (nonatomic, strong, readonly) NSNumber * groupFlags;
@property (nonatomic, retain, readonly) NSNumber *aggrType;
@property (nonatomic, assign, readonly) int       articleType;
@property (nonatomic, retain, readonly) NSNumber *natantLevel;
@property (nonatomic, retain, readonly) NSNumber     *videoType;
@property (nonatomic, retain, readonly) NSNumber       *articleDeleted;
@property (nonatomic, assign) int buryCount;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) int diggCount;
@property (nonatomic, assign) BOOL userBury;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL userRepined;
@property (nonatomic, assign, readonly) BOOL banComment;
@property (nonatomic, assign, readonly) BOOL hasImage;
@property (nonatomic, strong, readonly) NSNumber *detailVideoProportion;
@property (nonatomic, retain, readonly) NSDictionary   *comment;
@property (nonatomic, strong, readonly) NSDictionary *relatedVideoExtraInfo;
@property (nonatomic, retain, readonly) NSDictionary *videoDetailInfo;
@property (nonatomic, assign, readonly) BOOL detailShowPortrait;
@property (nonatomic, copy, readonly) NSString *videoLocalURL;

@property (nonatomic, retain, readonly) NSString     *videoID;
@property (nonatomic, retain, readonly) NSString       *title;
@property (nonatomic, retain, readonly) NSDictionary *largeImageDict;
@property (nonatomic, retain, readonly) NSDictionary *videoPlayInfo;
@property (nonatomic, retain, readonly) NSNumber     *videoDuration;
@property (nonatomic, retain, readonly) NSDictionary *videoExtendLink;
@property (nonatomic, retain, readonly) NSDictionary *mediaInfo NS_DEPRECATED_IOS(2_0, 11_0, "Use userInfo.");//订阅号信息
@property (nonatomic, strong, readonly) NSDictionary *detailMediaInfo NS_DEPRECATED_IOS(2_0, 11_0, "Use userInfo.");//详情页订阅号信息，非持久化，用于视频专题 add by 5.5
@property (nonatomic, strong, readonly) NSDictionary *userInfo;
@property (nonatomic, strong, readonly) NSDictionary *detailUserInfo NS_DEPRECATED_IOS(2_0, 11_0, "Use userInfo.");
@property (nonatomic, retain, readonly) NSArray        *zzComments;// 转载

@property (nonatomic, retain, readonly) TTAdVideoRelateAdModel *videoAdExtra;

@property (nonatomic, strong, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *mediaUserID;

@property (nonatomic, strong, readonly) ArticleDetail *detail;
@property (nonatomic, retain, readonly) NSNumber       *isOriginal;
@property (nonatomic, assign, readonly) double articlePublishTime;
@property (nonatomic, retain, readonly) NSNumber *banBury;
@property (nonatomic, retain, readonly) NSNumber *banDigg;

@property (nonatomic, assign, readonly) NSUInteger preloadWeb;
@property (nonatomic, strong, readonly) NSString *displayURL;
@property (nonatomic, retain, readonly) NSString *articleURLString;
@property (nonatomic, retain, readonly) id<TTAdFeedModel> adModel;
@property (nonatomic, strong, readonly) NSDictionary *h5Extra;
@property (nonatomic, strong, readonly) NSDictionary *logPbDic;
@property (nonatomic, strong, readonly) NSArray *commoditys;

- (NSString *)articleDetailContent;
- (TTGroupModel *)groupModel;
- (NSString *)firstZzCommentMediaId;
- (BOOL)isVideoSourceUGCVideoOrHuoShan;
- (BOOL)isVideoSourceHuoShan;
- (BOOL)isVideoSourceUGCVideo;
- (NSString *)zzCommentsIDString;
- (NSString *)videoSubjectID;
- (BOOL)shouldDirectShowVideoSubject;
- (BOOL)directPlay;
- (NSString *)relatedLogExtra;
- (BOOL)hasVideoSubjectID;
- (BOOL)hasVideoPlayInfoUrl;
- (BOOL)isVideoUrlValid;
- (NSString *)videoIDOfVideoDetailInfo;   //1576行
- (BOOL)showExtendLink;
- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative;
- (instancetype)managedObjectContext;
- (BOOL)isImageSubject;
- (void)updateFollowed:(BOOL)followed;

- (Article *)ttv_convertedArticle;
@end
