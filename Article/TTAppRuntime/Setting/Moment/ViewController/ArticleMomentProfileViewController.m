//
//  ArticleMomentProfileViewController.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "ArticleMomentProfileViewController.h"
#import "SSUserModel.h"
#import "SSWebViewControllerView.h"
#import "TTViewWrapper.h"
#import "TTNavigationController.h"
#import "NSDictionary+TTAdditions.h"
#import "TTAlphaThemedButton.h"
#import "ArticleURLSetting.h"
#import "NewsUserSettingManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTNetworkUtilities.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "TTProfileShareService.h"
#import "KVOController.h"
#import "SSCommonLogic.h"
#import <CrashLytics/Answers.h>
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTPersonalHomeViewController.h"
#import "FriendDataManager.h"
#import "NSString+URLEncoding.h"
#import <TTKitchen/TTKitchen.h>

@interface ArticleMomentProfileViewController ()

@property(nonatomic, strong) SSUserModel * model;

// 是否隐藏导航栏（wap版生效)
@property(nonatomic, assign) BOOL shouldHideNavigationBar;

@property(nonatomic, copy) NSString *wapUrl;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *mediaID;



// 用于重新加载页面
@property (nonatomic, strong) TTRouteParamObj *paramObj;

// RN出错时强制使用WAP
@property(nonatomic, assign) BOOL forceUseWap;

@property(nonatomic, copy) NSString *refer;

@property(nonatomic, copy)NSString *source;

// 下发模板url
@property(nonatomic, copy)NSString *templateUrl;

@property (nonatomic, assign) BOOL fromColdStartPage;

@property (nonatomic, copy) NSDictionary *enterHomepageV3ExtraParams;//enter_homepage 埋点需要带进去一些参数
@end

@implementation ArticleMomentProfileViewController

+ (void)load {
        RegisterRouteObjWithEntryName(@"pgcprofile");
        RegisterRouteObjWithEntryName(@"media_account");
}

+ (void)openWithMediaID:(NSString *)mediaID enterSource:(NSString *)source itemID:(NSString *)itemID {
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?media_id=%@", mediaID];
    if (!isEmptyString(source)) {
        [linkURLString appendFormat:@"&source=%@", source];
    }
    if (!isEmptyString(itemID)) {
        [linkURLString appendFormat:@"&item_id=%@", itemID];
    }
    NSURL *url = [TTStringHelper URLWithURLString:linkURLString];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

- (void)dealloc
{
    [TTProfileShareService setShareObject:nil forUID:self.userID];
}

#pragma mark - TTRouteInitializeProtocol

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    NSString * uidStr = nil;
    NSDictionary *params = paramObj.allParams;
    
    if ([params.allKeys containsObject:@"uid"]) {
        long long userID = [[params objectForKey:@"uid"] longLongValue];
        long long fixedUserID = [SSCommonLogic fixLongLongTypeGroupID:userID];
        uidStr = [NSString stringWithFormat:@"%lli", fixedUserID];
        self = [self initWithUserID:uidStr];
        if ([params.allKeys containsObject:@"coldstart"]) {
            self.fromColdStartPage = YES;
        }
    }
    else {
        NSString *mediaID = nil;
        if ([params.allKeys containsObject:@"mediaid"]) {
            mediaID = [params tt_stringValueForKey:@"mediaid"];
        } else if ([params.allKeys containsObject:@"media_id"]) {
            mediaID = [params tt_stringValueForKey:@"media_id"];
        } else if ([params.allKeys containsObject:@"entry_id"]) {
            mediaID = [params tt_stringValueForKey:@"entry_id"];
        }
        if (!isEmptyString(mediaID)) {
            self = [self initWithMediaID:mediaID];
        }
    }

    if (self) {
        self.paramObj = paramObj;
        
        self.refer = [params tt_stringValueForKey:@"refer"];
        self.source = [params tt_stringValueForKey:@"enter_from"];
        self.categoryName = [params tt_stringValueForKey:@"category_name"];
        self.groupId = [params tt_stringValueForKey:@"group_id"];
        self.fromPage = [params tt_stringValueForKey:@"from_page"];
        self.profileUserId = [params tt_stringValueForKey:@"profile_user_id"];
        self.serverExtra = [params tt_stringValueForKey:@"server_extra"];
        self.enterHomepageV3ExtraParams = [params tt_dictionaryValueForKey:@"enter_homepage_v3_extra_params"];
    
        NSString *gdExtJson = [params objectForKey:@"gd_ext_json"];
        if (!isEmptyString(gdExtJson)) {
            gdExtJson = [gdExtJson stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dict = [NSString tt_objectWithJSONString:gdExtJson error:&error];
            if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                _extraTracks = [dict copy];
                if (_extraTracks[@"enter_from"]) {
                    self.source = _extraTracks[@"enter_from"];
                }
            }
        }
        
        NSInteger pageSource = [params tt_integerValueForKey:@"page_source"];
        
        if (isEmptyString(self.refer)) {
            self.refer = [self.class pageSourceStringFromType:pageSource];
        }
    }
    return self;
}

