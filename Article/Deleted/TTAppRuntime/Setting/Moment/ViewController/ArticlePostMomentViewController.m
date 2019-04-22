//
//  ArticlePostMomentViewController.m
//  Article
//
//  Created by Huaqing Luo on 13/1/15.
//
//

#import <UIKit/UIImagePickerController.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

#import "ArticlePostMomentViewController.h"
#import "SSNavigationBar.h"
#import "ArticlePostMomentManager.h"
#import "SSThemed.h"
#import "ArticleMobileViewController.h"
#import "SSCheckbox.h"
#import "NetworkUtilities.h"
#import "TTPhotoScrollViewController.h"
#import "MBProgressHUD.h"
#import "TTThemedAlertController.h"
#import "TTNavigationController.h"
#import <TTAccountBusiness.h>
#import "TTAssetViewColumn.h"

#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"
#import "TTImagePicker.h"
#import "UITextView+TTAdditions.h"


#define NumberOfImagesPerRow 4
#define ImagesInterval 10.f

#define PostMomentUmengEventName @"update_post"
#define PostTopicUmengEventName @"topic_post"

@interface AddMultiImagesView() <TTImagePickerControllerDelegate,TTAssetViewColumnDelegate, TTPhotoScrollViewControllerDelegate>
{
    CGFloat _imageSize;
}

@property (nonatomic, strong   ) NSMutableArray  * selectedImageViews;
@property (nonatomic, readwrite) NSMutableArray  * selectedAssetsImages;
@property (nonatomic, strong   ) UIButton        * addImagesButton;

@property(nonatomic, strong) UIView * disableInteractionView;

// Umeng Event Name
@property(nonatomic, copy) NSString * eventName;

- (void)addImagesButtonClicked:(id)sender;

@end

@implementation AddMultiImagesView

- (void)dealloc
{
    [self stopObserving];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageSize = (self.width - (NumberOfImagesPerRow - 1) * ImagesInterval) / NumberOfImagesPerRow;
        self.backgroundColor = [UIColor clearColor];
        self.selectionLimit = DefaultImagesSelectionLimit;
        self.selectedImageViews = [NSMutableArray array];
        self.selectedAssetsImages = [NSMutableArray array];
        
        self.addImagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addImagesButton.frame = CGRectMake(0, 0, _imageSize, _imageSize);
        self.addImagesButton.backgroundColor = [UIColor clearColor];
        self.addImagesButton.layer.borderWidth = [TTDeviceHelper ssOnePixel] * 2;
        [self.addImagesButton addTarget:self action:@selector(addImagesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.addImagesButton];
        
        [self reloadThemeUI];
    }
    return self;
}

#pragma mark - Getters
- (void)stopObserving
{
    for (TTAssetViewColumn * assetViewColumn in self.selectedImageViews)
    {
        [assetViewColumn removeObserver:self forKeyPath:@"selectButton.highlighted"];
        [assetViewColumn removeObserver:self forKeyPath:@"isSelected"];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    [self.addImagesButton setImage:[UIImage themedImageNamed:@"addicon_repost"] forState:UIControlStateNormal];
    [self.addImagesButton setImage:[UIImage themedImageNamed:@"addicon_repost_press"] forState:UIControlStateHighlighted];
    self.addImagesButton.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground1].CGColor;
}

- (void)appendSelectedAsset:(id)assetObj
{
    if ([assetObj isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)assetObj;
        [self.selectedAssetsImages addObject:asset];
        [self appendAssetViewColumnByImage:[UIImage imageWithCGImage:asset.thumbnail]];
    }
    else if([assetObj isKindOfClass:[UIImage class]]) {
        [self appendSelectedImage:assetObj];
    }
}

