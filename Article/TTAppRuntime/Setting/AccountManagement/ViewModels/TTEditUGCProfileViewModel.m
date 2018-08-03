//
//  TTEditUGCProfileViewModel.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUGCProfileViewModel.h"
#import "TTEditUserProfileView.h"
#import "NSStringAdditions.h"
#import "UIImagePickerController+TTBlocks.h"

#import "TTEditUserProfileViewController.h"
#import "TTEditUGCTableViewControllerImp.h"

#import "TTEditUGCProfileViewModel+Notification.h"
#import "NSString+TTLength.h"
#import "TTEditUserProfileViewModel+Network.h"




/**
 *  账号合并，长度描述
 *  @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=59712405
 */
@implementation TTEditUGCProfileViewModel

#pragma mark - TTUserProfileInputViewDelegate

- (void)cancelButtonClicked:(TTUserProfileInputView *)view
{
    self.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
    
    // log
    if (view.type == TTUserProfileInputViewTypeName) {
        wrapperTrackEvent(@"account_setting_username", @"cancel");
    } else if (view.type == TTUserProfileInputViewTypeSign) {
        wrapperTrackEvent(@"account_setting_signature", @"cancel");
    }
}

- (void)confirmButtonClicked:(TTUserProfileInputView *)view
{
    self.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
    
    if (view.type == TTUserProfileInputViewTypeName) {
        // 修改用户名
        NSString *name = [view.textView.text trimmed];
        if([name isEqualToString:self.editableAuditInfo.name]) {
            // 当用户修改自己的昵称名，新昵称名与原昵称名相同时，显示“与原来昵称相同”
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来昵称相同", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            
            NSUInteger tt_byteLength = [name tt_lengthOfBytes];
            if(tt_byteLength < 2*2 || tt_byteLength > 20*2) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"用户名长度请控制在2-20个汉字", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            } else {
                // 上传
                [self uploadUserAuditContent:name forName:YES];
            }
        }
    } else if (view.type == TTUserProfileInputViewTypeSign){
        // 修改签名（介绍）
        NSString *desp = view.textView.text;
        NSUInteger tt_byteLength = [desp tt_lengthOfBytes];
        if([desp isEqualToString:self.editableAuditInfo.userDescription]) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来签名相同", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else if(tt_byteLength > 30*2) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"签名长度请控制在0-30个汉字", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            if (tt_byteLength == 0) {
                desp = @"  ";
            }
            
            // 上传
            [self uploadUserAuditContent:desp forName:NO];
        }
    }
    
    // log
    if (view.type == TTUserProfileInputViewTypeName) {
        wrapperTrackEvent(@"account_setting_username", @"confirm");
    } else if (view.type == TTUserProfileInputViewTypeSign) {
        wrapperTrackEvent(@"account_setting_signature", @"confirm");
    }
}

/**
 *  更新用户名还是描述
 *
 *  @param nameOrDesp name or desp
 */
- (void)uploadUserAuditContent:(NSString *)content forName:(BOOL)nameOrDesp
{
    if (isEmptyString(content))return;
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    __weak typeof(self) wself = self;
    void (^willStartBlock)() = ^() {
        __strong typeof(wself) sself = wself;
        if (nameOrDesp) {
            sself.editableAuditInfo.editingItem = kTTEditingUserItemTypeUsername;
            sself.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagUsername;
        } else {
            sself.editableAuditInfo.editingItem = kTTEditingUserItemTypeDescription;
            sself.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagDescription;
        }
        [sself reloadViewModel];
    };
    
    
    void (^didCompletedBlock)(TTAccountUserEntity *, NSError *) = ^(TTAccountUserEntity *userEntity, NSError *error) {
        __strong typeof(wself) sself = wself;
        // update flags
        if (sself.editableAuditInfo.editingItem == kTTEditingUserItemTypeUsername) {
            sself.editableAuditInfo.modifiedFlags &= ~kTTUserInfoModifiedFlagUsername;
        } else if (sself.editableAuditInfo.editingItem == kTTEditingUserItemTypeDescription) {
            sself.editableAuditInfo.modifiedFlags &= ~kTTUserInfoModifiedFlagDescription;
        }
        sself.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
        
        
        if (error) {
            // 名字重复的问题等错误信息，由服务端返回
            NSString *hint = [error.userInfo objectForKey:@"description"];
            if (isEmptyString(hint)) hint = [error.userInfo objectForKey:TTAccountErrMsgKey];
            if (isEmptyString(hint)) hint = NSLocalizedString(@"修改失败，请稍后重试", nil);
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            NSString *username = [userEntity.auditInfoSet username];
            NSString *userDesp = [userEntity.auditInfoSet userDescription];
            if (!isEmptyString(username) && nameOrDesp) {
                sself.editableAuditInfo.name = username;
            }
            if (!isEmptyString(userDesp) && !nameOrDesp) {
                sself.editableAuditInfo.userDescription = userDesp;
            }
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"修改成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
        
        // 使用新的数据刷新
        [sself reloadViewModel];
    };
    
    [self uploadUserProfileInfo:@{(nameOrDesp ? TTAccountUserNameKey : TTAccountUserDescriptionKey) : content} startBlock:willStartBlock completion:didCompletedBlock];
}

#pragma mark - pick image and upload image

- (void)imagePickerWithSource:(UIImagePickerControllerSourceType)sourceType forAvatar:(BOOL)bAvatar ofCell:(TTEditUserProfileItemCell *)cell
{
    __weak typeof(self) wself = self;
    UIImagePickerControllerDidFinishBlock completionCallback = ^(UIImagePickerController *picker, NSDictionary *info) {
        __strong typeof(wself) sself = wself;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        // iOS 9 的系统 bug，在 iPad 不能选取图片显示区域，系统自动给截了左上角区域；
        // workaround : iPad 暂时先取 `UIImagePickerControllerOriginalImage` (会导致图片挤压变形).
        NSString *imageType = UIImagePickerControllerEditedImage;
        if ([TTDeviceHelper isPadDevice] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                imageType = UIImagePickerControllerOriginalImage;
            }
        }
        UIImage *image = [info objectForKey:imageType];
        if (image) {
            // upload
            [sself uploadImage:image forAvatar:bAvatar];
        }
    };
    UIImagePickerControllerDidCancelBlock cancelCallback = ^(UIImagePickerController *picker) {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    };
    
    UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
    imageController.sourceType = sourceType;
    imageController.allowsEditing = YES;
    imageController.completionBlock = completionCallback;
    imageController.cancellationBlock = cancelCallback;
    
    if ([self.topNavigationController isKindOfClass:[UINavigationController class]]) {
        [self.topNavigationController presentViewController:imageController animated:YES completion:NULL];
    }
}

