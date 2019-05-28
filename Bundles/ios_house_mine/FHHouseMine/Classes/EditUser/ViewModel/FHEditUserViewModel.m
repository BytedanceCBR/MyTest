//
//  FHEditUserViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import "FHEditUserViewModel.h"
#import <TTHttpTask.h>
#import <TTRoute.h>
#import "FHEditUserBaseCell.h"
#import <TTAccountBusiness.h>
#import "FHEditableUserInfo.h"
#import "TTURLUtils.h"
#import "FHEnvContext.h"
#import "FHEditingInfoController.h"
#import "UIActionSheet+TTBlocks.h"
#import "UIImagePickerController+TTBlocks.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHMineAPI.h"

@interface FHEditUserViewModel()<UITableViewDelegate,UITableViewDataSource,FHEditingInfoControllerDelegate>

@property(nonatomic, strong) NSArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) FHEditableUserInfo *userInfo;
@property(nonatomic, weak) FHEditUserController *viewController;

@end

@implementation FHEditUserViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHEditUserController *)viewController {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:NSClassFromString(@"FHEditUserImageCell") forCellReuseIdentifier:@"imageCellId"];
        [tableView registerClass:NSClassFromString(@"FHEditUserTextCell") forCellReuseIdentifier:@"textCellId"];
        
        self.viewController = viewController;
    }
    return self;
}

- (void)initData {
    self.dataList = @[
                      @[
                          @{
                              @"name":@"头像",
                              @"key":@"avatar",
                              @"cellId":@"imageCellId",
                              @"cellClassName":@"FHEditUserImageCell",
                              @"imageUrl":(self.userInfo.avatarURL ? self.userInfo.avatarURL : @""),
                              },
                          @{
                              @"name":@"昵称",
                              @"key":@"userName",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":(self.userInfo.name ? self.userInfo.name : @"")
                              },
                          @{
                              @"name":@"介绍",
                              @"key":@"userDesc",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":(self.userInfo.userDescription ? self.userInfo.userDescription : @"")
                              },
                          ],
                      @[
                          @{
                              @"name":@"注销账号",
                              @"key":@"unRegister",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":@""
                              },
                          ]
                         ];
}

- (void)loadRequest {
    if ([TTAccountManager isLogin]) {
        __weak typeof(self) wself = self;
        
        [TTAccount getUserInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            __weak typeof(wself) sself = wself;
            if (!error) {
                sself.userInfo.name        = userEntity.name;
                sself.userInfo.avatarURL  = userEntity.avatarURL;
                sself.userInfo.userDescription = userEntity.userDescription;
                
                [sself reloadViewModel];
            }
        }];
    }
}

- (void)reloadViewModel {
    if (!_userInfo) {
        [self refreshUserInfo];
    }
    
    [self initData];
    [self.tableView reloadData];
}

- (void)refreshUserInfo {
    TTAccountUserAuditSet *newAuditInfo = [[TTAccountManager currentUser].auditInfoSet copy];
    TTAccountUserEntity* userInfo = [[TTAccount sharedAccount] user];
    if (!newAuditInfo && !userInfo) return;
    
    if (!_userInfo) {
        _userInfo = [[FHEditableUserInfo alloc] init];
    }
    
    _userInfo.editEnabled = YES;
    _userInfo.name        = userInfo.name;
    _userInfo.avatarURL   = userInfo.avatarURL;
    _userInfo.userDescription = userInfo.userDescription;
}