- (void)appendSelectedImage:(UIImage *)image
{
    UIImage * thumbnail = [image thumbnailImage:_imageSize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
    NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
    UIImage * imageInJPEGFormat = [UIImage imageWithData:imageData];
    [self.selectedAssetsImages addObject:imageInJPEGFormat];
    
    [self appendAssetViewColumnByImage:thumbnail];
}

- (void)appendAssetViewColumnByImage:(UIImage *)image
{
    TTAssetViewColumn * assetViewColumn = [[TTAssetViewColumn alloc] initWithFrame:self.addImagesButton.frame withImage:image];
    assetViewColumn.modeChangeActionType = ModeChangeActionTypeMask;
    UIImageView * deleteImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"closeicon_repost"]];
    [deleteImageView sizeToFit];
    assetViewColumn.selcteButtonImageView = deleteImageView;
    assetViewColumn.delegate = self;
    [assetViewColumn reloadThemeUI];
    
    [assetViewColumn addObserver:self forKeyPath:@"selectButton.highlighted" options:NSKeyValueObservingOptionNew context:nil];
    [assetViewColumn addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew context:nil];
    
    CGFloat x = assetViewColumn.right + ImagesInterval;
    CGFloat y = assetViewColumn.top;
    if (x + _imageSize > self.width)
    {
        x = 0;
        y += _imageSize + ImagesInterval;
    }
    self.addImagesButton.origin = CGPointMake(x, y);
    [self addSubview:assetViewColumn];
    [self.selectedImageViews addObject:assetViewColumn];
}

- (void)removeAssetViewColumn:(TTAssetViewColumn *)assetViewColumn
{
    NSUInteger index = [self.selectedImageViews indexOfObject:assetViewColumn];
    if (index != NSNotFound)
    {
        [self.selectedAssetsImages removeObjectAtIndex:index];
        [assetViewColumn removeObserver:self forKeyPath:@"selectButton.highlighted"];
        [assetViewColumn removeObserver:self forKeyPath:@"isSelected"];
        
        CGRect frame = assetViewColumn.frame;
        [assetViewColumn removeFromSuperview];
        for (NSUInteger i = index + 1 ; i < self.selectedImageViews.count; ++i)
        {
            TTAssetViewColumn * column = [self.selectedImageViews objectAtIndex:i];
            CGRect tempFrame = column.frame;
            column.frame = frame;
            frame = tempFrame;
        }
        self.addImagesButton.frame = frame;
        
        [self.selectedImageViews removeObjectAtIndex:index];
    }
}

- (void)addImagesButtonClicked:(id)sender
{
    if ([self.selectedAssetsImages count] >= self.selectionLimit)
    {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"最多可选%ld张图片", (long)self.selectionLimit] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    wrapperTrackEvent(self.eventName, @"add_pic");
    
    TTImagePickerController *picker = [[TTImagePickerController alloc] initWithDelegate:self];
    picker.maxImagesCount = self.selectionLimit - [self.selectedAssetsImages count];
    //                picker.umengEventName = self.eventName;
    
    UIViewController *topMost = [TTUIResponderHelper topmostViewController];
    if (topMost.presentedViewController) {
        [picker presentOn:topMost.presentedViewController];
    }
    else
    {
        [picker presentOn:topMost];
    }
}


- (UIImage *)getImageFromPHAsset:(PHAsset *)asset
{
    __block UIImage *tImage;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             tImage = [UIImage imageWithData:imageData];
         }];
    }
    
    CGFloat longEdge = [TTUIResponderHelper screenSize].height;
    CGFloat ratio = longEdge / MAX(tImage.size.height, tImage.size.width);
    CGSize newSize = CGSizeMake(tImage.size.width * ratio * [UIScreen mainScreen].scale, tImage.size.height * ratio * [UIScreen mainScreen].scale);
    UIImage *image = [tImage resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    
    return image;
}