- (void)uploadImage:(UIImage *)image forAvatar:(BOOL)avatarOrBg
{
    if (!image) return;
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    __weak typeof(self) wself = self;
    void (^willStartBlock)() = ^() {
        __strong typeof(wself) sself = wself;
        if (avatarOrBg) {
            sself.editableAuditInfo.editingItem = kTTEditingUserItemTypeAvatar;
            sself.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagAvatar;
        } else {
            sself.editableAuditInfo.editingItem = kTTEditingUserItemTypeBgImage;
            sself.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagAvatar;
        }
        [sself reloadViewModel];
    };
    
    
    void (^didCompletedBlock)(NSString *, NSError *) = ^(NSString *imageURIString, NSError *error) {
        __strong typeof(wself) sself = wself;
        if (error || isEmptyString(imageURIString)) {
            if (sself.editableAuditInfo.editingItem == kTTEditingUserItemTypeAvatar) {
                sself.editableAuditInfo.modifiedFlags &= ~kTTUserInfoModifiedFlagAvatar;
            } else if (sself.editableAuditInfo.editingItem == kTTEditingUserItemTypeBgImage) {
                sself.editableAuditInfo.modifiedFlags &= ~kTTUserInfoModifiedFlagBgImage;
            }
            sself.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
            sself.editableAuditInfo.avatarImage = nil;
            sself.editableAuditInfo.bgImage = nil;
            
            NSString *hint = [error.userInfo objectForKey:@"description"];
            if (isEmptyString(hint)) hint = NSLocalizedString(@"修改失败，请稍后重试", nil);
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            
            // 使用更新的数据刷新
            [sself reloadViewModel];
        } else {
            // 防止crash
            imageURIString = imageURIString ? : @"";
            [sself uploadUserProfileInfo:@{TTAccountUserAvatarKey : imageURIString} startBlock:nil completion:^(TTAccountUserEntity *userEntity, NSError *error) {
                __strong typeof(wself) sself2 = wself;
                if (sself2.editableAuditInfo.editingItem == kTTEditingUserItemTypeAvatar) {
                    sself2.editableAuditInfo.avatarImage = image;
                    sself2.editableAuditInfo.modifiedFlags &= ~kTTUserInfoModifiedFlagAvatar;
                } else if (sself2.editableAuditInfo.editingItem == kTTEditingUserItemTypeBgImage) {
                    sself2.editableAuditInfo.bgImage = image;
                    sself2.editableAuditInfo.modifiedFlags &= ~kTTUserInfoModifiedFlagBgImage;
                }
                sself2.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
                
                
                if (error) {
                    sself2.editableAuditInfo.avatarImage = nil;
                    sself2.editableAuditInfo.bgImage = nil;
                    
                    NSString *hint = [error.userInfo objectForKey:@"description"];
                    if (isEmptyString(hint)) hint = [error.userInfo objectForKey:TTAccountErrMsgKey];
                    if (isEmptyString(hint)) hint = NSLocalizedString(@"头像修改失败，请稍后重试", nil);
                    
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                } else {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"头像修改成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                    
                    NSString *imageURL = avatarOrBg ? [userEntity.auditInfoSet userAvatarURLString] : userEntity.bgImgURL;
                    if (!isEmptyString(imageURL)) {
                        if (avatarOrBg) {
                            sself2.editableAuditInfo.avatarURL = imageURL;
                        } else {
                            // sself2.editableAuditInfo.bg_img_url = imageURL;
                        }
                    }
                }
                
                // 使用更新的数据刷新
                [sself2 reloadViewModel];
            }];
        }
    };
    
    [self uploadUserPhoto:image startBlock:willStartBlock completion:didCompletedBlock];
}

#pragma mark - override methods

- (id<UITableViewDelegate,UITableViewDataSource>)tableViewDelegateImp {
    return [[TTEditUGCTableViewControllerImp alloc] initWithViewModel:self];
}
@end
