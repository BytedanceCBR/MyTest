//
//  FriendDataManager.m
//  Article
//
//  Created by Dianwei on 12-11-2.
//
//

#import "FriendDataManager.h"
#import "ArticleFriend.h"

#import "ArticleFriendModel.h"
#import "SSABPerson.h"
#import "ArticleAddressManager.h"

#import "TTURLDomainHelper.h"
#import "TTInstallIDManager.h"
#import <TTAccountBusiness.h>
#import "TTNetworkUtilities.h"
#import "TTNetworkManager.h"
#import "ExploreEntryManager.h"

#define kLastSuggesttedUserTimestampKey     @"kLastSuggesttedUserTimestampKey"          //suggestUser API返回的last_timestamp时间

@implementation FriendDataURLSetting

+ (NSString*)joinFriendsURLString
{
    return [NSString stringWithFormat:@"%@/user/friends/", [self baseURL]];
}

+ (NSString*)followingURLString
{
    return [NSString stringWithFormat:@"%@/user/following/", [self baseURL]];
}

+ (NSString*)followerURLString
{
    return [NSString stringWithFormat:@"%@/user/followed/", [self baseURL]];
}

+ (NSString*)visitorHistoryURLString
{
    return [NSString stringWithFormat:@"%@/2/user/visit_history/", [self baseURL]];
}

+ (NSString*)suggestedUserURLString
{
    return [NSString stringWithFormat:@"%@/2/relation/suggest_users/", [self baseURL]];
}

+ (NSString*)widgetSuggestedUserURLString
{
    return [NSString stringWithFormat:@"%@/2/relation/suggest_users/v2/", [self baseURL]];
}

+ (NSString*)platformFriendURLString
{
    return [NSString stringWithFormat:@"%@/2/relation/platform_friends/", [self baseURL]];
}

+ (NSString*)userProfileURLString
{
    return [NSString stringWithFormat:@"%@/2/user/profile/v3/", [self baseURL]];
}

+ (NSString*)baseURL {
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

@end

@interface TTUserRelationUserRelationProfile : JSONModel

@property (nonatomic, assign) NSInteger followings;
@property (nonatomic, assign) NSInteger newlyFollowers;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, assign) NSInteger pgcLikeCount;
@property (nonatomic, assign) NSInteger newlyFriends;

@end

//2/relation/counts/v2
@interface TTUserRelationCountV2 : JSONModel

@property (nonatomic, assign) NSInteger loginStatus;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TTUserRelationUserRelationProfile *data;

@end

@implementation TTUserRelationUserRelationProfile

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{@"followings" : @"followings",
                           @"new_followers" : @"newlyFollowers",
                           @"followers" : @"followers",
                           @"pgc_like_count" : @"pgcLikeCount",
                           @"new_friends" : @"newlyFriends"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end



@interface FriendDataManager()

@property(nonatomic, retain)NSMutableDictionary *taskDict;
@property(nonatomic, retain)TTHttpTask *profileTask;
@property(nonatomic, retain)TTHttpTask *joinFriendTask;

@end

@implementation FriendDataManager
@synthesize delegate;

static FriendDataManager *s_manager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[FriendDataManager alloc] init];
    });
    return s_manager;
}

static NSString *s_hasNewFriendCountKey = @"s_hasNewFriendCountKey";
+ (BOOL)hasNewFriendCount
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:s_hasNewFriendCountKey] boolValue];
}

