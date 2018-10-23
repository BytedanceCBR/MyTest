//
//  TTShortVideolModel.h
//  Article
//
//  Created by 王双华 on 2017/8/16.
//
//

#import <JSONModel/JSONModel.h>
#import "TSVUserModel.h"

@class TSVMusicModel, TSVVideoModel, TSVMusicVideoURLModel, TTImageInfosModel, TSVShortVideoOriginalData, TSVShowMoreModel, TSVActivityModel, TSVChallengeInfo, TSVCheckChallenge;

@interface TTShortVideoModel : JSONModel

@property (nonatomic, weak) TSVShortVideoOriginalData<Ignore> *shortVideoOriginalData;

@property (nonatomic, assign) BOOL shouldDelete;
@property (nonatomic, strong) NSNumber<Ignore> *listIndex;
@property (nonatomic, copy) NSString<Ignore> *cardID;
@property (nonatomic, copy) NSString<Ignore> *cardPosition;
@property (nonatomic, copy) NSString<Ignore> *listEntrance;
@property (nonatomic, copy) NSString<Ignore> *categoryName;
@property (nonatomic, copy) NSString<Ignore> *enterFrom;

@property (nonatomic, copy) NSString<Ignore> *videoLocalPlayAddr;
@property (nonatomic, strong) NSNumber<Optional> *showOrigin;
@property (nonatomic, copy) NSString<Optional> *showTips;
@property (nonatomic, strong) NSDictionary<Optional> *logPb;
@property (nonatomic, copy) NSString<Optional> *actionExtra;
/// ugc_recommend
@property (nonatomic, copy) NSString<Optional> *recommendReason;
@property (nonatomic, copy) NSString<Optional> *ugcActivity;
/// raw_data
@property (nonatomic, copy) NSString<Optional> *groupID;
@property (nonatomic, copy) NSString<Optional> *itemID;
@property (nonatomic, copy) NSString<Optional> *groupSource;
@property (nonatomic, copy) NSString<Optional> *title;
@property (nonatomic, copy) NSString<Optional> *titleRichSpanJSONString;
@property (nonatomic, copy) NSString<Optional> *labelForDetail;
@property (nonatomic, copy) NSString<Optional> *labelForList;
@property (nonatomic, copy) NSString<Optional> *labelForInteract;
@property (nonatomic, copy) NSString<Optional> *appSchema;
@property (nonatomic, copy) NSString<Optional> *detailSchema;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, copy) NSString<Optional> *distance;
/// action
@property (nonatomic, assign) NSInteger forwardCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger readCount;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL userRepin;
/// share
@property (nonatomic, copy) NSString<Optional> *shareDesc;
@property (nonatomic, copy) NSString<Optional> *shareTitle;
@property (nonatomic, copy) NSString<Optional> *shareUrl;
@property (nonatomic, copy) NSString<Optional> *shareWeiboDesc;
/// status
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, assign) BOOL allowShare;
@property (nonatomic, assign) BOOL allowComment;
@property (nonatomic, assign) BOOL allowDownload;
/// author
@property (nonatomic, strong) TSVUserModel<Optional> *author;
/// music video
@property (nonatomic, strong) TSVMusicModel<Optional> *music;
@property (nonatomic, strong) TSVVideoModel<Optional> *video;

@property (nonatomic, strong) TTImageInfosModel<Optional> *coverImageModel;
@property (nonatomic, strong) TTImageInfosModel<Optional> *detailCoverImageModel;
@property (nonatomic, strong) TTImageInfosModel<Optional> *firstFrameImageModel;
@property (nonatomic, strong) TTImageInfosModel<Optional> *animatedImageModel;
@property (nonatomic, strong) TSVActivityModel<Optional> *activity;
@property (nonatomic, copy) NSString<Optional> *topCursor;
@property (nonatomic, copy) NSString<Optional> *cursor;

@property (nonatomic, strong) NSDictionary *raw_ad_data;

@property (nonatomic, copy) NSString<Optional> *debugInfo;
@property (nonatomic, strong) TSVShowMoreModel<Optional> *showMoreModel;
@property (nonatomic, strong) TSVChallengeInfo<Optional> *challengeInfo;
@property (nonatomic, strong) TSVCheckChallenge<Optional> *checkChallenge;

- (void)save;
- (BOOL)isAuthorMyself;
- (void)removeVideoPlayAddressFromUserDefault;

@end

/// 子model

@interface TSVMusicModel : JSONModel

@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, strong) TSVMusicVideoURLModel *coverHd;//封面高清图(1080x1080)
@property (nonatomic, strong) TSVMusicVideoURLModel *coverLarge;//封面大图(720x720)
@property (nonatomic, strong) TSVMusicVideoURLModel *coverMedium;//封面中图(200x200)
@property (nonatomic, strong) TSVMusicVideoURLModel *coverThumb;//封面缩略图(100x100)

@end

@interface TSVVideoModel : JSONModel

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *ratio;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, strong) TSVMusicVideoURLModel *playAddr;
@property (nonatomic, strong) TSVMusicVideoURLModel *originCover;
@property (nonatomic, strong) TSVMusicVideoURLModel *downloadAddr;
@property (nonatomic, assign) BOOL vertical;

@end

@interface TSVMusicVideoURLModel : JSONModel
@property (nonatomic, copy) NSString * uri;
@property (nonatomic, copy) NSArray<NSString *> *urlList;

@end

@interface TSVActivityModel : JSONModel

@property (nonatomic, copy) NSString *forumID;
@property (nonatomic, copy) NSString *concernID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSString *activityInfo;
@property (nonatomic, assign) NSInteger bonus;
@property (nonatomic, copy) NSString *labels;
@property (nonatomic, assign) NSInteger rank;
@property (nonatomic, assign) BOOL showOnList;

@end

@interface TSVShowMoreModel : JSONModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end

@interface TSVChallengeInfo : JSONModel

@property (nonatomic, assign) BOOL allowChallenge;
@property (nonatomic, copy) NSString *challengeAward;
@property (nonatomic, copy) NSString *challengeRule;
@property (nonatomic, copy) NSString *challengeSchemaUrl;

@end

@interface TSVCheckChallenge : JSONModel

@property (nonatomic, assign) BOOL allowCheck;
@property (nonatomic, copy) NSString *challengeSchemaUrl;

- (void)replaceGroupIDWithGroupID:(NSString *)groupID;

@end
