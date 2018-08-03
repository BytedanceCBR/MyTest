//
//  TTAuthorizeManager.m
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeManager.h"



NSString * const TTFollowSuccessForPushGuideNotification = @"TTFollowSuccessForPushGuideNotification";;
NSString * const TTCommentSuccessForPushGuideNotification = @"TTCommentSuccessForPushGuideNotification";
NSString * const TTWDFollowPublishQASuccessForPushGuideNotification = @"TTWDFollowPublishQASuccessForPushGuideNotification"; // 问答提问和回答
NSString * const TTUGCPublishSuccessForPushGuideNotification = @"TTUGCPublishSuccessForPushGuideNotification"; // UGC中发帖

@interface TTAuthorizeManager ()

/*
 授权弹窗相关的model
 */
@property(nonatomic,strong)TTAuthorizeModel *authorizeModel;

@end

@implementation TTAuthorizeManager {
    
}

+ (instancetype)sharedManager {
    static TTAuthorizeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTAuthorizeManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFollowSuccessNotification:) name:TTFollowSuccessForPushGuideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCommentSuccessNotification:) name:TTCommentSuccessForPushGuideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWDFollowPublishQASuccessNotification:) name:TTWDFollowPublishQASuccessForPushGuideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUGCPublishSuccessNotification:) name:TTUGCPublishSuccessForPushGuideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveFollowSuccessNotification:(NSNotification *)notification
{
    TTPushNoteGuideFireReason reason = [notification.userInfo[@"reason"] integerValue];
    if (reason != TTPushNoteGuideFireReasonNone) {
        TTAuthorizePushGuideChangeFireReason(reason);
    }
}

- (void)receiveCommentSuccessNotification:(NSNotification *)notification
{
    TTPushNoteGuideFireReason reason = [notification.userInfo[@"reason"] integerValue];
    if (reason != TTPushNoteGuideFireReasonNone) {
        TTAuthorizePushGuideChangeFireReason(reason);
    }
}

- (void)receiveWDFollowPublishQASuccessNotification:(NSNotification *)notification
{
    TTPushNoteGuideFireReason reason = [notification.userInfo[@"reason"] integerValue];
    if (reason != TTPushNoteGuideFireReasonNone) {
        TTAuthorizePushGuideChangeFireReason(reason);
    }
}

- (void)receiveUGCPublishSuccessNotification:(NSNotification *)notification
{
    TTPushNoteGuideFireReason reason = [notification.userInfo[@"reason"] integerValue];
    if (reason != TTPushNoteGuideFireReasonNone) {
        TTAuthorizePushGuideChangeFireReason(reason);
    }
}

//- (TTAuthorizeAddressBookObj *)addressObj {
//    if (!_addressObj) {
//        _addressObj = [[TTAuthorizeAddressBookObj alloc] initWithAuthorizeModel:self.authorizeModel];
//    }
//    return _addressObj;
//}

- (TTAuthorizePushObj *)pushObj {
    if (!_pushObj) {
        _pushObj = [[TTAuthorizePushObj alloc] initWithAuthorizeModel:self.authorizeModel];
    }
    return _pushObj;
}

- (TTAuthorizeLoginObj *)loginObj {
    if (!_loginObj) {
        _loginObj = [[TTAuthorizeLoginObj alloc] initWithAuthorizeModel:self.authorizeModel];
    }
    return _loginObj;
}

- (TTAuthorizeLocationObj *)locationObj {
    if (!_locationObj) {
        _locationObj = [[TTAuthorizeLocationObj alloc] initWithAuthorizeModel:self.authorizeModel];
    }
    return _locationObj;
}

- (TTAuthorizeModel *)authorizeModel {
    if (!_authorizeModel) {
        _authorizeModel = [[TTAuthorizeModel alloc] init];
        [_authorizeModel loadData];
    }
    return _authorizeModel;
}

@end
