//
//  TTContactsRedPacketGuideViewHelper.m
//  Article
//
//  Created by Jiyee Sheng on 7/31/17.
//
//

#import "TTContactsRedPacketGuideViewHelper.h"
#import "TTContactsRedPacketGuideView.h"
#import "TTContactsNotDeterminedRedPacketGuideView.h"
#import "TTContactsDeniedRedPacketGuideView.h"
#import "TTContactsRedPacketManager.h"
#import "TTUIResponderHelper.h"
#import "TTAddressBookDefines.h"
#import "TTContactsUserDefaults.h"
#import "TTContactsNetworkManager.h"
#import "TTAddressBookService.h"
#import "TTNetworkManager.h"
#import "TTContactsRecommendUserTableViewCell.h"
#import "TTContactsGuideManager.h"
#import <TTDialogDirector/TTDialogDirector.h>



static BOOL kHasGuideViewDisplayed = NO;

@interface TTContactsRedPacketGuideViewHelper ()

@property (nonatomic, strong) TTContactsRedPacketGuideView *guideView;

@end

@implementation TTContactsRedPacketGuideViewHelper

+ (BOOL)hasGuideViewDisplayedAfterLaunching {
    return kHasGuideViewDisplayed;
}

- (instancetype)init {
    if ((self = [super init])) {
        CGRect frame = CGRectMake(0, 0, [TTUIResponderHelper screenSize].width, [TTUIResponderHelper screenSize].height);
        if ([TTAddressBook isAddressBookDenied]) {
            self.guideView = [[TTContactsDeniedRedPacketGuideView alloc] initWithFrame:frame];
            [self setupGuideView];
        } else if ([TTAddressBook isFirstAccessAddressBook]) {
            self.guideView = [[TTContactsNotDeterminedRedPacketGuideView alloc] initWithFrame:frame];
            [self setupGuideView];
        }
    }

    return self;
}

- (void)setupGuideView {
    __weak typeof(self) wself = self;
    self.guideView.didCloseBlock = ^{
        __strong typeof(self) sself = wself;

        if ([TTAddressBook isAddressBookDenied]) {
            [TTTrackerWrapper eventV3:@"upload_contact_permission_set" params:@{@"action_type": @"close"}];
        } else {
            [TTTrackerWrapper eventV3:@"upload_contact_permission_open" params:@{@"action_type": @"close"}];
        }

        [sself dismiss];
    };

    self.guideView.didSubmitBlock = ^{
        __strong typeof(self) sself = wself;

        if ([TTAddressBook isAddressBookDenied]) {
            [TTTrackerWrapper eventV3:@"upload_contact_permission_set" params:@{@"action_type": @"click"}];

            // 记录时间 15 min，这个周期内授权返回有效
            [TTContactsUserDefaults setContactsAuthorizationTimestamp:[[NSDate date] timeIntervalSince1970]];

            if (&UIApplicationOpenSettingsURLString != NULL) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
#pragma clang diagnostic pop
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        } else {
            [TTTrackerWrapper eventV3:@"upload_contact_permission_open" params:@{@"action_type": @"confirm"}];

            [sself requestAuthorizationAndUploadContacts];

            [sself dismiss];
        }
    };

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookRequestAccess:) name:TTAddressBookRequestAccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookRequestAccessGranted:) name:TTAddressBookRequestAccessGrantedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookRequestAccessDenied:) name:TTAddressBookRequestAccessDeniedNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _guideView = nil;
}

- (void)dismiss {
    [self.guideView dismissWithAnimation];

    // [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
    [TTDialogDirector dequeueDialog:self];
}

- (void)addressBookRequestAccess:(NSNotification *)notification {
    [TTTrackerWrapper eventV3:@"upload_contact_contact_access" params:@{@"action_type": @"show"}];
}

- (void)addressBookRequestAccessGranted:(NSNotification *)notification {
    [TTTrackerWrapper eventV3:@"upload_contact_contact_access" params:@{@"action_type": @"confirm"}];
}

