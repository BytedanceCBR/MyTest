//
//  TTAuthorizeModel.m
//  Article
//
//  Created by Chen Hong on 15/4/16.
//
//

#import "TTAuthorizeModel.h"


#define kPlistFileName @"ttAuthAlert.plist"
#define kLastTimeShowPush @"kLastTimeShowPush"
#define kLastTimeShowLogin @"kLastTimeShowLogin"
#define kLastTimeShowLocation @"kLastTimeShowLocation"
#define kLastTimeShowAddressBook @"kLastTimeShowAddressBook"

#define kShowLoginTimesDetailFavorite @"kShowLoginTimesDetailFavorite"
#define kShowLoginTimesDetailComment @"kShowLoginTimesDetailComment"
#define kShowPushTimes @"kShowPushTimes"
#define kShowLocationTimesLocalCategory @"kShowLocationTimesLocalCategory"
#define kShowLocationTimesLocationChanged @"kShowLocationTimesLocationChanged"
#define kShowAddressBookTimesAddFriendPage @"kShowAddressBookTimesAddFriendPage"
#define kShowAddressBookTimesAddFriendAction @"kShowAddressBookTimesAddFriendAction"
#define kShowAddressBookTimesMomentPage @"kShowAddressBookTimesMomentPage"


#define kShowAlertInterval @"kShowAlertInterval"

#define kShowLoginTimeInterval @"kShowLoginTimeInterval"
#define kShowLoginMaxTimesDetailFavorite @"kShowLoginMaxTimesDetailFavorite"
#define kShowLoginMaxTimesDetailComment @"kShowLoginMaxTimesDetailComment"

#define kShowPushTimeInterval @"kShowPushTimeInterval"
#define kShowPushMaxTimes @"kShowPushMaxTimes"
#define kShowPushHintText @"kShowPushHintText"

#define kShowPushTimesByTopArticle  (@"kShowPushTimesByTopArticle")
#define kShowPushTimesByFollow      (@"kShowPushTimesByFollow")
#define kShowPushTimesByInteraction (@"kShowPushTimesByInteraction")

#define kShowLocationTimeInterval @"kShowLocationTimeInterval"
#define kShowLocationMaxTimesLocalCategory @"kShowLocationMaxTimesLocalCategory"
#define kShowLocationMaxTimesLocationChanged @"kShowLocationMaxTimesLocationChanged"

#define kShowAddressBookTimeInterval @"kShowAddressBookTimeInterval"
#define kShowAddressBookMaxTimesAddFriendPage @"kShowAddressBookMaxTimesAddFriendPage"
#define kShowAddressBookMaxTimesAddFriendAction @"kShowAddressBookMaxTimesAddFriendAction"
#define kShowAddressBookMaxTimesMomentPage @"kShowAddressBookMaxTimesMomentPage"

// 默认设置
// 和其他类型弹窗间隔1天
#define kDefaultShowAlertInterval1 (1 * 24 * 3600) // 老的以秒计算
#define kNewDefaultShowAlertInterval1 (1) // 新的同类弹窗间隔按天计算
// 同类弹窗时间间隔7天
#define kDefaultShowAlertInterval2 (7 * 24 * 3600) // 老的以秒计算
#define kNewDefaultShowAlertInterval2 (7) // 新的间隔按天计算
// 最大次数3次
#define kDefaultShowMaxTimes 3

/**
 *  自有弹窗出现次数
 */
#define kShowLocationAuthorizeHintTimes @"kShowLocationAuthorizeHintTimes"
#define kShowPushAuthorizeHintTimes @"kShowPushAuthorizeHintTimes"
#define kIsPushAuthorizeHintAllowd @"kIsPushAuthorizeHintAllowd"
#define kLastTimeShowLocationAuthorizeHint @"kLastTimeShowLocationAuthorizeHint"
#define kLastTimeShowPushAuthorizeHint @"kLastTimeShowPushAuthorizeHint"

@implementation TTAuthorizeModel

- (instancetype)init {
    self = [super init];
    if (self) {
        // 和其他类型弹窗间隔
        
        _showAlertInterval = kNewDefaultShowAlertInterval1;
        
        _showLoginTimeInterval = kNewDefaultShowAlertInterval2;
        _showLoginMaxTimesDetailFavorite = kDefaultShowMaxTimes;
        _showLoginMaxTimesDetailComment = kDefaultShowMaxTimes;
        
        _showPushTimeInterval = kDefaultShowAlertInterval2;
        _showPushMaxTimes = kDefaultShowMaxTimes;
        _showPushHintText = NSLocalizedString(@"第一时间获知重大新闻", nil);
        
        _showLocationTimeInterval = kDefaultShowAlertInterval2;
        _showLocationMaxTimesLocalCategory = kDefaultShowMaxTimes;
        _showLocationMaxTimesLocationChanged = kDefaultShowMaxTimes;
        
        _showAddressBookTimeInterval = kDefaultShowAlertInterval2;
        
        _showAddressBookMaxTimesAddFriendPage = kDefaultShowMaxTimes;
        _showAddressBookMaxTimesAddFriendAction = kDefaultShowMaxTimes;
        _showAddressBookMaxTimesMomentPage = kDefaultShowMaxTimes;
        
        _isPushAuthorizeDetermined = NO;
        
        _pushFireReason = TTPushNoteGuideFireReasonNone;
        
        _showPushTimesByTopArticle = 0;
        _showPushTimesByFollow = 0;
        _showPushTimesByInteraction = 0;
    }
    return self;
}

