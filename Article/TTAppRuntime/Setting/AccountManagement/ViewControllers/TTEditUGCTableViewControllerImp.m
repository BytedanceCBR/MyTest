//
//  TTEditUGCTableViewControllerImp.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUGCTableViewControllerImp.h"
#import "TTEditUGCProfileViewModel.h"

#import "NSStringAdditions.h"
#import "TTThirdPartyAccountsHeader.h"

#import "TTUserProfileInputView.h"
#import "TTIndicatorView.h"

#import "SSAvatarView.h"
#import <TTWeChatShare.h>

#import "TTEditUserProfileCell.h"
#import "TTEditUserProfileSectionView.h"
#import "TTEditUserProfileItemCell.h"
#import "TTUserBindAccountCell.h"
#import "TTEditUserLogoutCell.h"
#import "TTEditUserProfileView.h"

#import "UIImagePickerController+TTBlocks.h"
#import "UIActionSheet+TTBlocks.h"
#import "TTSettingConstants.h"
#import "TTEditUserPickView.h"
#import "TTIndicatorView.h"

typedef NS_ENUM(NSUInteger, TTSectionType) {
    kTTSectionTypeNone = 0,
    kTTSectionTypeUserInfo,
    kTTSectionTypeSelfIntroduction,
    kTTSectionTypeAttachUserInfo,//个人主页native化新增
    kTTSectionTypeAccounts,
    kTTSectionTypeLogout,
};

typedef NS_ENUM(NSUInteger, TTCellType) {
    kTTCellTypeNone = 0,
    kTTCellTypeUserAvatar,
    kTTCellTypeUserBackgroundImage,
    kTTCellTypeUserUsername,
    kTTCellTypeUserSelfIntroduction,
    kTTCellTypeUserGender,
    kTTCellTypeUserArea,
    kTTCellTypeUserBirthday,
    kTTCellTypeUserIndustry,
};


@interface TTEditUGCTableViewControllerImp ()
<
UITableViewDelegate,
UITableViewDataSource,
UIActionSheetDelegate
>
@property (nonatomic, strong) SSAvatarView *avatarView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TTEditUGCTableViewControllerImp
- (instancetype)init {
    if ((self = [super init])) {
        _viewModel = nil;
    }
    return self;
}

- (instancetype)initWithViewModel:(TTEditUGCProfileViewModel *)viewModel {
    if ((self = [self init])) {
        _viewModel = viewModel;
    }
    return self;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if(!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.viewModel.profileView addSubview:_activityIndicatorView];
        _activityIndicatorView.center = CGPointMake(self.viewModel.profileView.width * 0.5, self.viewModel.profileView.height * 0.5);
    }
    return _activityIndicatorView;
}