- (void)dealloc
{
    for(TTHttpTask *task in [_taskDict allValues]) {
        [task cancel];
    }
    
    [_profileTask cancel];
    self.profileTask = nil;
    
    [_joinFriendTask cancel];
    self.joinFriendTask = nil;
    
    self.taskDict = nil;
    self.delegate = nil;
    
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.taskDict = [NSMutableDictionary dictionaryWithCapacity:7];
        
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)startGetJoinFriendsWithOffset:(NSInteger)offset finishBlock:(void(^)(NSArray *result, BOOL newAccount, NSInteger newCount, NSInteger originalCount, BOOL hasMore, NSError *error))finishBlock
{
    if (_joinFriendTask) {
        [_joinFriendTask cancel];
    }
    //    NSDate * date = [NSDate date];
    self.joinFriendTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:[FriendDataURLSetting joinFriendsURLString] params:@{@"offset": @(offset)} method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSDictionary * dictionary = [[ArticleAddressManager sharedManager] addressBookPersons];
        NSMutableArray *friends = [NSMutableArray array];
        NSInteger newCount = 0, originalCount = 0;
        BOOL hasMore = NO;
        BOOL newAccount = [[jsonObj dictionaryValueForKey:@"data" defalutValue:nil] tt_boolValueForKey:@"is_first"];
        if(!error) {
            NSDictionary *data = [jsonObj dictionaryValueForKey:@"data" defalutValue:nil];
            BOOL isFirst = [data tt_boolValueForKey:@"is_first"];
            int newCount = 0;
            if(isFirst) {
                newCount = [data intValueForKey:@"contacts_count" defaultValue:0];
            }
            
            if([data objectForKey:@"has_more"]) {
                hasMore = [data tt_boolValueForKey:@"has_more"];
            }
            
            NSArray *list = [data arrayValueForKey:@"users" defaultValue:nil];
            originalCount = [list isKindOfClass:[NSArray class]] ? (int)list.count : 0;
            NSInteger notExistCount = 0, totalMobileCount = 0;
            for(NSDictionary *data in list) {
                if (![data isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                ArticleFriendModel *model = [[ArticleFriendModel alloc] initWithDictionary:data];
                if ([model.platformString isEqual:@"mobile"] && !isEmptyString(model.mobileHash))
                {
                    totalMobileCount ++;
                    NSString * mobileHash = [model.mobileHash lowercaseString];
                    
                    if(!isFirst && model.isNew) {
                        newCount += 1;
                    }
                    if ([dictionary valueForKey:mobileHash])
                    {
                        SSABPerson * person = [dictionary valueForKey:mobileHash];
                        model.platformScreenName = [person personName];
                        
                        if (model.platformScreenName.length > 0)
                        {
                            [friends addObject:model];
                        } else {
                            notExistCount ++;
                        }
                    }
                    else
                    {
                        /* 晓东需求
                         今日头条-iOSXWTT-2958
                         客户端不能读出通讯录时，有通讯录好友加入，显示对方头条用户名和「通讯录好友」——现在是页面为空*/
                        if (isEmptyString(model.recommendReason)) {
                            model.recommendReason = NSLocalizedString(@"通讯录好友", nil);
                        }
                        //if (!isEmptyString(model.name)) {
                        [friends addObject:model];
                        //}
                    }
                }
                else
                {
                    [friends addObject:model];
                }
            }
            if (notExistCount > 0) {
                [self _sendNotExistEventWithCount:notExistCount totalCount:totalMobileCount];
            }
        }
        
        if (offset > 0) {
            if(finishBlock) {
                finishBlock(friends,newAccount, newCount, originalCount, hasMore, error);
            }
        } else {
            
            if(finishBlock) {
                finishBlock(friends,newAccount, newCount, originalCount, hasMore, error);
            }
            
        }
    }];
}

// count 被过滤掉的个数，totalCount 总返回的手机号用户个数
- (void)_sendNotExistEventWithCount:(NSInteger)count totalCount:(NSInteger)totalCount {
    if (count <= 0 || totalCount <= 0) {
        return;
    }
    NSMutableDictionary *dictionary = [@{@"category":@"umeng",@"event":@"add_friends", @"label":@"no_contacts", @"value":@(count), @"total":@(totalCount)} mutableCopy];
    
    [dictionary setValue:[TTAccountManager userID] forKey:@"uid"];
    [TTTrackerWrapper eventData:dictionary];
}

#pragma mark - data list logic related

- (void)cancelGetFriendListType:(FriendDataListType)listType
{
    if([_taskDict objectForKey:[NSNumber numberWithInt:listType]])
    {
        [[_taskDict objectForKey:[NSNumber numberWithInt:listType]] cancel];
    }
}

