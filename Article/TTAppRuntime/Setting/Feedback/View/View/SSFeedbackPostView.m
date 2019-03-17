//
//  SSFeedbackPostView.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSFeedbackPostView.h"
#import "TTFeedbackUploadImageManager.h"
#import "SSFeedbackManager.h"
#import "NetworkUtilities.h"
#import "TTThemedAlertController.h"
#import "UIColor+TTThemeExtension.h"
#import "TTNetworkManager.h"

#import "UITextView+TTAdditions.h"
#import "TTDebugRealMonitorManager.h"

#import "TTArticleTabBarController.h"
#import "ArticleTabbarStyleNewsListViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#define kExistSaveAlertTag 1
#define kRepostAlertTag 2

@interface SSFeedbackPostView()<TTFeedbackUploadImageManagerDelegate, UIAlertViewDelegate, SSFeedbackManagerDelegate>

@property(nonatomic, strong)UIImage * editedImg;
@property(nonatomic, strong)TTFeedbackUploadImageManager *uploadImageManager;
@property(nonatomic, strong)SSFeedbackManager * feedbackManager;
@property(nonatomic, strong)NSString *editedImgWebURI;      //editedImg 上传后的URI
@property(nonatomic, strong)NSString *editedImgUniqueKey;   //editedImg 的唯一key
@property(nonatomic, strong)NSURL *editedImgReferenceURL;
@property(nonatomic, strong)NSDate *editedImgCreateDate;
@property(nonatomic, assign)BOOL sending;    //发送中
@property(nonatomic, strong)UIImage *screenImg;
@property(nonatomic, strong)NSString *screenImgWebURI;
@end

@implementation SSFeedbackPostView

- (void)dealloc
{
    [_uploadImageManager cancelAllOperation];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sending = NO;
        self.editedImg = [SSFeedbackManager needPostImg];
        [self pickedImage:_editedImg withReferenceURL:_editedImgReferenceURL];
        self.editedImgWebURI = [SSFeedbackManager needPostImgURI];
        self.inputTextView.placeHolder = @"如需传图，请点右边--->";
        self.inputTextView.placeHolderColor = [UIColor tt_themedColorForKey:kFHColorCoolGrey3];
        self.inputTextView.text = [SSFeedbackManager needPostMsg];
        [self.inputTextView showOrHidePlaceHolderTextView];
        self.inputTextView.delegate = self;
        
        // add by zjing 去掉初始化截屏
        //当画面初始化时，初始化截屏图片
//         _screenImg = [self getCurrentFeedImage];
        
    }
    return self;
}

/*
 *  如果需要，发送截屏图片
 */
- (void)postScreenImgIfNeeded
{
    if (![self needPostScreenImg] || _sending) {
        return;
    }
    if (_screenImg) {
        _sending = YES;
        [self postImg:_screenImg];
    }
}

/*
 *  如果需要，发送图片
 */
- (void)postEditImgIfNeeded
{
    if (![self needPostEditImg] || _sending) {
        return;
    }
    if (_editedImg) {
        _sending = YES;
        [self postImg:_editedImg];
        
    }
}