- (void)addressBookRequestAccessDenied:(NSNotification *)notification {
    [TTTrackerWrapper eventV3:@"upload_contact_contact_access" params:@{@"action_type": @"refuse"}];
}

- (void)requestAuthorizationAndUploadContacts {
    
    void (^TTUploadContactsBlock)(void (^)(), void(^)(NSError *), void (^)(NSError *)) = ^(void (^TTWillRequestAddressBook)(), void (^TTDidAccessAddressBook)(NSError *error), void (^TTDidFinishUploading)(NSError *)) {
        // read and upload contacts
        [[TTAddressBookService sharedService] loadContactsForProperties:kTTContactsOfPropertiesV2 startBlock:TTWillRequestAddressBook finishBlock:^(NSArray<TTABContact *> *records, NSError *error) {
            if (TTDidAccessAddressBook) TTDidAccessAddressBook(error); // access address book
            
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // upload addressbook
                    [TTContactsNetworkManager postContacts:records userActive:YES completion:^(NSError *error2, id jsonObj) {
                        if (!error2) {
                            [TTContactsUserDefaults setHasUploadedContacts:YES];
                        }
                        
                        if (TTDidFinishUploading) TTDidFinishUploading(error2);
                    }];
                });
            } else {
                if (TTDidFinishUploading) TTDidFinishUploading(error);
            }
        }];
    };
    
    NSTimeInterval threshold = 5.f;
    __block BOOL isUploadContactsFinished = NO;
    __block BOOL isTimeIntervalOverThreshold = NO;
    
    // 上传通讯录
    TTUploadContactsBlock(^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [TTTrackerWrapper eventV3:@"upload_contact_sync" params:@{@"action_type": @"show"}];
            
            // 一直保留显示，直到上传成功或者重试之后
            [[TTContactsGuideManager sharedManager] showIndicatorView:nil];
        });
    }, ^(NSError *error) {
        if (!error) { // 这里采用折衷方案，采用数据导入之后开始计时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(threshold * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                isTimeIntervalOverThreshold = YES;
                
                if (!isUploadContactsFinished) {
                    [TTContactsUserDefaults setUserCompleteUploadContacts];
                    [[TTContactsGuideManager sharedManager] hideIndicatorView];
                    [TTContactsRedPacketGuideViewHelper presentNoContactsRedPacketViewController];
                    
                    [TTTrackerWrapper eventV3:@"upload_contact_sync" params:@{@"action_type": @"failure"}];
                }
            });
        }
    }, ^(NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTTrackerWrapper eventV3:@"upload_contact_sync" params:@{@"action_type": @"success"}];
                
                [[TTContactsGuideManager sharedManager] hideIndicatorView];
                
                if (!isTimeIntervalOverThreshold) {
                    [TTContactsUserDefaults setUserCompleteUploadContacts];
                    isUploadContactsFinished = YES; // 如果未超时，阻止超时策略
                    
                    [self requestContactUsers];
                }
            });
        } else if (error.code == kTTAddressBookErrorUserToBeDenied) { // 用户拒绝授权
            return;
        } else if (error.code == kTTAddressBookErrorDenied) { // 授权失败
            // REMOVED
            return;
        } else {
            // 重试一次上传
            TTUploadContactsBlock(nil, nil, ^(NSError *error2){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TTContactsGuideManager sharedManager] hideIndicatorView];
                    
                    if (!isTimeIntervalOverThreshold) {
                        [TTContactsUserDefaults setUserCompleteUploadContacts];
                        isUploadContactsFinished = YES; // 如果未超时，阻止超时策略
                        
                        if (!error2) {
                            [TTTrackerWrapper eventV3:@"upload_contact_sync" params:@{@"action_type": @"success"}];
                            
                            [self requestContactUsers];
                        } else {
                            [TTTrackerWrapper eventV3:@"upload_contact_sync" params:@{@"action_type": @"failure"}];
                            
                            [TTContactsRedPacketGuideViewHelper presentNoContactsRedPacketViewController];
                        }
                    }
                });
            });
        }
    });
}

