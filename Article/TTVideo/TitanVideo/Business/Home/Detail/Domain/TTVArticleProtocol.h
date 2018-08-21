//
//  TTVArticleProtocol.h
//  Article
//
//  Created by pei yun on 2017/4/9.
//
//

#ifndef TTVArticleProtocol_h
#define TTVArticleProtocol_h

#import "TTGroupModel.h"
#import "TTAdFeedDefine.h"

extern NSArray *ttv_propertyNamesInProtocol(NSString *protocolName);

@class ArticleDetail;
@class Article;
@class TTAdVideoRelateAdModel;
@protocol TTVArticleProtocol <NSObject>

@property (nonatomic, assign, readonly) int64_t uniqueID;

@property (nonatomic, copy, readonly) NSString *itemID;
@property (nonatomic, copy, readonly) NSString *adIDStr;
@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy, readonly) NSString *sourceAvatar;
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
@property (nonatomic, retain, readonly) NSDictionary *mediaInfo;//订阅号信息
@property (nonatomic, strong, readonly) NSDictionary *detailMediaInfo;//详情页订阅号信息，非持久化，用于视频专题 add by 5.5
@property (nonatomic, strong, readonly) NSDictionary *userInfo;
@property (nonatomic, strong, readonly) NSDictionary *detailUserInfo;
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
@property (nonatomic, retain, readonly) NSString *shareURL;
@property (nonatomic, strong, readonly) NSString *displayURL;
@property (nonatomic, retain, readonly) NSString *articleURLString;
@property (nonatomic, retain, readonly) id<TTAdFeedModel> adModel;
@property (nonatomic, strong, readonly) NSDictionary *h5Extra;
@property (nonatomic, strong, readonly) NSDictionary *novelData;
@property (nonatomic, strong, readonly) NSArray *commoditys;

- (NSDictionary *)rawAdData;
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

#endif /* TTVArticleProtocol_h */
