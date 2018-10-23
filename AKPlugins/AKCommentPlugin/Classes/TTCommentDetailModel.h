//
//  TTCommentDetailModel.h
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import <TTNewsAccountBusiness/SSUserModel.h>
#import <TTPlatformUIModel/TTGroupModel.h>
#import "TTQutoedCommentModel.h"

typedef NS_ENUM(NSInteger, TTCommentDetailGroupSource) {
    TTCommentDetailGroupSourceUnknown = 0,
    TTCommentDetailGroupSourceCrawl = 1,
    TTCommentDetailGroupSourcePGC = 2,
    TTCommentDetailGroupSourceAD = 3,
    TTCommentDetailGroupSourceSubject = 4,
    TTCommentDetailGroupSourceForum = 5,
    TTCommentDetailGroupSourceEssay = 6,
    TTCommentDetailGroupSourceTemai = 7,
    TTCommentDetailGroupSourceAdmin = 8,
    TTCommentDetailGroupSourceQuestion = 9,
    TTCommentDetailGroupSourceAnswer = 10,
    TTCommentDetailGroupSourceLive = 11,
    TTCommentDetailGroupSourceTTLive = 12,
    TTCommentDetailGroupSourceConcern = 13,
    TTCommentDetailGroupSourceColumn = 14,
    TTCommentDetailGroupSourceUgcVideo = 15
};

@interface TTCommentDetailModel : JSONModel
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString <Optional> *dongtaiID;
@property (nonatomic, strong) NSString <Optional>*content;
@property (nonatomic, strong) NSString <Optional>*contentRichSpanJSONString;
@property (nonatomic, strong) NSString <Optional>*createTime;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, strong) SSUserModel<Ignore> *user;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) BOOL isPGCAuthor;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, strong) NSString <Optional>*shareURL;
@property (nonatomic, strong) TTQutoedCommentModel<Ignore> *qutoedCommentModel;

// Group Item 用到的数据
@property (nonatomic, strong) TTGroupModel<Ignore> *groupModel;
@property (nonatomic, strong) NSMutableOrderedSet<SSUserModel *> <Optional>*digUsers;
@property (nonatomic, strong) NSString<Optional> *groupTitle;
@property (nonatomic, strong) NSString<Optional> *groupContent;
@property (nonatomic, strong) NSString<Optional> *groupContentRichSpan;
@property (nonatomic, strong) NSString<Optional> *groupUserName;
@property (nonatomic, strong) NSString<Optional> *groupUserId;
@property (nonatomic, strong) NSString<Optional> *groupThumbURL;
@property (nonatomic, assign) NSInteger groupMediaType;
@property (nonatomic, strong) NSString<Optional> *groupOpenURL;
@property (nonatomic, assign) NSInteger groupSource;


@property (nonatomic, strong) NSString <Optional> *commentPlaceholder; // Ignore
@property (nonatomic, assign) BOOL banEmojiInput; // Ignore
@property (nonatomic, strong) NSNumber <Optional> *banForwardToWeitoutiao; //是否露出对勾，nil表示未初始化，读取settings
@property (nonatomic, strong) NSString <Optional> *authorID;
@property (nonatomic, strong) NSDictionary <Optional> *repost_params;
@property (nonatomic, assign) BOOL show_repost_weitoutiao_entrance;

@end