- (void)loadData {
    NSArray *paths      = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kPlistFileName];
    NSDictionary *dict  = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    if (dict.count > 0) {
        // 本地保存
        _lastTimeShowPush                 = [[dict objectForKey:kLastTimeShowPush] integerValue];
        _lastTimeShowLogin                = [[dict objectForKey:kLastTimeShowLogin] integerValue];
        _lastTimeShowLocation             = [[dict objectForKey:kLastTimeShowLocation] integerValue];
        _lastTimeShowAddressBook          = [[dict objectForKey:kLastTimeShowAddressBook] integerValue];
        
        _showLoginTimesDetailFavorite     = [[dict objectForKey:kShowLoginTimesDetailFavorite] integerValue];
        _showLoginTimesDetailComment      = [[dict objectForKey:kShowLoginTimesDetailComment] integerValue];
        
        _showPushTimes                    = [[dict objectForKey:kShowPushTimes] integerValue];
        
        _showLocationTimesLocalCategory   = [[dict objectForKey:kShowLocationTimesLocalCategory] integerValue];
        _showLocationTimesLocationChanged = [[dict objectForKey:kShowLocationTimesLocationChanged] integerValue];
        
        _showAddressBookTimesAddFriendPage = [[dict objectForKey:kShowAddressBookTimesAddFriendPage] integerValue];
        _showAddressBookTimesAddFriendAction = [[dict objectForKey:kShowAddressBookTimesAddFriendAction] integerValue];
        _showAddressBookTimesMomentPage   = [[dict objectForKey:kShowAddressBookTimesMomentPage] integerValue];
        
        // 从服务端取，保存在本地
        _showAlertInterval                      = [[dict objectForKey:kShowAlertInterval] integerValue];
        
        _showLoginTimeInterval                  = [[dict objectForKey:kShowLoginTimeInterval] integerValue];
        _showLoginMaxTimesDetailFavorite        = [[dict objectForKey:kShowLoginMaxTimesDetailFavorite] integerValue];
        _showLoginMaxTimesDetailComment         = [[dict objectForKey:kShowLoginMaxTimesDetailComment] integerValue];
        
        _showPushTimeInterval                   = [[dict objectForKey:kShowPushTimeInterval] integerValue];
        _showPushMaxTimes                       = [[dict objectForKey:kShowPushMaxTimes] integerValue];
        _showPushHintText                       = [dict objectForKey:kShowPushHintText];
        
        _showPushTimesByTopArticle              = [[dict objectForKey:kShowPushTimesByTopArticle] integerValue];
        _showPushTimesByFollow                  = [[dict objectForKey:kShowPushTimesByFollow] integerValue];
        _showPushTimesByInteraction             = [[dict objectForKey:kShowPushTimesByInteraction] integerValue];
        
        _showLocationTimeInterval               = [[dict objectForKey:kShowLocationTimeInterval] integerValue];
        _showLocationMaxTimesLocalCategory      = [[dict objectForKey:kShowLocationMaxTimesLocalCategory] integerValue];
        _showLocationMaxTimesLocationChanged    = [[dict objectForKey:kShowLocationMaxTimesLocationChanged] integerValue];
        
        _showAddressBookTimeInterval            = [[dict objectForKey:kShowAddressBookTimeInterval] integerValue];
        
        _showAddressBookMaxTimesAddFriendPage   = [[dict objectForKey:kShowAddressBookMaxTimesAddFriendPage] integerValue];
        _showAddressBookMaxTimesAddFriendAction = [[dict objectForKey:kShowAddressBookMaxTimesAddFriendAction] integerValue];
        _showAddressBookMaxTimesMomentPage      = [[dict objectForKey:kShowAddressBookMaxTimesMomentPage] integerValue];
        
        /*加载自有弹窗出现次数*/
        _showLocationAuthorizeHintTimes = [[dict objectForKey:kShowLocationAuthorizeHintTimes] integerValue];
        _showPushAuthorizeHintTimes = [[dict objectForKey:kShowPushAuthorizeHintTimes] integerValue];
        
        _isPushAuthorizeDetermined = [[dict objectForKey:kIsPushAuthorizeHintAllowd] boolValue];
        _lastTimeShowPushAuthorizeHint = [[dict objectForKey:kLastTimeShowPushAuthorizeHint] integerValue];
        _lastTimeShowLocationAuthorizeHint = [[dict objectForKey:kLastTimeShowLocationAuthorizeHint] integerValue];
    }
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    [dict setValue:@(_lastTimeShowPush) forKey:kLastTimeShowPush];
    [dict setValue:@(_lastTimeShowLogin) forKey:kLastTimeShowLogin];
    [dict setValue:@(_lastTimeShowLocation) forKey:kLastTimeShowLocation];
    [dict setValue:@(_lastTimeShowAddressBook) forKey:kLastTimeShowAddressBook];
    
    [dict setValue:@(_showLoginTimesDetailFavorite) forKey:kShowLoginTimesDetailFavorite];
    [dict setValue:@(_showLoginTimesDetailComment) forKey:kShowLoginTimesDetailComment];
    
    [dict setValue:@(_showPushTimes) forKey:kShowPushTimes];
    [dict setValue:_showPushHintText forKey:kShowPushHintText];
    
    [dict setValue:@(_showLocationTimesLocalCategory) forKey:kShowLocationTimesLocalCategory];
    [dict setValue:@(_showLocationTimesLocationChanged) forKey:kShowLocationTimesLocationChanged];
    
    [dict setValue:@(_showAddressBookTimesAddFriendPage) forKey:kShowAddressBookTimesAddFriendPage];
    [dict setValue:@(_showAddressBookTimesAddFriendAction) forKey:kShowAddressBookTimesAddFriendAction];
    [dict setValue:@(_showAddressBookTimesMomentPage) forKey:kShowAddressBookTimesMomentPage];
    
    [dict setValue:@(_showAlertInterval) forKey:kShowAlertInterval];
    
    [dict setValue:@(_showLoginTimeInterval) forKey:kShowLoginTimeInterval];
    [dict setValue:@(_showLoginMaxTimesDetailFavorite) forKey:kShowLoginMaxTimesDetailFavorite];
    [dict setValue:@(_showLoginMaxTimesDetailComment) forKey:kShowLoginMaxTimesDetailComment];
    
    [dict setValue:@(_showPushTimeInterval) forKey:kShowPushTimeInterval];
    [dict setValue:@(_showPushMaxTimes) forKey:kShowPushMaxTimes];
    
    [dict setValue:@(_showPushTimesByTopArticle) forKey:kShowPushTimesByTopArticle];
    [dict setValue:@(_showPushTimesByFollow) forKey:kShowPushTimesByFollow];
    [dict setValue:@(_showPushTimesByInteraction) forKey:kShowPushTimesByInteraction];
    
    [dict setValue:@(_showLocationTimeInterval) forKey:kShowLocationTimeInterval];
    [dict setValue:@(_showLocationMaxTimesLocalCategory) forKey:kShowLocationMaxTimesLocalCategory];
    [dict setValue:@(_showLocationMaxTimesLocationChanged) forKey:kShowLocationMaxTimesLocationChanged];
    
    [dict setValue:@(_showAddressBookTimeInterval) forKey:kShowAddressBookTimeInterval];
    
    [dict setValue:@(_showAddressBookMaxTimesAddFriendPage) forKey:kShowAddressBookMaxTimesAddFriendPage];
    [dict setValue:@(_showAddressBookMaxTimesAddFriendAction) forKey:kShowAddressBookMaxTimesAddFriendAction];
    [dict setValue:@(_showAddressBookMaxTimesMomentPage) forKey:kShowAddressBookMaxTimesMomentPage];
    
    /*记录自有弹窗出现次数*/
    [dict setValue:@(_showLocationAuthorizeHintTimes) forKey:kShowLocationAuthorizeHintTimes];
    [dict setValue:@(_showPushAuthorizeHintTimes) forKey:kShowPushAuthorizeHintTimes];
    [dict setValue:@(_isPushAuthorizeDetermined) forKey:kIsPushAuthorizeHintAllowd];
    [dict setValue:@(_lastTimeShowLocationAuthorizeHint) forKey:kLastTimeShowLocationAuthorizeHint];
    [dict setValue:@(_lastTimeShowPushAuthorizeHint) forKey:kLastTimeShowPushAuthorizeHint];
    
    return [dict copy];
}

- (void)saveData {
    NSArray *paths      = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kPlistFileName];
    [[self toDictionary] writeToFile:plistPath atomically:YES];
}

- (NSInteger)maxLastTimeExcept:(NSInteger)lastTime {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:
                             @(_lastTimeShowPush),
                             @(_lastTimeShowLogin),
                             @(_lastTimeShowLocation),
                             @(_lastTimeShowAddressBook),
                             nil];
    [array removeObject:@(lastTime)];
    
    return [[array valueForKeyPath:@"@max.self"] integerValue];
}

@end
