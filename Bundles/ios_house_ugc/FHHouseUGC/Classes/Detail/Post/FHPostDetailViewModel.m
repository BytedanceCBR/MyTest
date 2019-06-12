//
//  FHPostDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHPostDetailViewModel.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"
#import "FHPostDetailCell.h"
#import "TTUGCRequestManager.h"
#import "NSObject+TTAdditions.h"
#import "TTRoute.h"
#import "FRCommonURLSetting.h"
#import "TTAlphaThemedButton.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "NSObject+FBKVOController.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "TTRoute.h"
#import "TTTAttributedLabel.h"
#import "TTImageView.h"
#import "JSONAdditions.h"
#import "NSDictionary+TTAdditions.h"

@interface FHPostDetailViewModel ()

@end

@implementation FHPostDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHPostDetailCell class] forCellReuseIdentifier:NSStringFromClass([FHPostDetailCell class])];
}

// cell class
- (Class)cellClassForEntity:(id)model {
    // 兼容旧版本 头部滑动图片
    if ([model isKindOfClass:[FHFeedUGCCellModel class]]) {
        return [FHPostDetailCell class];
    }
    return [FHUGCBaseCell class];
}

// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

// init
- (nonnull instancetype)initWithThreadID:(int64_t)threadID forumID:(int64_t)forumID{
    self = [super init];
    if (self) {
        self.threadID = threadID;
        self.forumID = forumID;
//        self.repostOriginType = TTThreadRepostOriginTypeNone;
//        [self firstInitWithDatabaseAndCache];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithThreadID:0 forumID:0];
    return self;
}

- (void)dealloc {
}

#pragma mark - Public

- (void)requestV3InfoWithCompletion:(void(^)(NSError *error, uint64_t networkConsume))completion
{
    if (self.threadID) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:@(self.threadID) forKey:@"thread_id"];
        [param setValue:self.category forKey:@"category"];
        uint64_t startTime = [NSObject currentUnixTime];
        WeakSelf;
        [TTUGCRequestManager requestForJSONWithURL:[FRCommonURLSetting ugcThreadDetailV3InfoURL] params:param method:@"GET" needCommonParams:YES callBackWithMonitor:^(NSError *error, id jsonObj, TTUGCRequestMonitorModel *monitorModel) {
            StrongSelf;
            uint64_t endTime = [NSObject currentUnixTime];
            uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
            if (!error) {
                NSDictionary *dataDict = [jsonObj isKindOfClass:[NSDictionary class]]? jsonObj: nil;
                if ([dataDict tt_longValueForKey:@"err_no"] == 0) {
//                    self.ad_string = [dataDict tt_stringValueForKey:@"ad"];
//                    self.recommend_sponsor = [dataDict tt_dictionaryValueForKey:@"recommend_sponsor"];
                    NSString *dataStr = [dataDict tt_stringValueForKey:@"data"];
                    if (isEmptyString(dataStr)) {
                        //不该出现这种情况
                    } else {
                        NSError *jsonParseError;
                        NSDictionary *threadDict = [NSString tt_objectWithJSONString:dataStr error:&jsonParseError];
                        
                        //如果用户点进详情页时候，该条帖子被主人编辑过了，这个时候详情页的帖子内容和外部不一样，所以发送这个通知，将外面出现的旧帖子内容进行更新
//                        if ([self.thread.versionCode integerValue] < [threadDict tt_intValueForKey:@"version"]) {
//                            NSMutableDictionary *info = [NSMutableDictionary dictionary];
//                            [info setValue:threadDict forKey:@"repostModel"];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostEditedThreadSuccessNotification object:nil userInfo:info];
//                        }
                        
//                        NSString * threadIdStr = [threadDict tt_stringValueForKey:@"thread_id"];
//                        self.thread = [Thread updateWithDictionary:threadDict threadId:threadIdStr parentPrimaryKey:nil];
//                        [self.thread save];
//                        //单独处理推荐理由字段
//                        NSDictionary *ugc_recommend = [threadDict tt_dictionaryValueForKey:@"ugc_recommend"];
//                        self.ugcRecommendReason = [ugc_recommend tt_stringValueForKey:@"reason"];
//
//                        NSString *threadID = self.thread.threadId;
//                        if (threadID && threadID.longLongValue != 0) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
//                                                                                object:nil
//                                                                              userInfo:@{@"uniqueID":threadID}];
//                        }
//                        NSString *originThreadID = self.thread.originThread.threadId;
//                        if (originThreadID && originThreadID.longLongValue != 0) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
//                                                                                object:nil
//                                                                              userInfo:@{@"uniqueID":originThreadID}];
//                        }
                    }
                }
            }
            if (completion) {
                completion(error,total);
            }
        }];
    }
}

@end