#pragma mark - TTImagePickerControllerDelegate
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets
{
    if (photos.count == 0) {
        wrapperTrackEvent(self.eventName, @"finish_none");
        return;
    }
    
    wrapperTrackEvent(self.eventName, @"finish");
    
    for (TTAssetModel * assetModel in assets)
    {
        if ([assetModel.asset isKindOfClass:[ALAsset class]]) {
            [self appendSelectedAsset:assetModel.asset];
        }
        else if ([assetModel.asset isKindOfClass:[PHAsset class]]) {
            [self appendSelectedAsset:[self getImageFromPHAsset:assetModel.asset]];
        }
        
        break;
    }
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info
{
    wrapperTrackEvent(self.eventName, @"confirm_shoot");
    
    NSMutableArray *assetAarray = [[NSMutableArray alloc] initWithArray:assets];
    for (id obj in assetAarray) {
        if ([obj isKindOfClass:[UIImage class]]) {
            [self appendSelectedAsset:obj];
        }
        else if ([obj isKindOfClass:[TTAssetModel class]]) {
            TTAssetModel *assetModel = (TTAssetModel *)obj;
            if ([assetModel.asset isKindOfClass:[ALAsset class]]) {
                [self appendSelectedAsset:assetModel.asset];
            }
            else if ([assetModel.asset isKindOfClass:[PHAsset class]]) {
                [self appendSelectedAsset:[self getImageFromPHAsset:assetModel.asset]];
            }
            
            break;
        }
    }
}

// 选择器取消选择的回调
- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker
{
    wrapperTrackEvent(self.eventName, @"cancel_shoot");
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isMemberOfClass:[TTAssetViewColumn class]])
    {
        TTAssetViewColumn *column = (TTAssetViewColumn *)object;
        
        if ([keyPath isEqualToString:@"selectButton.highlighted"])
        {
            if (column.selectButton.highlighted)
            {
                [column.selcteButtonImageView setImage:[UIImage themedImageNamed:@"closeicon_repost_press"]];
            }
            else
            {
                [column.selcteButtonImageView setImage:[UIImage themedImageNamed:@"closeicon_repost"]];
            }
        }
        
        if ([keyPath isEqualToString:@"isSelected"])
        {
            if (column.isSelected)
            {
                [self removeAssetViewColumn:column];
            }
        }
    }
}

#pragma mark -- TTAssetViewColumnDelegate

- (void)DidTapTTAssetViewColumn:(TTAssetViewColumn *)sender;
{
    NSUInteger index = [self.selectedImageViews indexOfObject:sender];
    if (index != NSNotFound)
    {
        wrapperTrackEvent(self.eventName, @"preview_photo");
        NSMutableArray * isSelecteds = [NSMutableArray arrayWithCapacity:[self.selectedAssetsImages count]];
        for (NSUInteger n = 0; n < [self.selectedAssetsImages count]; ++n)
        {
            [isSelecteds addObject:@(YES)];
        }
        
        TTPhotoScrollViewController * imagesPreviewController = [[TTPhotoScrollViewController alloc] init];
        imagesPreviewController.mode = PhotosScrollViewSupportSelectMode;
        imagesPreviewController.assetsImages = self.selectedAssetsImages;
        imagesPreviewController.isSelecteds = isSelecteds;
        imagesPreviewController.startWithIndex = index;
        imagesPreviewController.selectLimit = self.selectionLimit;
        imagesPreviewController.delegate = self;
        imagesPreviewController.umengEventName = self.eventName;
        
        [imagesPreviewController presentPhotoScrollView];
    }
}

#pragma mark -- TTPhotoScrollViewControllerDelegate