- (void)triggerLogoutUnRegister {
    NSDictionary *params = @{@"category":@"event_v3",@"page_type":@"minetab"};
    [FHEnvContext recordEvent:params andEventKey:@"account_cancellation"];
    
    
    NSString *unencodedString = @"http://m.haoduofangs.com/f100/inner/valuation/delcount/";
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)unencodedString,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",encodedString];
    
    NSURL *url = [TTURLUtils URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

- (void)goToEditingInfo:(NSString *)key {
    NSString *urlStr = nil;
    NSMutableDictionary *dict = @{}.mutableCopy;
    if([key isEqualToString:@"userName"]){
        dict[@"title"] = @"昵称";
        urlStr = @"sslocal://editingInfo?type=1";
    }else if([key isEqualToString:@"userDesc"]){
        dict[@"title"] = @"介绍";
        urlStr = @"sslocal://editingInfo?type=2";
    }
    dict[@"user_info"] = self.userInfo;
    
    NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegateTable addObject:self];
    
    dict[@"delegate"] = delegateTable;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    if (urlStr) {
        NSURL* url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)changeAvatar {
    UIActionSheet      *actionSheet = nil;
    NSArray<NSNumber*> *imageSourceTypes = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imageSourceTypes = @[@(UIImagePickerControllerSourceTypeCamera), @(UIImagePickerControllerSourceTypePhotoLibrary)];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册上传", nil), nil];
    } else {
        imageSourceTypes = @[@(UIImagePickerControllerSourceTypePhotoLibrary)];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"从相册上传", nil), nil];
    }
    [actionSheet showInView:self.tableView];
    [actionSheet setDidDismissBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (buttonIndex < [imageSourceTypes count])
                sourceType = [imageSourceTypes[buttonIndex] unsignedIntegerValue];
            [self imagePickerWithSource:sourceType forAvatar:YES];
        }
        
        // log
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            wrapperTrackEvent(@"account_setting_avatar", @"cancel");
        } else {
            if (buttonIndex < [imageSourceTypes count]) {
                NSString *logString = [imageSourceTypes[buttonIndex] unsignedIntegerValue] == UIImagePickerControllerSourceTypePhotoLibrary ? @"upload_avatar" : @"take_avatar";
                wrapperTrackEvent(@"account_setting_avatar", logString);
            }
        }
    }];
    
    wrapperTrackEvent(@"edit_profile", @"account_setting_avatar");
}

#pragma mark - pick image and upload image

- (void)imagePickerWithSource:(UIImagePickerControllerSourceType)sourceType forAvatar:(BOOL)bAvatar {
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
            [sself uploadImage:image];
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
    
    [self.viewController.navigationController presentViewController:imageController animated:YES completion:NULL];
}

- (void)uploadImage:(UIImage *)image {
    if (!image) return;
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络不给力，请稍后重试"];
        return;
    }
    
    __weak typeof(self) wself = self;
    
    void (^didCompletedBlock)(NSString *, NSError *) = ^(NSString *imageURIString, NSError *error) {
        __strong typeof(wself) sself = wself;
        if (error || isEmptyString(imageURIString)) {
            NSString *hint = [error.userInfo objectForKey:@"description"];
            if (isEmptyString(hint)) hint = NSLocalizedString(@"头像修改失败，请稍后重试", nil);
            [[ToastManager manager] showToast:hint];
        } else {
            // 防止crash
            imageURIString = imageURIString ? : @"";
            [FHMineAPI uploadUserProfileInfo:@{TTAccountUserAvatarKey : imageURIString} completion:^(TTAccountUserEntity *userEntity, NSError *error) {
                __strong typeof(wself) sself2 = wself;
                
                if (error) {
                    NSString *hint = [error.userInfo objectForKey:@"description"];
                    if (isEmptyString(hint)) hint = [error.userInfo objectForKey:TTAccountErrMsgKey];
                    if (isEmptyString(hint)) hint = NSLocalizedString(@"头像修改失败，请稍后重试", nil);
                    [[ToastManager manager] showToast:hint];
                } else {
                    [[ToastManager manager] showToast:@"头像修改成功"];
                    NSString *imageURL = [userEntity.auditInfoSet userAvatarURLString];
                    if (!isEmptyString(imageURL)) {
                        TTAccountUserEntity* user = [[TTAccount sharedAccount] user];
                        if (user != nil) {
                            user.avatarURL = imageURL;
                            [[TTAccount sharedAccount] setUser:user];
                        }
                        sself2.userInfo.avatarURL = imageURL;
                        // 使用更新的数据刷新
                        [sself2 reloadViewModel];
                    }
                }
            }];
        }
    };
    
    [FHMineAPI uploadUserPhoto:image completion:didCompletedBlock];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.dataList[section];
    return [items count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = self.dataList[indexPath.section];
    NSString *cellId = items[indexPath.row][@"cellId"];
    FHEditUserBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    [cell updateCell:items[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section != 0){
        return 10.0f;
    }
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if(section != 0){
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10.0f)];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *items = self.dataList[indexPath.section];
    NSDictionary *dic = items[indexPath.row];
    [self doOtherAction:dic[@"key"]];
}

- (void)doOtherAction:(NSString *)key {
    if([key isEqualToString:@"unRegister"]){
        [self triggerLogoutUnRegister];
    }else if([key isEqualToString:@"avatar"]){
        [self changeAvatar];
    }else if([key isEqualToString:@"userName"]){
        [self goToEditingInfo:key];
    }else if([key isEqualToString:@"userDesc"]){
        [self goToEditingInfo:key];
    }
}

#pragma mark - FHEditingInfoControllerDelegate

- (void)reloadData {
    [self reloadViewModel];
}

@end