- (void)postImg:(UIImage *)img
{
    NSData * imgData = [TTFeedbackUploadImageManager imageDataForImage:img withMaxAspectSize:CGSizeMake(800, 2000) withMaxDataSize:100];
    
    
    NSMutableDictionary * postParameter = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParameter setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParameter setValue:[NSNumber numberWithInteger:0] forKey:@"watermark"];
    [postParameter setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    
    __weak typeof(self) wself = self;
    __autoreleasing NSProgress * progress = nil;
    [[TTNetworkManager shareInstance] uploadWithURL:[CommonURLSetting uploadImageString] parameters:postParameter constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imgData name:@"image" fileName:@"image.jpeg" mimeType:@"image.jpg"];
        
    } progress:&progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error) {
            wself.sending = NO;
            [wself removeProgressView];
            [wself showRepostAlert:error];
        } else {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:wself.editedImgReferenceURL resultBlock:^(ALAsset *asset) {
                wself.editedImgCreateDate = [asset valueForProperty:ALAssetPropertyDate];
                wself.sending = NO;
                [wself send];
            } failureBlock:^(NSError *error) {
                wself.sending = NO;
                [wself send];
            }];
            [wself removeProgressView];
            
            NSError *error = nil;
            NSString *expInfo = nil;
            NSError *resultError = [SSCommonLogic handleError:error responseResult:jsonObj exceptionInfo:&expInfo];
            if(resultError && resultError.code == kSessionExpiredErrorCode) {
                [SSCommonLogic monitorLoginoutWithUrl:@"2-data-upload_image" status:2 error:resultError];
            }
            if (!resultError){
                NSString * webURI = [[jsonObj objectForKey:@"data"] objectForKey:@"web_uri"];
                if (!isEmptyString(webURI)) {
                    if(self.editedImg == img)
                    {
                         wself.editedImgWebURI = webURI;
                    }else
                    {
                        wself.screenImgWebURI = webURI;
                    }
                   
                }
            }
        }
    }];
    
    if (progress && (self.editedImg == img)) {
        [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)postMsg
{
    if (_sending) {
        return;
    }
    //此处不做有效检查， 在send方法中做
    if (!_feedbackManager) {
        self.feedbackManager = [[SSFeedbackManager alloc] init];
        _feedbackManager.delegate = self;
    }
    _sending = YES;
    [_feedbackManager startPostFeedbackContent:self.inputTextView.text userContact:[self availableContact] imgURI:_editedImgWebURI backgorundImgURI:_screenImgWebURI imageCreateDate:_editedImgCreateDate];
    
    //统计
    [TTTracker eventV3:@"feedback_confirm" params:[SSFeedbackManager shareInstance].trackerInfo];
}

/*
 *  是否需要上传图片
 */
- (BOOL)needPostEditImg
{
    if (_editedImg && isEmptyString(_editedImgWebURI)) {
        return YES;
    }
    return NO;
}

/*
 *  是否需要上传截屏图片
 */
- (BOOL)needPostScreenImg
{
    if (isEmptyString(_screenImgWebURI) && _screenImg) {
        return YES;
    }
    return NO;
}

- (void)clearNeedPostData
{
    self.editedImgUniqueKey = nil;
    self.editedImgWebURI = nil;
    self.editedImg = nil;
    self.editedImgCreateDate = nil;
    self.editedImgReferenceURL = nil;
    self.screenImgWebURI = nil;
    self.screenImg = nil;
    [self setInputTextViewText:nil];
    
    [SSFeedbackManager saveNeedPostImg:nil];
    [SSFeedbackManager saveNeedPostImgURI:nil];
    [SSFeedbackManager saveNeedPostMsg:nil];
    
}

- (void)saveNeedPostData
{
    [SSFeedbackManager saveNeedPostImg:_editedImg];
    [SSFeedbackManager saveNeedPostImgURI:_editedImgWebURI];
    [SSFeedbackManager saveNeedPostMsg:self.inputTextView.text];
}

- (BOOL)needSave
{
    if (!isEmptyString(_editedImgWebURI) || !isEmptyString(self.inputTextView.text) || _editedImg != nil) {
        return YES;
    }
    return NO;
}

- (void)quiteFeedbackPostView
{
    [self.inputTextView resignFirstResponder];
    if ([self needSave]) {
        
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"是否保存", nil) message:NSLocalizedString(@"反馈尚未保存, 是否保存?", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"丢弃", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self clearNeedPostData];
            [self existView];
        }];
        [alert addActionWithTitle:NSLocalizedString(@"保存", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [self saveNeedPostData];
            [self existView];
        }];
        [alert showFrom:self.viewController animated:YES];

    }
    else {
        [self existView];
    }
}

- (void)existView
{
    UIViewController * controller = [TTUIResponderHelper topViewControllerFor: self];
    if([controller isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)controller popViewControllerAnimated:YES];
    }
    else
    {
        [controller.navigationController popViewControllerAnimated:YES];
    }
}

