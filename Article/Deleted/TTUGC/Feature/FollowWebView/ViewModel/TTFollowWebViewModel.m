//
//  TTFollowWebViewModel.m
//  Article
//
//  Created by 王霖 on 16/8/19.
//
//

#import "TTFollowWebViewModel.h"
#import "ArticleURLSetting.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTNetworkManager/TTNetworkUtil.h>
#import "TTNetworkUtilities.h"

@interface TTFollowWebViewModel ()

@property (nonatomic, copy) NSURL * url;
@property (nonatomic, copy) NSURL * baseURL;
@property (nonatomic, copy) NSString * html;
@property (nonatomic, copy) void(^ refreshBlock)(NSString *, TTFollowNotify *);
@property (nonatomic, strong) TTFollowNotify * lastfollowNotify;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isFollowNotifyTriggerRequesting;

@property (nonatomic, copy) void(^ willEnterForegroundBlock)(void);
@property (nonatomic, copy) void(^ didEnterBackgroundBlock)(void);

@end

@implementation TTFollowWebViewModel

#pragma mark - Life circle

- (instancetype)initWithRefreshBlock:(nullable void(^)(NSString * _Nullable html, TTFollowNotify * _Nullable followNotify))refreshBlock
                 willEnterForeground:(nullable void(^)(void))willEnterForegroundBlock
                  didEnterBackground:(nullable void(^)(void))didEnterBackgroundBlock {
    self = [super init];
    if (self) {
        NSURL * baseURL = [TTNetworkUtil URLWithURLString:[ArticleURLSetting myFollowURL]].copy;
        if ([baseURL.scheme.lowercaseString rangeOfString:@"https"].location == NSNotFound) {
            //因为APP一启动就会触发关心tab请求，url选路还没完成，强制使用https防劫持
            NSURLComponents * components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:NO];
            components.scheme = @"https";
            baseURL = [components URL];
        }
        
        _url = [TTNetworkUtil URLWithURLString:[TTNetworkUtil URLString:baseURL.absoluteString appendCommonParams:[TTNetworkUtilities commonURLParameters]]].copy;
        _baseURL = baseURL;
        _refreshBlock = [refreshBlock copy];
        _willEnterForegroundBlock = [willEnterForegroundBlock copy];
        _didEnterBackgroundBlock = [didEnterBackgroundBlock copy];
        [self addNotification];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithRefreshBlock:nil willEnterForeground:nil didEnterBackground:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)refreshWithCompletion:(nullable void(^)(NSError * _Nullable error, NSString * _Nullable html))completion {
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    __weak typeof(self) wSelf = self;
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:_baseURL.absoluteString
                                                       params:nil
                                                       method:@"GET"
                                             needCommonParams:YES
                                                     callback:^(NSError *error, id obj) {
                                                         wSelf.isRequesting = NO;
                                                         if (error) {
                                                             if (completion) {
                                                                 completion(error, nil);
                                                             }
                                                         }else {
                                                             NSString * html = nil;
                                                             if ([obj isKindOfClass:[NSData class]]) {
                                                                 html = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                                                             }
                                                             if ([wSelf isValidHTML:html]) {
                                                                 wSelf.html = html;
                                                                 if (completion) {
                                                                     completion(nil, html);
                                                                 }
                                                             }else {
                                                                 error = [NSError errorWithDomain:@"kTTFollowErrorDomain"
                                                                                             code:1
                                                                                         userInfo:nil];
                                                                 if (completion) {
                                                                     completion(error, nil);
                                                                 }
                                                             }
                                                         }
                                                     }];
}

- (void)refreshWithFollowNotify:(TTFollowNotify *)followNotify {
    if (self.isFollowNotifyTriggerRequesting) {
        self.lastfollowNotify = followNotify;
        return;
    }
    self.isFollowNotifyTriggerRequesting = YES;
    self.lastfollowNotify = nil;
    __weak typeof(self) wSelf = self;
    self.url = [TTNetworkUtil URLWithURLString:[TTNetworkUtil URLString:[ArticleURLSetting myFollowURL] appendCommonParams:[TTNetworkUtilities commonURLParameters]]].copy;
    self.baseURL = [TTNetworkUtil URLWithURLString:[ArticleURLSetting myFollowURL]].copy;
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:_baseURL.absoluteString
                                                       params:nil
                                                       method:@"GET"
                                             needCommonParams:YES
                                                     callback:^(NSError *error, id obj) {
                                                         wSelf.isFollowNotifyTriggerRequesting = NO;
                                                         if (!error) {
                                                             NSString * html = nil;
                                                             if ([obj isKindOfClass:[NSData class]]) {
                                                                 html = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                                                             }
                                                             if ([wSelf isValidHTML:html]) {
                                                                 wSelf.html = html;
                                                                 if (wSelf.refreshBlock) {
                                                                     wSelf.refreshBlock(html, followNotify);
                                                                 }
                                                             }
                                                         }
                                                         if (wSelf.lastfollowNotify) {
                                                             [wSelf refreshWithFollowNotify:wSelf.lastfollowNotify];
                                                         }
                                                     }];
}

#pragma mark - Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_willEnterForegroundBlock) {
        _willEnterForegroundBlock();
    }
}

- (void)didEnterBackground:(NSNotification *)notification {
    if (_didEnterBackgroundBlock) {
        _didEnterBackgroundBlock();
    }
}

#pragma mark - Utils

- (BOOL)isValidHTML:(NSString *)html {
    if (isEmptyString(html)) {
        return NO;
    }
    return YES;
}

@end