- (void)cancelAllRequests
{
    for(TTHttpTask *task in [_taskDict allValues])
    {
        [task cancel];
    }
    
    [_profileTask cancel];
    [_joinFriendTask cancel];
}

- (void)startGetFriendListType:(FriendDataListType)listType userID:(NSString*)userID count:(int)count offset:(int)offset
{
    [self startGetFriendListType:listType friendModelClass:[ArticleFriend class] userID:userID count:count offset:offset];
}

- (void)startGetFriendListType:(FriendDataListType)listType friendModelClass:(Class)friendModelClass userID:(NSString*)userID count:(int)count offset:(int)offset
{
    NSString *urlString = nil;
    
    if([_taskDict objectForKey:[NSNumber numberWithInt:listType]])
    {
        [[_taskDict objectForKey:[NSNumber numberWithInt:listType]] cancel];
    }
    
    switch (listType) {
        case FriendDataListTypeFollower:
        {
            urlString = [FriendDataURLSetting followerURLString];
        }
            break;
        case FriendDataListTypeFowllowing:
        {
            urlString = [FriendDataURLSetting followingURLString];
        }
            break;
        case FriendDataListTypeVisitor: {
            urlString = [FriendDataURLSetting visitorHistoryURLString];
        }
            break;
        case FriendDataListTypePlatformFriends:
        {
            urlString = [FriendDataURLSetting platformFriendURLString];
        }
            break;
        case FriendDataListTypeSuggestUser:
        {
            urlString = [FriendDataURLSetting suggestedUserURLString];
        }
            break;
        case FriendDataListTypeWidgetSuggestUser:
        {
            urlString = [FriendDataURLSetting widgetSuggestedUserURLString];
        }
            break;
        default:
        {
            @throw [NSException exceptionWithName:@"FriendDataManagerException" reason:@"unkown list type" userInfo:nil];
        }
            break;
    }
    
    NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [getParams setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [getParams setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [getParams setValue:[NSNumber numberWithInt:count] forKey:@"count"];
    [getParams setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
    [getParams setValue:[TTDeviceHelper openUDID] forKey:@"openudid"];
    [getParams setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];

    if(listType == FriendDataListTypeSuggestUser || listType == FriendDataListTypeWidgetSuggestUser) {
        [getParams setValue:@([FriendDataManager suggestUserLastTimestamp]) forKey:@"last_timestamp"];
    }
    
    if(!isEmptyString(userID) &&
       (listType == FriendDataListTypeFowllowing ||
        listType == FriendDataListTypeFollower ||
        listType == FriendDataListTypeVisitor)) {
           [getParams setValue:userID forKey:@"user_id"];
       }
    
    
    NSDictionary *userInfo = @{@"list_type": @(listType), @"offset": @(offset), @"friendmodel_class": friendModelClass};
    
    TTHttpTask* task = [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:getParams method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSMutableArray *friends = [[NSMutableArray alloc] init];
        BOOL hasMoreData = YES;
        unsigned long long totalNumber = 0;
        unsigned long long anonymousNumber = 0;
        
        FriendDataListType listType = [[userInfo objectForKey:@"list_type"] intValue];
        if(!error)
        {
            NSArray *dataArray = nil;
            switch (listType) {
                case FriendDataListTypePlatformFriends:
                {
                    dataArray = [[jsonObj objectForKey:@"data"] objectForKey:@"friends"];
                }
                    break;
                default:
                {
                    dataArray = [[jsonObj objectForKey:@"data"] objectForKey:@"users"];
                }
                    break;
            }
            
            hasMoreData = [[[jsonObj objectForKey:@"data"] objectForKey:@"has_more"] boolValue];
            totalNumber = [[[jsonObj objectForKey:@"data"] objectForKey:@"total_cnt"] longLongValue];
            anonymousNumber = [[[jsonObj objectForKey:@"data"] objectForKey:@"anonymous_followers"] longLongValue];
            
            Class friendModelClass = [userInfo objectForKey:@"friendmodel_class"];
            
            for(NSDictionary *data in dataArray)
            {
                id friend = [[friendModelClass alloc] initWithDictionary:data];
                [friends addObject:friend];
            }
            if([friendModelClass isSubclassOfClass:[ArticleFriendModel class]])
            {
                NSDictionary * abDictionary = [[ArticleAddressManager sharedManager] addressBookPersons];
                for(ArticleFriendModel *friend in friends)
                {
                    //                 将platform为通讯录的用户的screenName替换成本地通讯录的名字
                    if ([friend.platformString isEqual:@"mobile"])
                    {
                        if(!isEmptyString(friend.mobileHash))
                        {
                            NSString * mobileHash = [friend.mobileHash lowercaseString];
                            SSABPerson * person = [abDictionary valueForKey:mobileHash];
                            friend.platformScreenName = [person personName];
                        }
                    }
                }
            }
            
            // get last refresh timestamp
            if(listType == FriendDataListTypeSuggestUser || listType == FriendDataListTypeWidgetSuggestUser)
            {
                NSTimeInterval lastRefreshTime = [[[jsonObj objectForKey:@"data"] objectForKey:@"last_timestamp"] doubleValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:lastRefreshTime] forKey:kLastSuggesttedUserTimestampKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        int offset = [[userInfo objectForKey:@"offset"] intValue];
        if(delegate && [delegate respondsToSelector:@selector(friendDataManager:finishGotListWithType:error:result:totalNumber:anonymousNumber:hasMore:offset:)])
        {
            [delegate friendDataManager:self finishGotListWithType:listType error:error result:friends totalNumber:totalNumber anonymousNumber:anonymousNumber hasMore:hasMoreData offset:offset];
        }
    }];
    
    [_taskDict setObject:task forKey:[NSNumber numberWithInt:listType]];
}

#pragma mark - friend profile methods

// request account user profile if userID == @""

- (void)startGetFriendProfileByUserID:(NSString *)userID extraTrack:(NSDictionary *)extraTrack
{
    NSString *urlString = [FriendDataURLSetting userProfileURLString];
    
    NSMutableDictionary *getParam = [NSMutableDictionary dictionaryWithCapacity:5];
    [getParam setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [getParam setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [getParam setValue:[TTDeviceHelper openUDID] forKey:@"openudid"];
    [getParam setValue:[SSCommonLogic followButtonColorStringForWap] forKey:@"followbtn_template"];
    [getParam setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    
    if (extraTrack[@"enter_from"]) {
        [getParam setValue:extraTrack[@"enter_from"] forKey:@"source"];
    }
    
    if (!isEmptyString(userID)) {
        [getParam setValue:userID forKey:@"user_id"];
    }
    
    if (_profileTask) {
        [_profileTask cancel];
    }
    _profileTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSDictionary *ret = nil;
        if (!error) {
            ret = [jsonObj objectForKey:@"data"];
        }
        if (delegate && [delegate respondsToSelector:@selector(friendDataManager:finishFriendProfileResult:error:)]) {
            [delegate friendDataManager:self finishFriendProfileResult:ret error:error];
        }
    }];
}


+ (NSTimeInterval)suggestUserLastTimestamp
{
    NSTimeInterval timeinterval = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastSuggesttedUserTimestampKey] doubleValue];
    if (timeinterval == 0) {
        timeinterval = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setObject:@(timeinterval) forKey:kLastSuggesttedUserTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return ((long long)timeinterval);
}

+ (void)saveSuggestUserLastTimestamp:(NSTimeInterval)time
{
    [[NSUserDefaults standardUserDefaults] setObject:@(time) forKey:kLastSuggesttedUserTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 *  判断是否应该提醒， 当用户第一次安装或者删除后安装时候， 不应该提醒
 */
+ (BOOL)relationCountNeedNotify
{
    BOOL result = YES;
    if (![TTAccountManager isLogin]) {
        result = NO;
    }
    return result;
}

@end