- (void)TTPhotoScrollViewControllerDidFinishSelect:(TTPhotoScrollViewController *)sender;
{
    NSMutableArray * deSelectedImageViews = [NSMutableArray arrayWithCapacity:[sender.isSelecteds count]];
    for (NSUInteger index = 0; index < [sender.isSelecteds count]; ++index)
    {
        if (![[sender.isSelecteds objectAtIndex:index] boolValue])
        {
            [deSelectedImageViews addObject:[self.selectedImageViews objectAtIndex:index]];
        }
    }
    
    for (TTAssetViewColumn * column in deSelectedImageViews)
    {
        [self removeAssetViewColumn:column];
    }
    
    if (sender.navigationController) {
        [sender.navigationController popViewControllerAnimated:YES];
    } else {
        [sender dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end

#define TextViewTopPadding 15.f
#define TextViewLeftPadding 15.f
#define TextViewRightPadding 15.f
#define TextViewHeight 85.f
#define ForwardButtonTopPadding 10.f
#define AddImagesViewTopPadding 18.f

#define CancelAlert 1

#define DummyProgressPercentageOfUploadImages 0.9f
#define DummyStartProgress 0.02f

#define TextViewCharactersLimit 2000

unsigned int g_postForumMinCharactersLimit = 0;
unsigned int g_postMomentMaxCharactersLimit = TextViewCharactersLimit;

@interface ArticlePostMomentViewController ()<UITextViewDelegate, UIAlertViewDelegate, ArticlePostMomentManagerDelegate>
{
}

@property (nonatomic, assign) PostMomentSourceType sourceType;

@property (nonatomic, strong) SSThemedTextView   * inputTextView;
@property (nonatomic, strong) UIView             * inputTextMaskView;

@property (nonatomic, strong) SSCheckbox         * forwardButton;
@property (nonatomic, strong) AddMultiImagesView * addImagesView;
@property (nonatomic, strong) SSNavigationBar    * titleBar;

@property (nonatomic, readonly) ArticlePostMomentManager * manager;

@property (nonatomic, strong) UIView * sendIndicatorContainerView;
@property (nonatomic, strong) MBProgressHUD * sendIndicator;

// Umeng Event
@property (nonatomic, readonly) NSString * eventName;

// Cancel alert view
@property (nonatomic, strong) UIAlertView * cancelAlert;

@property (nonatomic, strong) SSThemedLabel * tipLabel;

@end

@implementation ArticlePostMomentViewController

@synthesize manager = _manager;
@synthesize inputTextMaskView = _inputTextMaskView;

- (instancetype)initWithSourceType:(PostMomentSourceType)sourceType
{
    self = [super init];
    if (self)
    {
        _sourceType = sourceType;
        _forumID = 0;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    wrapperTrackEvent(self.eventName, @"enter");
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.modeChangeActionType = ModeChangeActionTypeCustom;
    
    self.titleBar = [[SSNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [SSNavigationBar navigationBarHeight])];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft withTitle:@"取消" target:self action:@selector(cancelButtonClicked:)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"发送" target:self action:@selector(sendButtonClicked:)]];
    
    
    self.inputTextView = [[SSThemedTextView alloc] initWithFrame:CGRectMake(TextViewLeftPadding, self.titleBar.bottom + TextViewTopPadding, self.view.width - TextViewLeftPadding - TextViewRightPadding, TextViewHeight)];
    self.inputTextView.backgroundColor = [UIColor clearColor];
    self.inputTextView.font = [UIFont systemFontOfSize:14.f];
    self.inputTextView.placeHolder = @"说点什么...";
    self.inputTextView.placeHolderFont = [UIFont systemFontOfSize:16.f];
    self.inputTextView.delegate = self;
    [self.view addSubview:self.inputTextView];
    
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.inputTextView.frame) - 80, CGRectGetMaxY(self.inputTextView.frame) - 12, 70, 10)];
    self.tipLabel.font = [UIFont boldSystemFontOfSize:10.];
    self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.textAlignment = NSTextAlignmentRight;
    self.tipLabel.textColorThemeKey = kColorText9;
    self.tipLabel.hidden = YES;
    [self.view addSubview:self.tipLabel];
    
    if (_sourceType == PostMomentSourceFromForum)
    {
        self.forwardButton = [[SSCheckbox alloc] initWithTitle:@"同时转发到我的动态"];
        self.forwardButton.origin = CGPointMake(TextViewLeftPadding, self.inputTextView.bottom + ForwardButtonTopPadding);
        [self.view addSubview:self.forwardButton];
    }
    
    CGFloat y = (_sourceType == PostMomentSourceFromForum ? self.forwardButton.bottom : self.inputTextView.bottom) + AddImagesViewTopPadding;
    self.addImagesView = [[AddMultiImagesView alloc] initWithFrame:CGRectMake(TextViewLeftPadding, y, self.inputTextView.width, self.view.height - y)];
    self.addImagesView.eventName = self.eventName;
    [self.view addSubview:self.addImagesView];
    
    self.sendIndicatorContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleBar.bottom, self.view.width, self.view.height - self.titleBar.height)];
    _sendIndicatorContainerView.userInteractionEnabled = NO;
    _sendIndicatorContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_sendIndicatorContainerView];
    
    [self reloadThemeUI];
    
    [self.inputTextView becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.cancelAlert isVisible]) {
        [self.cancelAlert dismissWithClickedButtonIndex:self.cancelAlert.cancelButtonIndex animated:NO];
    }
    [self.manager cancelAllOperations];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [_addImagesView showActionSheet];
}

