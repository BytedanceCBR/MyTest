//
//  TTShortVideoModel.m
//  Article
//
//  Created by 王双华 on 2017/8/16.
//
//

#import "TTShortVideoModel.h"
#import "TTImageInfosModel.h"
#import "TTImageInfosModel+TSVJSONValueTransformer.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVShortVideoOriginalData.h"
#import "TTFollowManager.h"
#import "TTBlockManager.h"
#import "TTBaseMacro.h"
#import "TSVPropertySynchronizationMediator.h"
#import "TTAccountManager.h"
#import "TSVVideoPlayAddressManager.h"
#import "TTUGCPostCenterProtocol.h"
#import "TSVShortVideoPostTaskProtocol.h"

@implementation TTShortVideoModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super initWithDictionary:dict error:err]) {
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter]
           rac_addObserverForName:RelationActionSuccessNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification *notification) {
             @strongify(self);
             NSString *userID = notification.userInfo[kRelationActionSuccessNotificationUserIDKey];
             NSString *userIDOfSelf = self.author.userID;
             if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
                 FriendActionType actionType = (FriendActionType)[(NSNumber *)notification.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
                 if (actionType == FriendActionTypeFollow) {
                     self.author.isFollowing = YES;
                     self.author.followersCount++;
                     [self save];
                 } else if (actionType == FriendActionTypeUnfollow) {
                     self.author.isFollowing = NO;
                     self.author.followersCount--;
                     [self save];
                 }
             }
         }];

        [[[[NSNotificationCenter defaultCenter]
           rac_addObserverForName:kHasBlockedUnblockedUserNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification *notification) {
             @strongify(self);
             NSString *userID = notification.userInfo[kBlockedUnblockedUserIDKey];
             NSString *userIDOfSelf = self.author.userID;
             if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
                 BOOL isBlocking = [notification.userInfo[kIsBlockingKey] boolValue];
                 if (isBlocking) {
                     self.author.isFollowing = NO;
                     [self save];
                 }
             }
         }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"TSVShortVideoDiggCountSyncNotification" object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification * _Nullable notification) {
             @strongify(self);
             NSDictionary *userInfo = notification.userInfo;
             NSString *groupID = [userInfo tt_stringValueForKey:@"group_id"];
             BOOL userDigg = [userInfo tt_boolValueForKey:@"user_digg"];
             if (!isEmptyString(groupID) && [groupID isEqualToString:self.groupID]) {
                 if (self.userDigg != userDigg) {
                     self.userDigg = userDigg;
                 }
             }
         }];
        
//        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskBeginNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
//            @strongify(self);
//            id<TSVShortVideoPostTaskProtocol> task = notification.object;
//            if (!task.challengeGroupID || ![task.challengeGroupID isEqualToString:self.groupID]) {
//                return;
//            }
//            if (self.challengeInfo.allowChallenge){
//                //开始上传时，需要将状态改成不能挑战，可以查看
//                self.challengeInfo.allowChallenge = NO;
//                self.checkChallenge.allowCheck = YES;
//                [self save];
//            }
//        }];
        
//        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskSuccessNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
//            @strongify(self);
//            id<TSVShortVideoPostTaskProtocol> task = notification.object;
//            if (!task.challengeGroupID || ![task.challengeGroupID isEqualToString:self.groupID]) {
//                return;
//            }
//            //pk_no != 0即挑战失败
//            NSInteger pkNo = [task.pkStatus tt_integerValueForKey:@"pk_no"];
//            NSDictionary *dict = notification.userInfo;
//            NSString *groupID = [dict tt_stringValueForKey:@"id"];
//            if (pkNo != 0) {
//                //上传成功，但是挑战失败时，需要将状态改回能挑战，不能查看
//                self.challengeInfo.allowChallenge = YES;
//                self.checkChallenge.allowCheck = NO;
//            } else {
//                //上传成功，挑战成功,不允许继续挑战，能查看
//                self.challengeInfo.allowChallenge = NO;
//                self.checkChallenge.allowCheck = YES;
//                [self.checkChallenge replaceGroupIDWithGroupID:groupID];
//            }
//            [self save];
//        }];
        
