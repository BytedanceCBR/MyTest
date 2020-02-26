//
//  FHEditUserViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import "FHEditUserViewModel.h"
#import "TTHttpTask.h"
#import "TTRoute.h"
#import "FHEditUserBaseCell.h"
#import "TTAccountBusiness.h"
#import "FHEditableUserInfo.h"
#import "TTURLUtils.h"
#import "FHEnvContext.h"
#import "FHEditingInfoController.h"
#import "UIActionSheet+TTBlocks.h"
#import "UIImagePickerController+TTBlocks.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHMineAPI.h"
#import "FHCommonApi.h"
#import "FHUserInfoManager.h"
#import "FHHomePageSettingController.h"
#import <TTImagePicker/TTImagePickerController.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface FHEditUserViewModel()<UITableViewDelegate,UITableViewDataSource,FHEditingInfoControllerDelegate,FHEditUserBaseCellDelegate,FHHomePageSettingControllerDelegate,TTImagePickerControllerDelegate>

@property(nonatomic, strong) NSArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) FHEditableUserInfo *userInfo;
@property(nonatomic, weak) FHEditUserController *viewController;
@property (nonatomic, strong) TTImagePickerController *ttImagePickerController;

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
        [tableView registerClass:NSClassFromString(@"FHEditUserSwitchCell") forCellReuseIdentifier:@"switchCellId"];
        
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
                              @"isAuditing":(self.userInfo.isAuditing ? @"1" : @"0"),
                              },
                          @{
                              @"name":@"昵称",
                              @"key":@"userName",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":(self.userInfo.name ? self.userInfo.name : @""),
                              @"isAuditing":(self.userInfo.isAuditing ? @"1" : @"0"),
                              },
                          @{
                              @"name":@"介绍",
                              @"key":@"userDesc",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":(self.userInfo.userDescription ? self.userInfo.userDescription : @""),
                              @"isAuditing":(self.userInfo.isAuditing ? @"1" : @"0"),
                              },
                          @{
                              @"name":@"个人主页设置",
                              @"key":@"homePageSetting",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":[self getHomeAuthDesc:self.userInfo.homePageAuth],
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
        
        [TTAccount getUserAuditInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            if (!error) {
                TTAccountUserAuditSet *newAuditInfo = [userEntity.auditInfoSet copy];
                wself.userInfo.isAuditing  = [newAuditInfo isAuditing];
                wself.userInfo.editEnabled = [newAuditInfo modifyUserInfoEnabled];
                wself.userInfo.name        = [newAuditInfo username];
                wself.userInfo.avatarURL  = [newAuditInfo userAvatarURLString];
                wself.userInfo.userDescription = [newAuditInfo userDescription];
                
                [wself reloadViewModel];
            }
        }];
        
        [TTAccount getUserInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            if(!error){
                wself.userInfo.homePageAuth = [[FHUserInfoManager sharedInstance].userInfo.data.fHomepageAuth integerValue];

                [wself reloadViewModel];
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
    
    //F自己的字段
    _userInfo.homePageAuth = [[FHUserInfoManager sharedInstance].userInfo.data.fHomepageAuth integerValue];
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

- (void)goToHomePageSetting {
    NSMutableDictionary *dict = @{}.mutableCopy;

    NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegateTable addObject:self];
    
    dict[@"delegate"] = delegateTable;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://homePageSetting?auth=%i", self.userInfo.homePageAuth];

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
            if (buttonIndex == 1) {
                [self imagePickerResponser];
            }else {
                [self imagePickerWithSource:sourceType forAvatar:YES];
            }
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

- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg callback:(void(^)(void))callback
{
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:msg preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:callback];
    [alert showFrom:self.viewController animated:YES];
}

-(BOOL)showAuthAlert:(UIImagePickerControllerSourceType)sourceType
{
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
            // 无权限
            UIAlertView * authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无访问权限", nil)
                                                                 message:NSLocalizedString(@"请在手机的[设置-隐私-照片]选项中，允许幸福里访问你的相机", nil)
                                                                delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil];
            
            [authAlert addButtonWithTitle:NSLocalizedString(@"去设置", nil)];
            [authAlert show];
            return YES;
        }
    }else{
        ALAuthorizationStatus photoAuthStatus = [ALAssetsLibrary authorizationStatus];
        if (photoAuthStatus == ALAuthorizationStatusDenied) {
            UIAlertView * authAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"无访问权限", nil)
                                                                 message:NSLocalizedString(@"请在手机的[设置-隐私-照片]选项中，允许幸福里访问你的相册", nil)
                                                                delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil];
            [authAlert addButtonWithTitle:NSLocalizedString(@"去设置", nil)];
            [authAlert show];
            return YES;
        }
    }
    return NO;
}