#pragma mark -- Getters

- (ArticlePostMomentManager *)manager
{
    if (!_manager)
    {
        _manager = [[ArticlePostMomentManager alloc] init];
        _manager.delegate = self;
    }
    
    return _manager;
}

- (UIView *)inputTextMaskView
{
    if (!_inputTextMaskView)
    {
        _inputTextMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.inputTextView.bottom, self.view.width, self.view.height - self.inputTextView.bottom)];
        _inputTextMaskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        [_inputTextMaskView addGestureRecognizer:tapGesture];
    }
    
    return _inputTextMaskView;
}

- (NSString *)eventName
{
    switch (_sourceType) {
        case PostMomentSourceFromForum:
            return PostTopicUmengEventName;
        case PostMomentSourceFromMoment:
            return PostMomentUmengEventName;
        default:
            return nil;
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.inputTextView.placeHolderColor = [UIColor tt_themedColorForKey:kColorText3];
    self.inputTextView.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)dismissKeyboard:(UIGestureRecognizer *)gesture
{
    BOOL needDismissKeyboard = YES;
    CGPoint gestureLocation = [gesture locationInView:self.addImagesView.addImagesButton];
    if (CGRectContainsPoint(self.addImagesView.addImagesButton.bounds, gestureLocation)) {
        [self.addImagesView addImagesButtonClicked:nil];
    } else {
        gestureLocation = [gesture locationInView:self.forwardButton];
        if (CGRectContainsPoint(self.forwardButton.bounds, gestureLocation)) {
            [self.forwardButton setChecked:!self.forwardButton.checked];
            needDismissKeyboard = NO;
        }
    }
    
    if (needDismissKeyboard && [self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
        [self.inputTextMaskView removeFromSuperview];
    }
}

- (void)finish
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancelButtonClicked:(id)sender
{
    [self.inputTextView resignFirstResponder];
    if (isEmptyString(self.inputTextView.text) && self.addImagesView.selectedAssetsImages.count == 0)
    {
        wrapperTrackEvent(self.eventName, @"cancel_none");
        [self.manager cancelAllOperations];
        [self finish];
    }
    else
    {
        wrapperTrackEvent(self.eventName, @"cancel");
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"确定退出？", nil) message:@"" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:NSLocalizedString(@"退出", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            wrapperTrackEvent(self.eventName, @"cancel_confirm");
            [self.manager cancelAllOperations];
            [self finish];
        }];
        [alert showFrom:self animated:YES];
    }
}