#pragma mark - delegate for UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    if ([self showTableviewSectionOfThirdAccounts])
        numberOfSections++;
    if ([self showTableviewSectionOfLogout])
        numberOfSections++;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightOfRow = 0;
    NSInteger sectionType = [self sectionTypeOfIndex:indexPath.section];
    
    if (sectionType != kTTSectionTypeNone) {
        heightOfRow = [TTBaseUserProfileCell cellHeight];
    }
    return heightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self heightOfSectionHeaderView:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [self heightOfSectionHeaderView:section];
    TTThemedSplitView *sectionHeaderView = nil;
    
    switch ([self sectionTypeOfIndex:section]) {
        case kTTSectionTypeAttachUserInfo: {
            sectionHeaderView = [[TTThemedSplitView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), height)];
            sectionHeaderView.backgroundColor = [UIColor clearColor];
        }
            break;
        default:
            break;
    }
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTBaseUserProfileCell *cell = [self reuseCellInTableView:tableView forIndexPath:indexPath];
    cell.cellSpearatorStyle = [TTBaseUserProfileCell separatorStyleForPosition:[self cellPositionInIndexPath:indexPath]];
    
    // refresh content of cell
    TTEditUserProfileItemCell *userItemCell = (TTEditUserProfileItemCell *)cell;
    TTUserProfileItem *userItem = [self userProfileItemOfIndexPath:indexPath];
    [userItemCell reloadWithProfileItem:userItem];
    
    return cell ? : [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeUserAvatar: {
            [self changeAvatarDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
            
        case kTTCellTypeUserBackgroundImage: {
            [self changeBackgroundImageDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
            
        case kTTCellTypeUserUsername: {
            [self changeUsernameDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
            
        case kTTCellTypeUserSelfIntroduction: {
            [self changeDescriptionDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case kTTCellTypeUserGender: {
            [self changeGenderDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case kTTCellTypeUserBirthday: {
            [self changeBirthdayDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case kTTCellTypeUserArea: {
            [self changeAreaDidClickCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
            //        case kTTCellTypeUserIndustry: {
            //            break;
            //        }
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cellTypeOfIndexPath:indexPath] == kTTCellTypeUserUsername) {
        return self.viewModel.editableAuditInfo.editEnabled;
    } else {
        return YES;
    }
}

#pragma mark - helper for UITableView

- (void)reloadTableView {
    [self.viewModel reloadViewModel];
}

- (BOOL)showTableviewSectionOfThirdAccounts {
    return NO;
}

- (BOOL)showTableviewSectionOfLogout {
    return NO;
}

- (CGFloat)heightOfSectionHeaderView:(NSUInteger)section {
    CGFloat heightOfHeader = 0.f;
    NSInteger sectionType = [self sectionTypeOfIndex:section];
    switch (sectionType) {
        case kTTSectionTypeAccounts:
            heightOfHeader = 40.f;
            break;
        case kTTSectionTypeAttachUserInfo:
            heightOfHeader = [TTDeviceUIUtils tt_padding:kTTSettingInsetTop];
            break;
        case kTTSectionTypeLogout:
            heightOfHeader = 35.f;
            break;
        default:
            break;
    }
    return heightOfHeader;
}

- (TTCellPositionType)cellPositionInIndexPath:(NSIndexPath *)indexPath {
    TTCellPositionType type = kTTCellPositionTypeMiddle;
    NSUInteger numberOfRows = [self numberOfRowsInSection:indexPath.section];
    
    if (indexPath.row == 0 && indexPath.row == numberOfRows - 1) {
        type = kTTCellPositionTypeFirstAndLast;
    } else if (indexPath.row == 0) {
        type = kTTCellPositionTypeFirst;
    } else if (indexPath.row == numberOfRows - 1) {
        type = kTTCellPositionTypeLast;
    } else {
        type = kTTCellPositionTypeMiddle;
    }
    return type;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section {
    NSInteger numberOfRows = 0;
    TTSectionType sectionType = [self sectionTypeOfIndex:section];
    switch (sectionType) {
        case kTTSectionTypeUserInfo:
            numberOfRows = 3; // remove backgroundImage
            break;
        case kTTSectionTypeAttachUserInfo:
            numberOfRows = 3;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (TTSectionType)sectionTypeOfIndex:(NSInteger)section {
    NSMutableArray<NSNumber *> *sectionArray = [@[@(kTTSectionTypeUserInfo), @(kTTSectionTypeAttachUserInfo)] mutableCopy];
    if ([self showTableviewSectionOfThirdAccounts]) {
        [sectionArray addObject:@(kTTSectionTypeAccounts)];
    }
    if ([self showTableviewSectionOfLogout]) {
        [sectionArray addObject:@(kTTSectionTypeLogout)];
    }
    return [[sectionArray objectAtIndex:section] unsignedIntegerValue];
}

- (TTCellType)cellTypeOfIndexPath:(NSIndexPath *)indexPath {
    TTCellType cellType = kTTCellTypeNone;
    switch ([self sectionTypeOfIndex:indexPath.section]) {
        case kTTSectionTypeUserInfo: {
            if (indexPath.row == 0) {
                cellType = kTTCellTypeUserAvatar;
            } else if (indexPath.row == 1) {
                cellType = kTTCellTypeUserUsername;
            } else if(indexPath.row == 2) {
                cellType = kTTCellTypeUserSelfIntroduction;
            }
            break;
        }
        case kTTSectionTypeAttachUserInfo: {
            if(indexPath.row == 0) {
                cellType = kTTCellTypeUserGender;
            } else if(indexPath.row == 1) {
                cellType = kTTCellTypeUserBirthday;
            } else if(indexPath.row == 2){
                cellType = kTTCellTypeUserArea;
            }
            break;
        }
        default:
            break;
    }
    return cellType;
}

- (TTUserProfileItem *)userProfileItemOfIndexPath:(NSIndexPath *)indexPath {
    return [self userProfileItemOfIndexPath:indexPath animation:NO];
}

/**
 *  UGC用户仅仅用户名显示在审核中
 */
- (TTUserProfileItem *)userProfileItemOfIndexPath:(NSIndexPath *)indexPath animation:(BOOL)animation {
    TTEditableUserAuditInfo *userAuditInfo = self.viewModel.editableAuditInfo;
    
    TTUserProfileItem *userItem = [TTUserProfileItem new];
    userItem.animating   = animation;
    userItem.isAuditing  = NO;
    userItem.editEnabled = YES;
    
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeUserAvatar: { // Avatar
            userItem.title = @"头像";
            userItem.image = userAuditInfo.avatarImage;
            userItem.imageURLName = userAuditInfo.avatarURL;
            if (userAuditInfo.editingItem == kTTEditingUserItemTypeAvatar) {
                userItem.animating = YES;
            }
            break;
        }
        case kTTCellTypeUserBackgroundImage: { // 个人背景
            userItem.title = @"更换个人主页背景";
            userItem.image = userAuditInfo.bgImage;
            userItem.imageURLName = nil;
            userItem.avatarStyle = SSAvatarViewStyleRectangle;
            if (userAuditInfo.editingItem == kTTEditingUserItemTypeBgImage) {
                userItem.animating = YES;
            }
            break;
        }
            
        case kTTCellTypeUserUsername: { // 用户名
            userItem.title = @"用户名";
            userItem.content = userAuditInfo.name;
            userItem.isAuditing  = userAuditInfo.isAuditing;
            userItem.editEnabled = userAuditInfo.editEnabled;
            if (userAuditInfo.editingItem == kTTEditingUserItemTypeUsername) {
                userItem.animating = YES;
            }
            break;
        }
            
        case kTTCellTypeUserSelfIntroduction: { // 介绍
            userItem.title = @"介绍";
            userItem.content = userAuditInfo.userDescription;
            if (userAuditInfo.editingItem == kTTEditingUserItemTypeDescription) {
                userItem.animating = YES;
            }
            break;
        }
        case kTTCellTypeUserGender: {
            userItem.title = @"性别";
            NSString *content = nil;
            if(userAuditInfo.gender.integerValue == 1) {
                content = @"男";
                userItem.contentThemeKey = kColorText3;
            } else if(userAuditInfo.gender.integerValue == 2) {
                content = @"女";
                userItem.contentThemeKey = kColorText3;
            } else {
                content = @"待完善";
                userItem.contentThemeKey = kColorText6;
            }
            userItem.content = content;
            break;
        }
        case kTTCellTypeUserBirthday: {
            userItem.title = @"生日";
            if(!isEmptyString(userAuditInfo.birthday)) {
                userItem.content = [self formatterBirthdayWithBirthdayString:userAuditInfo.birthday];
                userItem.contentThemeKey = kColorText3;
            } else {
                userItem.content = @"待完善";
                userItem.contentThemeKey = kColorText6;
                
            }
            break;
        }
        case kTTCellTypeUserArea: {
            userItem.title = @"地区";
            if(!isEmptyString(userAuditInfo.area)) {
                userItem.content = userAuditInfo.area;
                userItem.contentThemeKey = kColorText3;
            } else {
                userItem.content = @"待完善";
                userItem.contentThemeKey = kColorText6;
            }
            break;
        }
            //        case kTTCellTypeUserIndustry: {
            //            userItem.title = @"所在行业";
            //            if(!isEmptyString(userAuditInfo.industry)) {
            //                userItem.content = userAuditInfo.industry;
            //                userItem.contentThemeKey = kColorText3;
            //            } else {
            //                userItem.content = @"待完善";
            //                userItem.contentThemeKey = kColorText6;
            //            }
            //            break;
            //        }
        default:
            break;
    }
    
    if([self sectionTypeOfIndex:indexPath.section] != kTTSectionTypeAttachUserInfo) {
        if (userItem.editEnabled) {
            userItem.contentThemeKey = kColorText3;
        } else {
            userItem.contentThemeKey = kColorText9;
        }
    }
    return userItem;
}

- (TTBaseUserProfileCell *)reuseCellInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"kTTUGCProfileDefaultCellIdentifier";
    NSInteger sectionType = [self sectionTypeOfIndex:indexPath.section];
    if (sectionType == kTTSectionTypeUserInfo) {
        cellIdentifier = @"kTTUGCProfileItemCellIdentifier";
    }else if (sectionType == kTTSectionTypeAccounts) {
        cellIdentifier = @"kTTUGCAccountItemCellIdentifier";
    } else if (sectionType == kTTSectionTypeLogout) {
        cellIdentifier = @"kTTUGCLogoutCellIdentifier";
    } else if(sectionType == kTTSectionTypeAttachUserInfo) {
        cellIdentifier = @"kTTUGCAttachProfileItemCellIdentifier";
    }
    
    TTBaseUserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        if (sectionType == kTTSectionTypeUserInfo) {
            cell = [[TTEditUserProfileItemCell alloc] initWithReuseIdentifier:cellIdentifier];
        } else if (sectionType == kTTSectionTypeAttachUserInfo) {
            cell = [[TTEditUserProfileItemCell alloc] initWithReuseIdentifier:cellIdentifier];
        } else if (sectionType == kTTSectionTypeAccounts) {
            cell = [[TTUserBindAccountCell alloc] initWithReuseIdentifier:cellIdentifier];
        } else if (sectionType == kTTSectionTypeLogout) {
            cell = [[TTEditUserLogoutCell alloc] initWithReuseIdentifier:cellIdentifier];
        } else {
            cell = [[TTBaseUserProfileCell alloc] initWithReuseIdentifier:cellIdentifier];
        }
    }
    
    return cell;
}


#pragma mark - events for tapping cell

- (void)logoutDidClickCell:(TTEditUserLogoutCell *)cell {
    if (![cell isKindOfClass:[TTEditUserLogoutCell class]]) return;
}

- (void)changeBackgroundImageDidClickCell:(TTEditUserProfileItemCell *)cell {
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    
    UIActionSheet       *actionSheet = nil;
    NSArray<NSNumber *> *imageSourceTypes = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imageSourceTypes = @[@(UIImagePickerControllerSourceTypeCamera), @(UIImagePickerControllerSourceTypePhotoLibrary)];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册上传", nil), nil];
    } else {
        imageSourceTypes = @[@(UIImagePickerControllerSourceTypePhotoLibrary)];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"从相册上传", nil), nil];
    }
    [actionSheet showInView:self.viewModel.profileView];
    [actionSheet setDidDismissBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (buttonIndex < [imageSourceTypes count])
                sourceType = [imageSourceTypes[buttonIndex] unsignedIntegerValue];
            [self.viewModel imagePickerWithSource:sourceType forAvatar:NO ofCell:cell];
        }
    }];
}

- (void)changeAvatarDidClickCell:(TTEditUserProfileItemCell *)cell {
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    
    UIActionSheet      *actionSheet = nil;
    NSArray<NSNumber*> *imageSourceTypes = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imageSourceTypes = @[@(UIImagePickerControllerSourceTypeCamera), @(UIImagePickerControllerSourceTypePhotoLibrary)];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册上传", nil), nil];
    } else {
        imageSourceTypes = @[@(UIImagePickerControllerSourceTypePhotoLibrary)];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"从相册上传", nil), nil];
    }
    [actionSheet showInView:self.viewModel.profileView];
    [actionSheet setDidDismissBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (buttonIndex < [imageSourceTypes count])
                sourceType = [imageSourceTypes[buttonIndex] unsignedIntegerValue];
            [self.viewModel imagePickerWithSource:sourceType forAvatar:YES ofCell:cell];
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

- (void)changeUsernameDidClickCell:(TTEditUserProfileItemCell *)cell {
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    
    TTUserProfileInputView *inputView = [[TTUserProfileInputView alloc] initWithFrame:CGRectZero];
    inputView.type = TTUserProfileInputViewTypeName;
    inputView.textView.text = self.viewModel.editableAuditInfo.name;
    inputView.delegate = self.viewModel;
    [inputView showInView:self.viewModel.profileView animated:YES];
    
    wrapperTrackEvent(@"edit_profile", @"account_setting_username");
}

- (void)changeDescriptionDidClickCell:(TTEditUserProfileItemCell *)cell {
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    
    TTUserProfileInputView *inputView = [[TTUserProfileInputView alloc] initWithFrame:CGRectZero];
    inputView.type = TTUserProfileInputViewTypeSign;
    inputView.textView.text = self.viewModel.editableAuditInfo.userDescription;
    inputView.delegate = self.viewModel;
    [inputView showInView:self.viewModel.profileView animated:YES];
    
    wrapperTrackEvent(@"edit_profile", @"account_setting_signature");
}

- (void)changeGenderDidClickCell:(TTEditUserProfileCell *)cell
{
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    actionSheet.tag = 1001;
    [actionSheet showInView:self.viewModel.profileView];
}

- (void)changeBirthdayDidClickCell:(TTEditUserProfileCell *)cell
{
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    TTEditUserPickView *pickerView = [[TTEditUserPickView alloc] init];
    __weak typeof(self) weakSelf = self;
    [pickerView showWithType:TTEditUserPickViewTypeBirthday pickerViewHeight:[TTDeviceUIUtils tt_newPadding:245] completion:^(NSArray<NSString *> *textArray,TTEditUserPickViewType type) {
        if(!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力,请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        NSString *text = textArray.firstObject;
        if(isEmptyString(text)) return ;
        [weakSelf.activityIndicatorView startAnimating];
        
        NSMutableDictionary *profileExtraDict = [NSMutableDictionary dictionary];
        [profileExtraDict setValue:text
                            forKey:TTAccountUserBirthdayKey];
        
        [TTAccount updateUserExtraProfileWithDict:profileExtraDict completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
            
            [weakSelf.activityIndicatorView stopAnimating];
            
            if(!error) {
                weakSelf.viewModel.editableAuditInfo.birthday = [TTAccountManager currentUser].birthday;
                [TTAccountManager sharedManager].myUser.birthday = [TTAccountManager currentUser].birthday;
                
                [weakSelf.viewModel.profileView reloadData];
            } else {
                NSString *desc = error.userInfo[@"description"];
                if (!desc) desc = [error.userInfo objectForKey:TTAccountErrMsgKey];
                if(!isEmptyString(desc)) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }
            }
        }];
    }];
    
}

- (void)changeAreaDidClickCell:(TTEditUserProfileCell *)cell
{
    if (![cell isKindOfClass:[TTEditUserProfileItemCell class]]) return;
    TTEditUserPickView *pickerView = [[TTEditUserPickView alloc] init];
    __weak typeof(self) weakSelf = self;
    [pickerView showWithType:TTEditUserPickViewTypeArea pickerViewHeight:[TTDeviceUIUtils tt_newPadding:245]completion:^(NSArray<NSString *> *textArray,TTEditUserPickViewType type) {
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力,请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        NSString *province = textArray.firstObject;
        NSString *city = textArray.lastObject;
        if ([province isEqualToString:city]) {
            city = nil;
        }
        if (isEmptyString(province) && isEmptyString(city)) return;
        
        [weakSelf.activityIndicatorView startAnimating];
        
        NSMutableDictionary *profileExtraDict = [NSMutableDictionary dictionary];
        [profileExtraDict setValue:province
                            forKey:TTAccountUserProvinceKey];
        [profileExtraDict setValue:city
                            forKey:TTAccountUserCityKey];
        
        
        [TTAccount updateUserExtraProfileWithDict:profileExtraDict completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
            
            [weakSelf.activityIndicatorView stopAnimating];
            
            if (!error) {
                weakSelf.viewModel.editableAuditInfo.area = [TTAccountManager currentUser].area;
                [TTAccountManager sharedManager].myUser.area = [TTAccountManager currentUser].area;
                
                [weakSelf.viewModel.profileView reloadData];
            } else {
                NSString *desc = error.userInfo[@"description"];
                if (!desc) desc = [error.userInfo objectForKey:TTAccountErrMsgKey];
                if(!isEmptyString(desc)) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }
            }
        }];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2 || actionSheet.tag != 1001) return;
    
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力,请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    NSNumber *gender = buttonIndex == 0 ? @(1) : @(2);
    
    [self.activityIndicatorView startAnimating];
    
    NSMutableDictionary *profileExtraDict = [NSMutableDictionary dictionary];
    [profileExtraDict setValue:gender
                        forKey:TTAccountUserGenderKey];
    
    WeakSelf;
    [TTAccount updateUserExtraProfileWithDict:profileExtraDict completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
        
        [wself.activityIndicatorView stopAnimating];
        
        if(!error) {
            wself.viewModel.editableAuditInfo.gender = [TTAccountManager currentUser].gender;
            [TTAccountManager sharedManager].myUser.gender = [[TTAccountManager currentUser].gender stringValue];
            
            [wself.viewModel.profileView reloadData];
        } else {
            NSString *desc = error.userInfo[@"description"];
            if (!desc) desc = [error.userInfo objectForKey:TTAccountErrMsgKey];
            if(!isEmptyString(desc)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
        }
    }];
}

- (NSString *)formatterBirthdayWithBirthdayString:(NSString *)birthdayString
{
    if(isEmptyString(birthdayString)) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSDate *date = [formatter dateFromString:birthdayString];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *birthday = [formatter stringFromDate:date];
    return birthday;
}

@end