#pragma mark - pick image and upload image

- (void)imagePickerWithSource:(UIImagePickerControllerSourceType)sourceType forAvatar:(BOOL)bAvatar {
    
    if ([self showAuthAlert:sourceType]) {
        return;
    }            
    __weak typeof(self) wself = self;
    UIImagePickerControllerDidFinishBlock completionCallback = ^(UIImagePickerController *picker, NSDictionary *info) {
        __strong typeof(wself) sself = wself;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        if ([sself showAuthAlert:sourceType]) {
            return;
        }
        
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
                    if(userEntity.auditInfoSet.pgcUserAuditEntity){
                        self.userInfo.isAuditing = userEntity.auditInfoSet.pgcUserAuditEntity.auditing;
                    }
                    if(!self.userInfo.isAuditing){
                        [[ToastManager manager] showToast:@"头像修改成功"];
                    }
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

//调用图片选择器
- (void) imagePickerResponser
{
    [[self getTTImagePicker] presentOn:self.viewController.navigationController];
}


#pragma mark --- ttimage picker delegate ---

- (TTImagePickerController *)getTTImagePicker {
    [TTImagePickerManager manager].accessIcloud = YES;
    if (!_ttImagePickerController) {
        _ttImagePickerController = [[TTImagePickerController alloc] initWithDelegate:self];
    }
    _ttImagePickerController.maxImagesCount = 1;
    _ttImagePickerController.isRequestPhotosBack = NO;
    //    _ttImagePickerController.isHideGIF = YES;
    return _ttImagePickerController;
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info {
    if (photo != nil) {
        [self uploadImage:photo];
    }
}

- (void)ttimagePickerController:(TTImagePickerController *)picker
         didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                   sourceAssets:(NSArray<TTAssetModel *> *)assets {
    
    if (photos.count > 0) {
        UIImage *image = [photos firstObject];
        UIImage *scaleImage = [[self class]cropSquareImage:image];
        [self uploadImage:scaleImage];
    }else if (assets.count > 0){
        TTAssetModel *model = [assets firstObject];
        WeakSelf;
        [[TTImagePickerManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (photo) {
                [wself uploadImage:photo];
            }
        }];
        
    }
}

// 以图片中心为中心，以最小边为边长，裁剪正方形图片
+ (UIImage *)cropSquareImage:(UIImage *)image
{
    CGImageRef sourceImageRef = [image CGImage];//将UIImage转换成CGImageRef
    
    CGFloat _imageWidth = image.size.width * image.scale;
    CGFloat _imageHeight = image.size.height * image.scale;
    CGFloat _width = _imageWidth > _imageHeight ? _imageHeight : _imageWidth;
    CGFloat _offsetX = (_imageWidth - _width) / 2;
    CGFloat _offsetY = (_imageHeight - _width) / 2;
    
    CGRect rect = CGRectMake(_offsetX, _offsetY, _width, _width);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    return newImage;
}

- (NSString *)getHomeAuthDesc:(NSInteger)auth {
    //默认是公开
    NSString *desc = @"公开";
    switch (auth) {
        case 0:
            desc = @"公开";
            break;
        case 1:
            desc = @"仅个人可见";
            break;
        default:
            break;
    }
    return desc;
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
    cell.delegate = self;
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
    if(dic[@"isAuditing"] && [dic[@"isAuditing"] boolValue]){
        //审核中不可编辑
        return;
    }
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
    }else if([key isEqualToString:@"homePageSetting"]){
        [self goToHomePageSetting];
    }
}

#pragma mark - FHEditingInfoControllerDelegate

- (void)reloadData {
    [self reloadViewModel];
}

#pragma mark - FHHomePageSettingControllerDelegate

- (void)reloadAuthDesc:(NSInteger)auth {
    self.userInfo.homePageAuth = auth;
    [self reloadViewModel];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