/**
 * 请求通讯录好友列表数据
 */
- (void)requestContactUsers {
    FRUserRelationContactfriendsRequestModel *requestModel = [[FRUserRelationContactfriendsRequestModel alloc] init];
    requestModel.auto_follow = @0;

    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (error) {
            [TTContactsRedPacketGuideViewHelper presentNoContactsRedPacketViewController];
            return;
        }

        FRUserRelationContactfriendsResponseModel *model = (FRUserRelationContactfriendsResponseModel *)responseModel;

        if (model && model.data && model.data.users && model.data.users.count > 0) {
            NSMutableArray *contactUsers = [[NSMutableArray alloc] initWithCapacity:model.data.users.count];
            for (FRUserRelationContactFriendsUserStructModel *friendsUserStructModel in model.data.users) {
                TTRecommendUserModel *userModel = [[TTRecommendUserModel alloc] initWithFRUserRelationContactFriendsUserStructModel:friendsUserStructModel];
                [contactUsers addObject:userModel];
            }
            [TTContactsRedPacketGuideViewHelper presentContactsRedPacketViewController:[contactUsers copy]];
        } else {
            [TTContactsRedPacketGuideViewHelper presentNoContactsRedPacketViewController];
        }
    }];
}

/**
 * 获取好友失败或者好友为空时，弹出默认红包
 */
+ (void)presentNoContactsRedPacketViewController {
    [[TTContactsRedPacketManager sharedManager] presentInViewController:[TTUIResponderHelper topmostViewController] contactUsers:nil];
}

/**
 * 获取好友成功时，弹出通讯录好友红包
 */
+ (void)presentContactsRedPacketViewController:(NSArray *)contactUsers {
    [[TTContactsRedPacketManager sharedManager] presentInViewController:[TTUIResponderHelper topmostViewController] contactUsers:contactUsers];
}

#pragma mark - TTGuideProtocol

- (TTGuidePriority)priority {
    return kTTGuidePriorityHigh;
}

- (BOOL)shouldDisplay:(id)context {
    if (![[TTContactsGuideManager sharedManager] isUserStayInExploreMainViewController]) { // 停留在首页
        return NO;
    }

    if (![[TTContactsGuideManager sharedManager] isCurrentExploreCategoryIdEqualsToMainCategoryId]) { // 停留在推荐频道
        return NO;
    }

    return [[TTContactsGuideManager sharedManager] shouldPresentContactsGuideView];
}

- (void)showWithContext:(id)context
{
    if (self.guideView) {
        [TTDialogDirector showInstantlyDialog:self shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
            return [self shouldDisplay:context];
        } showMe:^(id  _Nonnull dialogInst) {
            if ([self.guideView isKindOfClass:[TTContactsNotDeterminedRedPacketGuideView class]]) {
                [TTTrackerWrapper eventV3:@"upload_contact_permission_open" params:@{@"action_type": @"show"}];
            } else if ([self.guideView isKindOfClass:[TTContactsDeniedRedPacketGuideView class]]) {
                [TTTrackerWrapper eventV3:@"upload_contact_permission_set" params:@{@"action_type": @"show"}];
            }
            
            // 记录此次通讯录弹窗已经弹出过，作为此次的服务端检查数据就此终止
            [[TTContactsGuideManager sharedManager] setContactsGuideHasPresented];
            
            // 记录通讯录弹窗弹出时间
            [TTContactsUserDefaults setContactsGuidePresentTimestamp:[[NSDate date] timeIntervalSince1970]];
            
            [self.guideView showInKeyWindowWithAnimation];
            
        } hideForcedlyMe:nil];
    } else {
        if ([self shouldDisplay:context]) {
            // 重置通讯录弹窗授权时间，保证在 15 min 之内重复启动不会重复弹出
            [TTContactsUserDefaults setContactsAuthorizationTimestamp:0];
            
            [self requestAuthorizationAndUploadContacts];
            [self dismiss];
        }
    }
    
    kHasGuideViewDisplayed = YES;
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
