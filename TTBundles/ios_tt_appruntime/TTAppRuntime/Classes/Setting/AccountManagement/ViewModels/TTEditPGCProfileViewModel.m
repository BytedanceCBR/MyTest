//
//  TTEditPGCProfileViewModel.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditPGCProfileViewModel.h"
#import "TTEditPGCTableViewControllerImp.h"
#import "TTPGCUserFooterView.h"
#import "NSStringAdditions.h"
#import "UIImagePickerController+TTBlocks.h"
#import "NSString+TTLength.h"

#import "TTEditUserProfileViewModel+Network.h"



@implementation TTEditPGCProfileViewModel

#pragma mark - TTEditUserProfileViewDelegate

- (void)cancelButtonClicked:(TTUserProfileInputView *)view {
    self.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
    
    // log
    if (view.type == TTUserProfileInputViewTypeName) {
        wrapperTrackEvent(@"account_setting_username", @"cancel");
    } else if (view.type == TTUserProfileInputViewTypeSign) {
        wrapperTrackEvent(@"account_setting_signiture", @"cancel");
    }
}

- (void)confirmButtonClicked:(TTUserProfileInputView *)view {
    self.editableAuditInfo.editingItem = kTTEditingUserItemTypeNone;
    
    if (view.type == TTUserProfileInputViewTypeName) {
        NSString *username = [view.textView.text trimmed];
        if([username isEqualToString:self.editableAuditInfo.name]) {
            // 当用户修改自己的昵称名，新昵称名与原昵称名相同时，显示“与原来昵称相同”
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来昵称相同", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            });
        } else {
            // 与原来昵称不相同
            //            NSUInteger length = 0;
            //            for (NSUInteger i = 0; i < [username length]; i++) {
            //                int ch = [username characterAtIndex:i];
            //                NSString *str = [username substringWithRange:NSMakeRange(i, 1)];
            //                if([str rangeOfCharacterFromSet:self.nameLatinCharacterSet].location != NSNotFound ||
            //                   (ch >= 0x4e00 && ch < 0x9fff) /*|| strlen([str UTF8String]) >= 3*/) {
            //                    length++;
            //                } else {
            //                    dispatch_async(dispatch_get_main_queue(), ^{
            //                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"用户名仅允许中英文和数字", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            //                    });
            //                    return;
            //                }
            //            }
            
            NSUInteger tt_byteLength = [username tt_lengthOfBytes];
            if(tt_byteLength < 2*2 || tt_byteLength > 20*2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"用户名长度请控制在2-20个汉字", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                });
            } else {
                self.editableAuditInfo.name = username;
                self.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagUsername;
                [self reloadViewModel];
            }
        }
    } else if (view.type == TTUserProfileInputViewTypePGCSign){
        // 点击用户签名(介绍)
        NSString *userDesp = [view.textView.text trimmed];
        NSUInteger tt_byteLength = [userDesp tt_lengthOfBytes];
        if([userDesp isEqualToString:self.editableAuditInfo.userDescription]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来签名相同", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            });
        } else if(tt_byteLength < 10*2 || tt_byteLength > 30*2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"签名长度请控制在10-30个汉字", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            });
        } else {
            if (tt_byteLength == 0) {
                userDesp = @"  ";
            }
            self.editableAuditInfo.userDescription = userDesp;
            self.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagDescription;
            [self reloadViewModel];
        }
    }
    
    // log
    if (view.type == TTUserProfileInputViewTypeName) {
        wrapperTrackEvent(@"account_setting_username", @"confirm");
    } else if (view.type == TTUserProfileInputViewTypePGCSign) {
        wrapperTrackEvent(@"account_setting_signiture", @"confirm");
    }
}

#pragma mark - pick image and upload image

- (void)imagePickerWithSource:(UIImagePickerControllerSourceType)sourceType forAvatar:(BOOL)bAvatar ofCell:(TTEditUserProfileItemCell *)cell {
    __weak typeof(self) wself = self;
    UIImagePickerControllerDidFinishBlock completionCallback = ^(UIImagePickerController *picker, NSDictionary *info) {
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        __strong typeof(wself) sself = wself;
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
            if (bAvatar) {
                sself.editableAuditInfo.avatarImage = image;
                self.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagAvatar;
            } else {
                sself.editableAuditInfo.bgImage = image;
                self.editableAuditInfo.modifiedFlags |= kTTUserInfoModifiedFlagBgImage;
            }
            [self reloadViewModel];
            
            // 预先上传图片，得到上传成功后的imageURI
            [sself uploadUserPhoto:image startBlock:nil completion:^(NSString *imageURIString, NSError *error) {
                if (!error && imageURIString) {
                    if (bAvatar) {
                        self.editableAuditInfo.avatarImageURI = imageURIString;
                    } else {
                        self.editableAuditInfo.bgImageURI = imageURIString;
                    }
                }
            }];
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

#pragma mark - override methods

- (id<UITableViewDelegate,UITableViewDataSource>)tableViewDelegateImp {
    return [[TTEditPGCTableViewControllerImp alloc] initWithViewModel:self];
}

- (SSThemedView *)tableFooterView {
    return [[TTPGCUserFooterView alloc] initWithFrame:CGRectMake(0, 0, self.profileView.tableView.width, 0)];
}
@end
