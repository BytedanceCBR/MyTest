//
//  TTAddFriendsViewController.h
//  Article
//  上传通讯录之后引导用户关注
//
//  Created by Jiyee Sheng on 6/9/17.
//
//

extern NSString *const kPresentAddFriendsViewNotification;
extern NSString *const kDismissAddFriendsViewNotification;
extern NSString *const kUploadContactsSuccessForInvitePageNotification;

#import <TTUIWidget/SSViewControllerBase.h>

@class FRUserRelationContactFriendsUserStructModel;
@interface TTContactsAddFriendsViewController : SSViewControllerBase

@property (nonatomic, assign) BOOL isVisible;

- (void)showInView:(UIView *)view withUsers:(NSArray <FRUserRelationContactFriendsUserStructModel *> *)users;

- (void)closeIfNeeded;

@end