+ (NSURL * _Nonnull )redirectURLWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    if ([paramObj.sourceURL.absoluteString containsString:@"redirect"]) {
        //约定，包含redirect字段之后为重定向
        NSString *originUrlStr = paramObj.sourceURL.absoluteString;
        NSRange redirectRange = [originUrlStr rangeOfString:@"redirect"];
        NSString *newUrlStr = [originUrlStr substringFromIndex:redirectRange.location + redirectRange.length];
        if (!isEmptyString(newUrlStr)) {
            return [NSURL URLWithString:newUrlStr];
        }
    }
    
    return paramObj.sourceURL;
}

- (id)initWithUserID:(NSString *)userID
{
    if (isEmptyString(userID)) {
        return nil;
    }
    SSUserModel * sModel = [[SSUserModel alloc] initWithDictionary:@{@"user_id": userID}];
    self = [self initWithUserModel:sModel];
    if (self) {
    }
    return self;
}

- (id)initWithMediaID:(NSString *)mediaID
{
    if (isEmptyString(mediaID)) {
        return nil;
    }
    SSUserModel * sModel = [[SSUserModel alloc] initWithDictionary:@{@"media_id": mediaID}];
    self = [self initWithUserModel:sModel];
    if (self) {
        self.mediaID = mediaID;
    }
    return self;
}

- (id)initWithFriendModel:(FriendModel *)model
{
    self = [self initWithUserID:model.userID];
    if (self) {
    }
    return self;
}

- (id)initWithUserModel:(SSUserModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        self.userID = model.ID;
        self.mediaID = model.media_id;
        self.pageSource = kTTMomentPageSourceTypeDefault;
        self.templateUrl = [SSCommonLogic stringForKey:@"user_homepage_template_url"];
    }
    return self;
}

// 不使用?a=b&c=d，使用#a=b&c=d这种特殊的方式
- (NSURL *)URLForTemplateURLString:(NSString *)tempateURLString {
    NSMutableString *result = [NSMutableString stringWithCapacity:20];
    [result appendString:tempateURLString];
    
    NSDictionary *parameters = [TTNetworkUtilities commonURLParameters];
    NSString *queryString = [TTStringHelper URLQueryStringWithParameters:parameters];
    
    if (!isEmptyString(queryString)) {
        [result appendFormat:@"&%@", queryString];
    }
    
    NSString *fixedURLString = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *URL = [NSURL URLWithString:fixedURLString];
    if (!URL) {
        URL = [NSURL URLWithString:[fixedURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return URL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTPersonalHomeViewController *controller = [[TTPersonalHomeViewController alloc] initWithUserID:self.userID mediaID:self.mediaID refer:self.refer source:self.source fromPage:self.fromPage category:self.categoryName groupId:self.groupId profileUserId:self.profileUserId serverExtra:self.serverExtra enterHomepageV3ExtraParams:self.enterHomepageV3ExtraParams];
    
    NSDictionary *dict = [[_paramObj allParams] tt_dictionaryValueForKey:@"extra_user_info"];
    if (dict) {
        [controller configWithUserName:[dict tt_stringValueForKey:@"username"]
                                avatar:[dict tt_stringValueForKey:@"avatar"]
                          userAuthInfo:[dict tt_stringValueForKey:@"userAuthInfo"]
                           isFollowing:[dict tt_boolValueForKey:@"isFollowing"]
                            isFollowed:[dict tt_boolValueForKey:@"isFollowed"]
                               summary:[dict tt_stringValueForKey:@"desc"]
                           followCount:[dict tt_longValueForKey:@"followingCount"]
                             fansCount:[dict tt_longValueForKey:@"followedCount"]];
    }
    
    controller.fromColdStart = self.fromColdStartPage;
    [self.view addSubview:controller.view];
    controller.view.frame = self.view.bounds;
    [self addChildViewController:controller];
    self.shouldHideNavigationBar = NO;
    self.ttHideNavigationBar = YES;
    
}

#pragma mark - wap个人主页全局控制

+ (NSString *)pageSourceStringFromType:(TTMomentPageSourceType)type {
    if (type == kTTMomentPageSourceTypeVideo) {
        return @"video";
    }
    else if (type == kTTMomentPageSourceTypeWenda)
    {
        return @"wenda";
    }
    
    return @"default";
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    LOGD(@"出现异常，该key不存在%@",key);
}

@end
