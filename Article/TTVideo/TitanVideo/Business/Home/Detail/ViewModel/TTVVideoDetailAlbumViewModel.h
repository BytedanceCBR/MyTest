//
//  TTVVideoDetailAlbumViewModel.h
//  Article
//
//  Created by lishuangyang on 2017/6/19.
//
//

#import <Foundation/Foundation.h>
#import <TTVideoService/VideoInformation.pbobjc.h>
#import "TTVArticleProtocol.h"

#define kEntityId           @"entity_id"
#define kEntityText         @"entity_text"
#define kEntityWord         @"entity_word"
#define kEntityScheme       @"entity_scheme"
#define kEntityFollowed     @"entity_followed"
#define kEntityStyle        @"entity_style"
#define kEntityMark         @"entity_mark"
#define kEntityConcernID    @"concern_id"

typedef void(^TTAlbumFetchCompletion)(NSArray *albumItems, NSError *error);

@interface TTVVideoDetailAlbumViewModel : NSObject

@property (nonatomic, strong) TTVRelatedItem *item;
@property (nonatomic, strong) id<TTVArticleProtocol> currentPlayingArticle;
@property (nonatomic, copy) TTAlbumFetchCompletion didFetchedAlbums;
@property (nonatomic, copy) NSArray *albumItems;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, assign) BOOL reloadFlag;
@property (nonatomic, strong)NSDictionary *logPb;

- (void)fetchAlbumsWithURL:(NSString *)url completion:(TTAlbumFetchCompletion)completion;

@end

@interface TTVVideoDetailAlbumModel: JSONModel<TTVArticleProtocol>

@property (nonatomic, assign) int diggCount;
@property (nonatomic, strong) NSNumber * groupFlags;
@property (nonatomic, strong) NSNumber * hasRead;
@property (nonatomic, strong) NSNumber * likeCount;
@property (nonatomic, strong) NSString * likeDesc;
@property (nonatomic, strong) NSNumber * notInterested;
@property (nonatomic, strong) NSNumber * repinCount;
@property (nonatomic, strong) NSString * shareURL;
@property (nonatomic, assign) BOOL userBury;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL userRepined;
@property (nonatomic, strong) NSNumber * userRepinTime;
@property (nonatomic, strong) NSDictionary   *embededAdInfo;
@property (nonatomic, strong) NSString       *adPromoter;
@property (nonatomic, strong) NSNumber *aggrType;     //
@property (nonatomic, strong) NSNumber *articlePosition;
@property (nonatomic, strong) NSString       *articleURLString;
@property (nonatomic, assign) BOOL                     banComment;
@property (nonatomic, assign) int buryCount;
@property (nonatomic, strong) NSString       *cacheToken;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, strong) NSNumber       *articleDeleted;
@property (nonatomic, strong) NSNumber       *detailNoComments;
@property (nonatomic, strong) NSString       *displayTitle;
@property (nonatomic, strong) NSString       *displayURL;
@property (nonatomic, strong) NSNumber *gallaryFlag;
@property (nonatomic, strong) NSNumber *gallaryImageCount;
@property (nonatomic, strong) NSArray        *galleries;
@property (nonatomic, strong) NSNumber       *goDetailCount;
@property (nonatomic, strong) NSNumber       *groupType;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, strong) NSNumber       *hasVideo;
@property (nonatomic, strong) NSNumber       *ignoreWebTranform;
@property(nonatomic, copy) NSString * infoDesc;
@property (nonatomic, strong) NSNumber       *isOriginal;
@property (nonatomic, strong) NSNumber *isSubscribe;
@property (nonatomic, strong) NSString     *mediaName;
@property (nonatomic, strong) NSNumber *natantLevel;
@property (nonatomic, strong) NSDictionary *novelData;
@property (nonatomic, strong) NSString       *openURL;
@property (nonatomic) double articlePublishTime;
@property (nonatomic, strong) NSString *recommendReason;
@property (nonatomic, copy) NSString * schema;
@property (nonatomic, assign) BOOL showPortrait;
@property (nonatomic, assign) BOOL detailShowPortrait;
@property (nonatomic, copy) NSString *sourceAvatar;
@property (nonatomic, copy) NSString *sourceOpenUrl;
@property (nonatomic, copy) NSString *sourceDesc;
@property (nonatomic, copy) NSString *sourceDescOpenUrl;
@property (nonatomic) NSNumber *sourceIconStyle;
@property (nonatomic, copy) NSString       *subtitle;
@property (nonatomic, strong) NSNumber *topicGroupId;
@property (nonatomic, strong) NSString       *tcHeadText;
@property (nonatomic, strong) NSDictionary *ugcInfo;
@property (nonatomic, strong) NSString       *sourceURL;
@property (nonatomic, strong) NSDictionary *userRelation;
@property (nonatomic, strong) NSNumber     *videoDuration;
@property (nonatomic, strong) NSString     *videoID;
@property (nonatomic, copy) NSString *videoLocalURL;
@property (nonatomic, strong) NSNumber *videoProportion;
@property (nonatomic, strong) NSNumber *detailVideoProportion;
@property (nonatomic, copy) NSString *videoSource;
@property (nonatomic, strong) NSNumber *share_count;
@property (nonatomic, strong) NSNumber *showOrigin;
@property (nonatomic, strong) NSString *showTips;
@property (nonatomic, strong) NSNumber *banBury;
@property (nonatomic, strong) NSNumber *banDigg;
@property (nonatomic, strong) NSDictionary   *forwardInfo;


