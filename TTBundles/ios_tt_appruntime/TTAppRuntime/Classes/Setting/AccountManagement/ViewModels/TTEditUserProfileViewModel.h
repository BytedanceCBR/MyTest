//
//  TTEditUserProfileViewModel.h
//  Article
//
//  Created by Zuopeng Liu on 7/28/16.
//
//

#import <Foundation/Foundation.h>
#import "SSViewControllerBase.h"
#import "TTEditUserProfileView.h"
#import "TTUserProfileInputView.h"
#import <TTAccountBusiness.h>
#import "TTEditableUserAuditInfo.h"
#import "TTEditUserProfileItemCell.h"



@class TTEditUserProfileViewController;
@interface TTEditUserProfileViewModel <ObjectType: id<UITableViewDelegate, UITableViewDataSource>> : NSObject
<
TTUserProfileInputViewDelegate,
TTAccountMulticastProtocol
>
@property (nonatomic,   weak, readonly) TTEditUserProfileViewController *hostViewController;
@property (nonatomic, strong, readonly) UINavigationController *topNavigationController;
@property (nonatomic, strong, readonly) TTEditUserProfileView *profileView;

@property (nonatomic,   weak, readonly) TTAccountManager *accountManager;
@property (nonatomic, strong, readonly) NSCharacterSet *nameLatinCharacterSet;

@property (nonatomic, strong) TTEditableUserAuditInfo *editableAuditInfo;

- (instancetype)initWithHostViewController:(TTEditUserProfileViewController *)hostVC;

- (void)reloadViewModel;
- (void)refreshEditableUserInfo;
- (BOOL)hasModifiedUserAuditInfo;

/**
 *  重载注册和取消通知，必须首先调用父类
 */
- (void)registerNotifications;
- (void)unregisterNotifications;

- (void)imagePickerWithSource:(UIImagePickerControllerSourceType)sourceType forAvatar:(BOOL)bAvatar ofCell:(TTEditUserProfileItemCell *)cell;

/**
 *  must be override
 *
 *  @return default is nil
 */
- (ObjectType)tableViewDelegateImp;
- (SSThemedView *)tableFooterView;
@end