//        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskDeletedNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
//            @strongify(self);
//            NSString *challengeGroupID = [notification.userInfo tt_stringValueForKey:TTPostTaskNotificationUserInfoKeyChallengeGroupID];
//            if (isEmptyString(challengeGroupID) || ![challengeGroupID isEqualToString:self.groupID]) {
//                return;
//            }
//            if (self.checkChallenge.allowCheck) {
//                //删除未上传结束的挑战的视频，需要将状态改回能挑战，不能查看
//                self.checkChallenge.allowCheck = NO;
//                self.challengeInfo.allowChallenge = YES;
//                [self save];
//            }
//        }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTSVShortVideoDeleteNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
            @strongify(self);
            NSDictionary *userInfo = notification.userInfo;
            NSString *groupID = [userInfo tt_stringValueForKey:kTSVShortVideoDeleteUserInfoKeyGroupID];
            NSString *challengeSchemaUrl = self.checkChallenge.challengeSchemaUrl;
            if (isEmptyString(groupID) || ![challengeSchemaUrl containsString:groupID]) {
                return;
            }
            //如果删除自己，不改变”查看挑战“
            if ([groupID isEqualToString:self.groupID]) {
                return;
            }
            if (self.checkChallenge.allowCheck) {
                //删除已上传结束的挑战的视频，需要将状态改回能挑战，不能查看
                self.checkChallenge.allowCheck = NO;
                self.challengeInfo.allowChallenge = YES;
                [self.checkChallenge replaceGroupIDWithGroupID:@""];
                [self save];
            }
        }];

        NSString *entityKey = [NSString stringWithFormat:@"gid:%@", self.groupID];
        TSVPropertySynchronizationMediator *mediator = [TSVPropertySynchronizationMediator sharedMediator];

        [mediator syncPropertyForObject:self
                                keyPath:@keypath(self, diggCount)
                              entityKey:entityKey];
        [mediator syncPropertyForObject:self
                                keyPath:@keypath(self, commentCount)
                              entityKey:entityKey];
        [mediator syncPropertyForObject:self
                                keyPath:@keypath(self, forwardCount)
                              entityKey:entityKey];
        [mediator syncPropertyForObject:self
                                keyPath:@keypath(self, userDigg)
                              entityKey:entityKey];
        [mediator syncPropertyForObject:self
                                keyPath:@keypath(self, shouldDelete)
                              entityKey:entityKey];

        if ([dict tt_stringValueForKey:@"video_local_url"]) {
            NSString *videoLocalPlayAddr = [dict tt_stringValueForKey:@"video_local_url"];
            [TSVVideoPlayAddressManager saveVideoPlayAddress:videoLocalPlayAddr forGroupID:self.groupID];
        }
    }
    
    return self;
}

+ (JSONKeyMapper *)keyMapper
{
    TTShortVideoModel *model = nil;
    NSDictionary *dict = @{
                           @keypath(model, showOrigin): @"show_origin",
                            @keypath(model, showTips): @"show_tips",
                            @keypath(model, logPb): @"log_pb",
                            @keypath(model, actionExtra): @"action_extra",
                            @keypath(model, recommendReason): @"ugc_recommend.reason",
                            @keypath(model, ugcActivity): @"ugc_recommend.activity",
                            @keypath(model, groupID): @"raw_data.group_id",
                            @keypath(model, itemID): @"raw_data.item_id",
                            @keypath(model, groupSource): @"raw_data.group_source",
                            @keypath(model, title): @"raw_data.title",
                            @keypath(model, titleRichSpanJSONString): @"raw_data.title_rich_span",
                            @keypath(model, labelForDetail): @"raw_data.label",
                            @keypath(model, labelForList): @"raw_data.label_for_list" ,
                            @keypath(model, labelForInteract): @"raw_data.interact_label" ,
                            @keypath(model, appSchema): @"raw_data.app_schema",
                            @keypath(model, detailSchema): @"raw_data.detail_schema",
                            @keypath(model, createTime): @"raw_data.create_time",
                            @keypath(model, distance): @"raw_data.distance",
                            @keypath(model, forwardCount): @"raw_data.action.forward_count",
                            @keypath(model, commentCount): @"raw_data.action.comment_count",
                            @keypath(model, readCount): @"raw_data.action.read_count",
                            @keypath(model, diggCount): @"raw_data.action.digg_count",
                            @keypath(model, playCount): @"raw_data.action.play_count",
                            @keypath(model, userDigg): @"raw_data.action.user_digg",
                            @keypath(model, userRepin): @"raw_data.action.user_repin",
                            @keypath(model, shareDesc): @"raw_data.share.share_desc",
                            @keypath(model, shareTitle): @"raw_data.share.share_title",
                            @keypath(model, shareUrl): @"raw_data.share.share_url",
                            @keypath(model, shareWeiboDesc): @"raw_data.share.share_weibo_desc",
                            @keypath(model, isDelete): @"raw_data.status.is_delete",
                            @keypath(model, allowShare): @"raw_data.status.allow_share",
                            @keypath(model, allowComment): @"raw_data.status.allow_comment",
                            @keypath(model, allowDownload): @"raw_data.status.allow_download",
                            @keypath(model, author): @"raw_data.user",
                            @keypath(model, music): @"raw_data.music",
                            @keypath(model, video): @"raw_data.video",
                            @keypath(model, coverImageModel): @"raw_data.thumb_image_list",
                            @keypath(model, detailCoverImageModel): @"raw_data.large_image_list",
                            @keypath(model, firstFrameImageModel): @"raw_data.first_frame_image_list",
                            @keypath(model, animatedImageModel): @"raw_data.animated_image_list",
                            @keypath(model, raw_ad_data): @"raw_data.raw_ad_data",
                            @keypath(model, debugInfo): @"debug_info",
                            @keypath(model, activity): @"raw_data.activity",
                            @keypath(model, topCursor): @"top_cursor",
                            @keypath(model, cursor): @"cursor",
                            @keypath(model, showMoreModel): @"show_more",
                            @keypath(model, challengeInfo): @"raw_data.challenge_info",
                            @keypath(model, checkChallenge): @"raw_data.check_challenge",
                            };
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    TTShortVideoModel *model = nil;
    NSArray *optionalArray = @[@keypath(model, createTime),
                                @keypath(model, forwardCount),
                                @keypath(model, commentCount),
                                @keypath(model, readCount),
                                @keypath(model, diggCount),
                                @keypath(model, playCount),
                                @keypath(model, userDigg),
                                @keypath(model, userRepin),
                                @keypath(model, isDelete),
                                @keypath(model, allowShare),
                                @keypath(model, allowComment),
                                @keypath(model, allowDownload),
                                @keypath(model, raw_ad_data)
                                ];
    
    return [optionalArray containsObject:propertyName];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    TTShortVideoModel *model = nil;
    NSArray *ignoreArray = @[@keypath(model, shouldDelete),
                              @"rawAd"
                              ];
    return [ignoreArray containsObject:propertyName];
}