@property (nonatomic, strong) NSNumber * hasShown;
@property (nonatomic, strong) NSNumber * showAddForum;
@property (nonatomic) int64_t uniqueID;
@property (nonatomic, strong) NSSet *orderedData;
@property (nonatomic, strong) NSNumber * userLike;
@property (nonatomic) double requestTime;
@property (nonatomic, assign) BOOL needRefreshUI;
@property (nonatomic, copy) NSString       *primaryID;
@property (nonatomic, copy) NSString       *content;
@property (nonatomic) double updateTime;
@property (nonatomic, strong) NSString       *abstract;
@property (nonatomic, strong) NSDictionary   *comment;
@property (nonatomic, strong) NSArray        *comments;
@property (nonatomic, strong) NSArray        *zzComments;
@property (nonatomic, strong) NSString       *imageDetailListString;
@property (nonatomic, strong) NSString       *keywords;
@property (nonatomic, strong) NSArray        *filterWords;
@property (nonatomic, copy  ) NSString *itemID;
@property (nonatomic, strong, readonly) id<TTAdFeedModel> adModel;
@property (nonatomic, strong) NSDictionary *entityWordInfoDict;
@property (nonatomic, strong) NSDictionary *largeImageDict;
@property (nonatomic, strong) NSDictionary *middleImageDict;
@property (nonatomic, strong) NSDictionary *videoDetailInfo;
@property (nonatomic, strong) NSDictionary *videoPlayInfo;
@property (nonatomic, strong) TTAdVideoRelateAdModel *videoAdExtra;
@property (nonatomic, strong) NSDictionary *videoExtendLink;
@property (nonatomic, strong) NSString       *source;
@property (nonatomic, strong) NSString       *thumbnailListString;
@property (nonatomic, strong) NSString       *title;
@property (nonatomic, strong) NSNumber       *imageMode;
@property (nonatomic, strong) NSArray *listGroupImgDicts;
@property (nonatomic, strong) NSDictionary *sourceIconDict;
@property (nonatomic, strong) NSDictionary *sourceIconNightDict;
@property (nonatomic, strong) NSNumber     *videoType;
@property (nonatomic, strong) NSDate       *createdTime;
@property (nonatomic, strong) NSMutableDictionary *meituanAds;
@property (nonatomic, strong) NSDictionary *mediaInfo;
@property (nonatomic, strong) NSDictionary *detailMediaInfo;
@property (nonatomic, strong) NSDictionary *relatedVideoExtraInfo;
@property (nonatomic, copy) NSDictionary *wapHeaders;
@property (nonatomic, strong, readonly) NSDictionary *h5Extra;
@property (nonatomic, copy) NSDictionary *wendaExtra;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *detailUserInfo;
@property (nonatomic, copy) NSString *mediaUserID;
@property (nonatomic, copy, readonly) NSString *adIDStr;
@property (nonatomic, assign, readonly) int       articleType;

@property (nonatomic, strong, readonly) ArticleDetail *detail;

@property (nonatomic, assign, readonly) NSUInteger preloadWeb;
@property (nonatomic, strong, readonly) NSArray *commoditys;

- (NSDictionary *)rawAdData;
- (NSString *)articleDetailContent;
- (TTGroupModel *)groupModel;
- (NSString *)firstZzCommentMediaId;
- (BOOL)isVideoSourceUGCVideoOrHuoShan;
- (BOOL)isVideoSourceUGCVideo;
- (NSString *)zzCommentsIDString;
- (NSString *)videoSubjectID;
- (BOOL)shouldDirectShowVideoSubject;
- (BOOL)directPlay;
- (NSString *)relatedLogExtra;
- (BOOL)hasVideoSubjectID;
- (BOOL)hasVideoPlayInfoUrl;
- (BOOL)isVideoUrlValid;
- (NSString *)videoIDOfVideoDetailInfo;
- (BOOL)showExtendLink;
- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative;
- (instancetype)managedObjectContext;
- (BOOL)isImageSubject;
- (void)updateFollowed:(BOOL)followed;

- (Article *)ttv_convertedArticle;

@end