- (void)send
{
    if (!TTNetworkConnected()) {
        [self showIndicatorMsg:NSLocalizedString(@"没有网络连接,请稍后重试", nil) autoHidden:YES];
    }
    else if (_sending) {
        [self showIndicatorMsg:NSLocalizedString(@"发送中...", nil) autoHidden:YES];
    }
    else if (![self inputContentLegal]) {
        [self showIndicatorMsg:NSLocalizedString(@"说点什么吧", nil) autoHidden:YES];
    }
    else if ([self needPostEditImg]){
        [self postEditImgIfNeeded];
    }
    else if ([self needPostScreenImg])
    {
        [self postScreenImgIfNeeded];
    }
    else {
        [self postMsg];
    }
}

- (void)willDisappear
{
    [super willDisappear];
    [self saveNeedPostData];
}



#pragma mark -- setter

- (void)setEditedImg:(UIImage *)editedImg
{
    if (_editedImg != editedImg) {
        _editedImg = editedImg;
    }
    self.editedImgUniqueKey = [TTFeedbackUploadImageManager imageUniqueKey:_editedImg];
}

- (void) deletePickedImg {
    [super deletePickedImg];
    [self pickedImage:nil withReferenceURL:nil];
}

- (void)showRepostAlert:(NSError *)error
{
    NSString * tipMsg = NSLocalizedString(@"后台服务繁忙，需要重试吗?", nil);
    if (error.code == kNoNetworkErrorCode) {
        tipMsg = NSLocalizedString(@"网络不给力，需要重试吗", nil);
    }
    
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:tipMsg message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alert addActionWithTitle:NSLocalizedString(@"重试", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        [self send];
    }];
    [alert showFrom:self.viewController animated:YES];
}

#pragma mark -- protected

- (void)pickedImage:(UIImage *)image withReferenceURL:(NSURL *)url
{
    [super pickedImage:image withReferenceURL:url];
    self.editedImg = image;
    self.editedImgReferenceURL = url;
    self.editedImgWebURI = nil;
    self.editedImgCreateDate = nil;
    [self setImageButtonImg:_editedImg];
}

- (BOOL) hasPickedImg {
    return !!self.editedImg;
}


#pragma mark -- SSFeedbackManagerDelegate

- (void)feedbackManager:(SSFeedbackManager *)manager postMsgUserInfo:(NSDictionary *)dict error:(NSError *)error
{
    if (manager == _feedbackManager) {
        _sending = NO;
        
        if (error) {
            [self showRepostAlert:error];
        }
        else {
            [self clearNeedPostData];
            [self quiteFeedbackPostView];
        }
    }
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kExistSaveAlertTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self clearNeedPostData];
        }
        else {
            [self saveNeedPostData];
        }
        [self existView];
    }
    else if(alertView.tag == kRepostAlertTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // do nothing...
        }
        else {
            [self send];
        }
    }
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[NSProgress class]] && [keyPath isEqualToString:@"completedUnitCount"]) {
        NSProgress * progress = object;
        CGFloat pro = 0;
        if (progress.completedUnitCount >= progress.totalUnitCount) {
            pro = 1.f;
            [progress removeObserver:self forKeyPath:@"completedUnitCount"];
        } else {
            pro = progress.fractionCompleted;
        }
        
        [self setSubmitProgress:pro];
    }
}

//获取截屏图片
- (UIImage *)getCurrentFeedImage
{
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    if (![mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        return nil;
    }
    TTArticleTabBarController * rootTabController = (TTArticleTabBarController*)mainWindow.rootViewController;
    UINavigationController * navigationController = (UINavigationController*)(rootTabController.viewControllers.firstObject); //这个其实是TTNavigationController
    
    ArticleTabBarStyleNewsListViewController * tabbarNewsVC = navigationController.viewControllers.firstObject;
    
    UIGraphicsBeginImageContext(mainWindow.frame.size);
    [tabbarNewsVC.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
    
}

@end
