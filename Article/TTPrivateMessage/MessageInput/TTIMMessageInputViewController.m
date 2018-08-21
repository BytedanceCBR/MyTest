//
//  TTIMMessageInputViewController.m
//  EyeU
//
//  Created by matrixzk on 10/23/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMMessageInputViewController.h"
#import "ChatKeyBoard.h"
#import <KVOController.h>
//#import "TZImagePickerController.h"

@interface TTIMMessageInputViewController () <ChatKeyBoardDelegate, ChatKeyBoardDataSource>

@property (nonatomic, weak) id<TTIMMessageInputViewDelegate> delegate;
@property (nonatomic, strong) ChatKeyBoard *msgInputView;
@property (nonatomic, weak) UIViewController *parentVC;

@end

@implementation TTIMMessageInputViewController

+ (instancetype)setupMessageInputViewWithParentViewController:(UIViewController *)parentVC associateTableView:(UITableView *)tableView delegate:(id<TTIMMessageInputViewDelegate>)delegate {
    TTIMMessageInputViewController *msgInputVC = [[TTIMMessageInputViewController alloc] init];
    msgInputVC.delegate = delegate;
    msgInputVC.msgInputView.associateTableView = tableView;
    msgInputVC.msgInputView.shouldTableViewContentScrollToBottomWhenKeybordUp = YES;
    msgInputVC.parentVC = parentVC;
    [parentVC.view addSubview:msgInputVC.msgInputView];
    return msgInputVC;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _msgInputView = [ChatKeyBoard keyBoard];
        _msgInputView.delegate = self;
        _msgInputView.dataSource = self;
//        _msgInputView.placeHolder = @"输入消息...";
        _msgInputView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        _msgInputView.chatToolBar.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
//        _msgInputView.chatToolBar.topLineColor = [UIColor tt_themedColorForKey:kColorLine7];
        _msgInputView.chatToolBar.alwaysShowSendButton = YES;
        
        _msgInputView.allowImage = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubview {
    CGFloat chatKeyBoardHeight = _msgInputView.chatToolBar.height + _msgInputView.tt_safeAreaInsets.bottom;
    _msgInputView.frame = CGRectMake(0, kScreenHeight - chatKeyBoardHeight, kScreenWidth, chatKeyBoardHeight);
}

- (void)dismissMessageInputView {
    [self.msgInputView keyboardDown];
}

- (void)callOutMsgInputViewWithText:(NSString *)text {
    [self.msgInputView.chatToolBar setTextViewContent:text];
    [self.msgInputView keyboardUp];
}

- (NSString *)currentInputtingText
{
    return self.msgInputView.chatToolBar.textView.text;
}

+ (CGFloat)heightOfMsgInputView
{
    return kChatToolBarHeight;
}

- (void)themeChanged:(NSNotification *)notification {
    _msgInputView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    _msgInputView.chatToolBar.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

#pragma mark - ChatKeyBoard DataSource Methods

- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems
{
    ChatToolBarItem *album = [ChatToolBarItem barItemWithKind:kBarItemImage normal:@"pl_img" high:nil select:nil];
    ChatToolBarItem *send = [ChatToolBarItem barItemWithKind:kBarItemSend normal:nil high:nil select:nil];
    
    return @[album, send];
}

#pragma mark - ChatKeyBoard Delegate Methods

- (void)chatKeyBoardSendText:(NSString *)text
{
    if ([self.delegate respondsToSelector:@selector(ttimMessageInputViewTextDidSend:)]) {
        [self.delegate ttimMessageInputViewTextDidSend:text];
    }
}

- (void)chatKeyBoardImagePickedButtonPressed
{
//    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:30 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
//    imagePickerVc.allowTakePicture = NO;
//    imagePickerVc.navigationBar.barTintColor = [UIColor teu_colorOfBackground1];
//    imagePickerVc.barItemTextColor = [UIColor colorWithHexString:@"#666666"];
//    imagePickerVc.barItemTextFont = [UIFont systemFontOfSize:16];
//    UIColor *color = [UIColor colorWithHexString:@"#FF7350"];
//    imagePickerVc.oKButtonTitleColorDisabled = [color colorWithAlphaComponent:0.5];
//    imagePickerVc.oKButtonTitleColorNormal = color;
//    
//    imagePickerVc.photoDefImageName = @"select";
//    imagePickerVc.photoSelImageName = @"selected";
//    imagePickerVc.photoOriginDefImageName = @"albumoriginal";
//    imagePickerVc.photoOriginSelImageName = @"albumoriginal_selected";
//    
//    imagePickerVc.photoPreviewOriginDefImageName = @"albumoriginal";
//    
//    imagePickerVc.allowPickingVideo = NO;
//    imagePickerVc.allowPickingImage = YES;
//    imagePickerVc.allowPickingOriginalPhoto = YES;
//    
//    // imagePickerVc.sortAscendingByModificationDate = YES;
//    
//    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//        
//    }];
//    
//    [self.parentVC presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate Methods

//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
//{
//    if ([self.delegate respondsToSelector:@selector(ttimMessageInputViewAlbumPhotosDidPicked:sourceAssets:isSelectOriginalPhoto:)]) {
//        [self.delegate ttimMessageInputViewAlbumPhotosDidPicked:photos sourceAssets:assets isSelectOriginalPhoto:isSelectOriginalPhoto];
//    }
//}
//
/*
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker
{
}
 */

@end