- (void)setCoverImageModelWithNSArray:(NSArray *)array
{
    self.coverImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForCoverImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.coverImageModel];
}

- (void)setDetailCoverImageModelWithNSArray:(NSArray *)array
{
    self.detailCoverImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForDetailCoverImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.detailCoverImageModel];
}

- (void)setFirstFrameImageModelWithNSArray:(NSArray *)array
{
    self.firstFrameImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForFirstFrameImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.firstFrameImageModel];
}

- (void)setAnimatedImageModelWithNSArray:(NSArray *)array
{
    self.animatedImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForAnimatedImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.animatedImageModel];
}

- (void)setUserRepin:(BOOL)userRepin
{
    _userRepin = userRepin;
    if (_shortVideoOriginalData) {
        _shortVideoOriginalData.userRepined = userRepin;
    }
}

- (void)save
{
    self.shortVideoOriginalData.originalDict = [self toDictionary];
    [self.shortVideoOriginalData save];
}

- (BOOL)isAuthorMyself
{
    return [self.author.userID isEqualToString:[TTAccountManager userID]];
}

- (NSString *)videoLocalPlayAddr
{
    ///自己发的视频 本地播放
    NSString *playAddr = [TSVVideoPlayAddressManager videoPlayeAddressForGroupID:self.groupID];
    if (playAddr.length > 0) {
        NSString *homeDirectory = NSHomeDirectory();
        NSString *videoLocalURLPath = [homeDirectory stringByAppendingString:playAddr];
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalURLPath]) {
            return videoLocalURLPath;
        } else {
            [self removeVideoPlayAddressFromUserDefault];
        }
    }
    return nil;
}

- (void)removeVideoPlayAddressFromUserDefault
{
    [TSVVideoPlayAddressManager removeVideoPlayAddressForGroupID:self.groupID];
}

@end

@implementation TSVMusicModel

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TSVVideoModel

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TSVMusicVideoURLModel

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TSVActivityModel

+ (JSONKeyMapper *)keyMapper
{
    TSVActivityModel *activityModel;
    NSDictionary *dict = @{
                           @keypath(activityModel, forumID): @"forum_id",
                            @keypath(activityModel, concernID): @"concern_id",
                            @keypath(activityModel, name): @"name",
                            @keypath(activityModel, openURL): @"open_url",
                            @keypath(activityModel, activityInfo): @"activity_info",
                            @keypath(activityModel, bonus): @"bonus",
                            @keypath(activityModel, labels): @"labels",
                            @keypath(activityModel, rank): @"rank",
                            @keypath(activityModel, showOnList): @"show_on_list",
                            };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TSVShowMoreModel

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation TSVChallengeInfo

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)setAllowChallenge:(BOOL)allowChallenge
{
    if (_allowChallenge != allowChallenge) {
        _allowChallenge = allowChallenge;
        if (allowChallenge && self.challengeSchemaUrl.length > 0) {
            //允许挑战时，需要将schema里的group_id干掉
            NSURLComponents *components = [NSURLComponents componentsWithString:self.challengeSchemaUrl];
            NSMutableArray *queryItems = [NSMutableArray array];
            for (NSURLQueryItem *queryItem in components.queryItems) {
                if (![queryItem.name isEqualToString:@"group_id"]) {
                    [queryItems addObject:queryItem];
                }
            }
            components.queryItems = [queryItems copy];
            self.challengeSchemaUrl = [components.URL.absoluteString copy];
        }
    }
}

@end

@implementation TSVCheckChallenge

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)replaceGroupIDWithGroupID:(NSString *)groupID
{
    NSURLComponents *components = [NSURLComponents componentsWithString:self.challengeSchemaUrl];
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if (![queryItem.name isEqualToString:@"group_id"]) {
            [queryItems addObject:queryItem];
        } else {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"group_id" value:groupID]];
        }
    }
    components.queryItems = [queryItems copy];
    self.challengeSchemaUrl = [components.URL.absoluteString copy];
}

@end