- (void)sendButtonClicked:(id)sender
{
    [self.inputTextView resignFirstResponder];
    if (isEmptyString(self.inputTextView.text) && self.addImagesView.selectedAssetsImages.count == 0)
    {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"说点什么..." indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        [_inputTextView becomeFirstResponder];
        return;
    }
    
    if (self.inputTextView.text.length > g_postMomentMaxCharactersLimit) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"超出字数限制， 请调整后再发" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (!TTNetworkConnected())
    {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (_sourceType == PostMomentSourceFromForum) {
        if (self.inputTextView.text.length < g_postForumMinCharactersLimit && [_addImagesView.selectedAssetsImages count] == 0) {
            //            NSInteger backup = [SSActivityIndicatorView sharedView].maxNumberOfLineCharacters;
            //            [SSActivityIndicatorView sharedView].maxNumberOfLineCharacters = 10;
            //            [[SSActivityIndicatorView sharedView] showInView:self.view message:[NSString stringWithFormat:@"请至少写%d个字", g_postForumMinCharactersLimit] tipImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]];
            //            [SSActivityIndicatorView sharedView].maxNumberOfLineCharacters = backup;
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"请至少写%d个字", g_postForumMinCharactersLimit] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [_inputTextView becomeFirstResponder];
            return;
        }
    }
    
    if ([_manager isPosting]) {
        return;
    }
    
    if (self.addImagesView.selectedAssetsImages.count == 0) {
        wrapperTrackEvent(self.eventName, @"post");
    } else {
        wrapperTrackEvent(self.eventName, @"post_pic");
    }
    
    if (self.forwardButton.checked) {
        wrapperTrackEvent(self.eventName, @"syn_update");
    }
    
    __weak typeof(self) wself = self;
    ArticleMobilePiplineCompletion sendLogic =  ^(ArticleLoginState state){
        
        wself.sendIndicator = [MBProgressHUD showHUDAddedTo:wself.sendIndicatorContainerView animated:YES];
        wself.sendIndicator.opacity = 0.5f;
        wself.sendIndicator.mode = MBProgressHUDModeDeterminate;
        wself.sendIndicator.progress = DummyStartProgress;
        [wself.manager cancelAllOperations];
        [wself.manager PostMomentWithContent:wself.inputTextView.text ForumID:wself.forumID AssetsImages:wself.addImagesView.selectedAssetsImages FromSource:wself.sourceType NeedForward:wself.forwardButton.checked ? 1 : 0];
    };
    
    if (![TTAccountManager isLogin]) {
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_dongtai" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                //登录成功 走发送逻辑
                if ([TTAccountManager isLogin]) {
                    sendLogic(ArticleLoginStatePlatformLogin);
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:self type:TTAccountLoginDialogTitleTypeDefault source:@"post_dongtai" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
    else {
        
        sendLogic(ArticleLoginStateMobileLogin);
        
    }
}


- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName autoHidden:(BOOL)autoHide
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage themedImageNamed:imgName] autoDismiss:YES dismissHandler:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!self.inputTextMaskView.superview)
    {
        [self.view addSubview:self.inputTextMaskView];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.inputTextView.text.length > g_postMomentMaxCharactersLimit) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d", nil), (NSInteger)(g_postMomentMaxCharactersLimit - self.inputTextView.text.length)];
    } else {
        self.tipLabel.hidden = YES;
    }
}

#pragma mark -- ArticlePostMomentManagerDelegate

- (void)postMomentManager:(ArticlePostMomentManager *)manager postFinishWithError:(NSError *)error
{
    if (error)
    {
        if (self.addImagesView.selectedAssetsImages.count == 0) {
            wrapperTrackEvent(self.eventName, @"post_fail");
        } else {
            wrapperTrackEvent(self.eventName, @"post_pic_fail");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:_sendIndicatorContainerView animated:YES];
            NSString * errorMsg = @"发送失败，请稍后再试";
            id description = [error.userInfo objectForKey:@"description"];
            if (description) {
                errorMsg = [NSString stringWithFormat:@"%@", description];
            }
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errorMsg indicatorImage:[UIImage themedImageNamed:@"excalmatoryicon_loading.png"] autoDismiss:YES dismissHandler:nil];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sendIndicator.progress = 1.f;
            [MBProgressHUD hideHUDForView:_sendIndicatorContainerView animated:YES];
            [self finish];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"发送成功" indicatorImage:[UIImage themedImageNamed:@"tickicon_loading.png"] autoDismiss:YES dismissHandler:nil];
        });
    }
}

- (void)postMomentManager:(ArticlePostMomentManager *)manager uploadImagesProgress:(NSNumber *)progress
{
    if (self.sendIndicator) {
        CGFloat sendProgress = [progress floatValue] * DummyProgressPercentageOfUploadImages + DummyStartProgress;
        
        self.sendIndicator.progress = sendProgress;
        
    }
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CancelAlert)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            wrapperTrackEvent(self.eventName, @"cancel_confirm");
            [self.manager cancelAllOperations];
            [self finish];
        }
    }
}

@end
