//
//  TTEditUserProfileViewModel.m
//  Article
//
//  Created by Zuopeng Liu on 7/28/16.
//
//

#import "TTEditUserProfileViewModel.h"
#import <NSStringAdditions.h>
#import <NSObject+FBKVOController.h>
#import <TTUIResponderHelper.h>

#import "SSMyUserModel.h"
#import <TTAccountBusiness.h>

#import "TTUserProfileInputView.h"
#import "ArticleMobileNumberViewController.h"
#import "ArticleMobilePasswordViewController.h"
#import "ArticleMobileChangeViewController.h"
#import "TTEditUserProfileViewController.h"



@interface TTEditUserProfileViewModel ()
<
TTEditUserProfileViewDelegate
>
@property (nonatomic, strong, readwrite) id<UITableViewDelegate, UITableViewDataSource> tableViewDelegate;
@property (nonatomic, strong, readwrite) NSCharacterSet *nameLatinCharacterSet;

// views
@property (nonatomic, strong, readwrite) TTEditUserProfileView *profileView;

@property (nonatomic, assign) BOOL backButtonDisabled;
@end
@implementation TTEditUserProfileViewModel
- (instancetype)initWithHostViewController:(TTEditUserProfileViewController *)hostVC
{
    if ((self = [self init])) {
        _hostViewController = hostVC;
    }
    return self;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _hostViewController = nil;
        _tableViewDelegate = [self tableViewDelegateImp];
        self.profileView.tableView.delegate = _tableViewDelegate;
        self.profileView.tableView.dataSource = _tableViewDelegate;
        
        // init editable user info
        //        [self refreshEditableUserInfo];
        
        [self registerNotifications];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterNotifications];
    
    _profileView.delegate = nil;
    _profileView.tableView.delegate = nil;
    _profileView.tableView.dataSource = nil;
    
    _tableViewDelegate = nil;
    
    if (_editableAuditInfo) {
        @try {
            [self.KVOController unobserveAll];
        } @catch (NSException *exception) {
        } @finally {
            _editableAuditInfo = nil;
        }
    }
}

- (void)refreshEditableUserInfo
{
    TTAccountUserAuditSet *newAuditInfo = [[TTAccountManager currentUser].auditInfoSet copy];
    SSMyUserModel *myUser = [TTAccountManager sharedManager].myUser;
    if (!newAuditInfo && !myUser) return;
    
    if (!_editableAuditInfo) {
        _editableAuditInfo = [TTEditableUserAuditInfo new];
        
        @try {
            [self.KVOController observe:_editableAuditInfo keyPath:@"modifiedFlags" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
    _editableAuditInfo.isAuditing  = [newAuditInfo isAuditing];
    _editableAuditInfo.editEnabled = YES;//[newAuditInfo modifyUserInfoEnabled];
    _editableAuditInfo.name        = [newAuditInfo username];
    _editableAuditInfo.avatarURL   = [newAuditInfo userAvatarURLString];
    _editableAuditInfo.userDescription = [newAuditInfo userDescription];
    _editableAuditInfo.gender = @([myUser.gender integerValue]);
    _editableAuditInfo.birthday = myUser.birthday;
    _editableAuditInfo.area = myUser.area;
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == _editableAuditInfo && [keyPath isEqualToString:@"modifiedFlags"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.hostViewController respondsToSelector:@selector(updateSaveButtonStatus)]) {
            [self.hostViewController performSelector:@selector(updateSaveButtonStatus)];
        }
#pragma clang diagnostic pop
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - events of notifications

- (void)applicationWillEnterForeground
{
    [self reloadViewModel];
}

#pragma mark - TTEditUserProfileViewDelegate

- (void)editUserProfileView:(TTEditUserProfileView *)aView goBack:(id)sender
{
    [self.hostViewController goBack:sender];
}

#pragma mark - public methods

- (__autoreleasing id<UITableViewDelegate,UITableViewDataSource>)tableViewDelegateImp
{
    return nil;
}

- (void)imagePickerWithSource:(UIImagePickerControllerSourceType)sourceType forAvatar:(BOOL)bAvatar ofCell:(TTEditUserProfileItemCell *)cell
{
    
}

- (SSThemedView *)tableFooterView
{
    return [SSThemedView new];
}

- (void)reloadViewModel
{
    if (!_editableAuditInfo) {
        [self refreshEditableUserInfo];
    }
    
    [self.profileView reloadData];
}

- (BOOL)hasModifiedUserAuditInfo
{
    return (!_editableAuditInfo || _editableAuditInfo.modifiedFlags == kTTUserInfoModifiedFlagNone) ? NO : YES;
}

#pragma mark - Getter

- (UINavigationController *)topNavigationController
{
    return [TTUIResponderHelper topNavigationControllerFor:self.hostViewController];
}


#pragma mark - lazied load

- (NSCharacterSet *)nameLatinCharacterSet
{
    if (!_nameLatinCharacterSet) {
        _nameLatinCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"];
    }
    return _nameLatinCharacterSet;
}

- (TTEditUserProfileView *)profileView
{
    if (!_profileView) {
        _profileView = [[TTEditUserProfileView alloc] initWithFrame:CGRectZero];
        _profileView.delegate = self;
        _profileView.tableView.delegate   = _tableViewDelegate;
        _profileView.tableView.dataSource = _tableViewDelegate;
        _profileView.tableView.tableFooterView = [self tableFooterView];
    }
    return _profileView;
}
@end
