//
//  FRAddMultiImagesView.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import "FRAddMultiImagesView.h"
#import "FRPostAssetViewColumn.h"
#import "FRPostThreadDefine.h"
#import "TTIndicatorView.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "TTThemedAlertController.h"
#import "SSThemed.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "UIImage+MultiFormat.h"
#import <BDWebImage/SDWebImageAdapter.h>

#import "TTImagePicker.h"
#import "TTImagePickerTrackDelegate.h"
#import "UIViewAdditions.h"
#import "UIImageAdditions.h"
#import "TTTrackerWrapper.h"

#define NumberOfImagesPerRow 3
#define ImagesInterval 3.f
#define kImageHeightInterval 3.f

@interface FRAddMultiImagesView() <FRPostAssetViewColumnDelegate, UIActionSheetDelegate,TTImagePickerControllerDelegate,TTImagePreviewViewControllerDelegate>
{
    CGFloat _imageSize;
}

@property (nonatomic, strong   ) NSMutableArray  * selectedImageViews;

@property (nonatomic, readwrite) NSMutableArray  * selectedImageCacheTasks;

@property (nonatomic, strong)TTImagePickerTrackDelegate *trackDelegate;
@property (nonatomic,strong) UIView *currentPreviewMaskView; //蒙在当前预览view上的


@property(nonatomic, strong) UIView * disableInteractionView;

@property(nonatomic, strong)FRAddMultiImagesViewFrameChangedBlock changeFrameBlock;
@end

@implementation FRAddMultiImagesView

- (void)dealloc
{
    [TTImagePickerManager manager].accessIcloud = NO;
    self.changeFrameBlock = nil;
}

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray *)assets images:(NSArray <UIImage *> *)images
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageSize = (self.width - (NumberOfImagesPerRow - 1) * ImagesInterval) / NumberOfImagesPerRow;
        self.backgroundColor = [UIColor clearColor];
        self.selectionLimit = DefaultImagesSelectionLimit;
        self.selectedImageViews = [NSMutableArray array];
        self.selectedImageCacheTasks = [NSMutableArray array];
        
        self.addImagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addImagesButton.frame = CGRectMake(0, 0, _imageSize, _imageSize);
        [self.addImagesButton addTarget:self action:@selector(addImagesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.addImagesButton];
        
        [self changeHeight:(_addImagesButton.bottom) notiy:YES];
        [self reloadThemeUI];
        
        
        [self addAssets:assets];
        [self addImages:images];
    }
    return self;
}

- (void)restoreDraft:(NSArray *)models {
    if (self.selectedImageCacheTasks.count > 0) {
        return;
    }
    for (FRUploadImageModel *model in models) {
        if ([[TTForumPostImageCache sharedInstance] fileExist:model.cacheTask]) {
            [self.selectedImageCacheTasks addObject:model.cacheTask];
            [self appendAssetViewColumnByImage:model.thumbnailImg task:nil];
        }
    }
}

- (void)startTrackImagepicker
{
    //开始伴随本类的生命周期，做图片选择器的埋点
    self.trackDelegate = [[TTImagePickerTrackDelegate alloc]initWithEventName:self.eventName TrackDic:self.ssTrackDict];
}

- (NSArray *)imageViews
{
    return _selectedImageViews;
}

- (void)changeHeight:(CGFloat)height notiy:(BOOL)notify
{
    self.height = height;
    
    if (notify && self.changeFrameBlock) {
        _changeFrameBlock(self.frame.size);
    }
}

- (void)frameChangedBlock:(FRAddMultiImagesViewFrameChangedBlock)block
{
    self.changeFrameBlock = block;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];

    self.addImagesButton.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
    [self.addImagesButton setImage:[UIImage themedImageNamed:@"addicon_repost"] forState:UIControlStateNormal];
    [self.addImagesButton setImage:[UIImage themedImageNamed:@"addicon_repost_press"] forState:UIControlStateHighlighted];
    self.addImagesButton.layer.borderColor = SSGetThemedColorWithKey(kColorLine1).CGColor;
}



- (void)appendSelectedImage:(UIImage *)image {
    TTForumPostImageCacheTask* task = [[TTForumPostImageCache sharedInstance]saveCacheSource:image];
    if (task) {
        UIImage * thumbnail = [image thumbnailImage:_imageSize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
        [self.selectedImageCacheTasks addObject:task];
        [self appendAssetViewColumnByImage:thumbnail task:nil];
    }
}

- (void)appendAssetViewColumnByImage:(UIImage *)image task:(TTForumPostImageCacheTask *)task
{
    FRPostAssetViewColumn * assetViewColumn = [[FRPostAssetViewColumn alloc] initWithFrame:self.addImagesButton.frame];
    assetViewColumn.modeChangeActionType = ModeChangeActionTypeMask;
    
    if (image) {
        [assetViewColumn loadWithImage:image];
    }
    
    if (task && task.assetModel) {
        [assetViewColumn loadWithAsset:task.assetModel];
        assetViewColumn.task = task;
    }

    assetViewColumn.delegate = self;
    [assetViewColumn reloadThemeUI];
    
    CGFloat x = (assetViewColumn.right) + ImagesInterval;
    CGFloat y = (assetViewColumn.top);
    if (x + _imageSize > self.width)
    {
        x = 0;
        y += _imageSize + kImageHeightInterval;
    }
    self.addImagesButton.origin = CGPointMake(x, y);
    
   
    
    [self addSubview:assetViewColumn];
    [self.selectedImageViews addObject:assetViewColumn];
    
    
    if (self.selectedImageViews.count >= 9) {
        self.addImagesButton.hidden = YES;
        [self changeHeight:(assetViewColumn.bottom) notiy:YES];

    }else{
        [self changeHeight:(_addImagesButton.bottom) notiy:YES];

    }
    
}

- (NSMutableArray<UIImage *> *)selectedThumbImages {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.selectedImageViews.count];
    for (FRPostAssetViewColumn* columnn in self.selectedImageViews) {
        if (columnn.assetImageView.image) {
            [result addObject:columnn.assetImageView.image];
        }
    }
    return result;
}

- (void)removeAssetViewColumn:(FRPostAssetViewColumn *)assetViewColumn
{
    NSUInteger index = [self.selectedImageViews indexOfObject:assetViewColumn];
    if (index != NSNotFound)
    {
        if (index < [_selectedImageCacheTasks count]) {
            TTForumPostImageCacheTask* task = [_selectedImageCacheTasks objectAtIndex:index];
            [[TTForumPostImageCache sharedInstance] removeTask:task];
            [self.selectedImageCacheTasks removeObjectAtIndex:index];
        }
        
        CGRect frame = assetViewColumn.frame;
        [assetViewColumn removeFromSuperview];
        for (NSUInteger i = index + 1 ; i < self.selectedImageViews.count; ++i)
        {
            FRPostAssetViewColumn * column = [self.selectedImageViews objectAtIndex:i];
            CGRect tempFrame = column.frame;
            column.frame = frame;
            frame = tempFrame;
        }
        self.addImagesButton.frame = frame;
        
        [self.selectedImageViews removeObjectAtIndex:index];
        
        if (self.selectedImageViews.count < 9) {
            self.addImagesButton.hidden = NO;
            [self changeHeight:(_addImagesButton.bottom) notiy:YES];
        }
    }
}

- (void)removeAssetViewColumnWithIndex:(NSUInteger)index
{
    FRPostAssetViewColumn *assetViewColumn = self.selectedImageViews[index];
    [self removeAssetViewColumn:assetViewColumn];
}

- (void)addImagesButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addImagesButtonDidClickedOfAddMultiImagesView:)]) {
        [self.delegate addImagesButtonDidClickedOfAddMultiImagesView:self];
    }
    if ([self.selectedImageCacheTasks count] >= self.selectionLimit) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"最多可选%ld张图片", (long)self.selectionLimit] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    [TTImagePickerManager manager].accessIcloud = YES;
    
    TTImagePickerController *imgPick = [[TTImagePickerController alloc] initWithDelegate:self];
    imgPick.maxImagesCount = self.selectionLimit - [self.selectedImageCacheTasks count];
    imgPick.isRequestPhotosBack = NO;
    [imgPick presentOn:self.viewController.navigationController];
    
    [TTTrackerWrapper eventV3:@"click_add_image" params:nil];
}

#pragma mark - Add asset or image

- (void)addAssets:(NSArray *)assets {
    
    if (!assets) {
        return;
    }
    
    for (id asset in assets) {
        if([asset isKindOfClass:[UIImage class]]) {
            [self appendSelectedImage:asset];
        } else{
            TTForumPostImageCacheTask *task = [[TTForumPostImageCache sharedInstance]saveCacheSource:asset];
            if (task) {
                [self.selectedImageCacheTasks addObject:task];
                [self appendAssetViewColumnByImage:nil task:task];
            }
        }
    }
}

- (void)addImages:(NSArray <UIImage *> *)images {
    for (UIImage * tImage in images) {
        CGFloat longEdge = [TTUIResponderHelper screenSize].height;
        CGFloat ratio = longEdge / MAX(tImage.size.height, tImage.size.width);
        CGSize newSize = CGSizeMake(tImage. size.width * ratio * [UIScreen mainScreen].scale, tImage.size.height * ratio * [UIScreen mainScreen].scale);
        UIImage *image = [tImage resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
        [self appendSelectedImage:image];
    }
}

#pragma mark - TTImagePickerControllerDelegate

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets
{
    if (!SSIsEmptyArray(assets)) {
        [self addAssets:assets];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImagesViewPresentedViewControllerDidDismiss)]) {
        [self.delegate addMultiImagesViewPresentedViewControllerDidDismiss];
    }
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info
{
    if (!SSIsEmptyArray(assets)) {
        [self addAssets:assets];
    }
    [self appendSelectedImage:photo];

    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImagesViewPresentedViewControllerDidDismiss)]) {
        [self.delegate addMultiImagesViewPresentedViewControllerDidDismiss];
    }
}

- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImagesViewPresentedViewControllerDidDismiss)]) {
        [self.delegate addMultiImagesViewPresentedViewControllerDidDismiss];
    }
}

#pragma mark -- FRPostAssetViewColumnDelegate

- (void)didTapAssetViewColumn:(FRPostAssetViewColumn *)sender {
    NSUInteger index = [self.selectedImageViews indexOfObject:sender];
    if (index != NSNotFound)
    {
        wrapperTrackEventWithCustomKeys(self.eventName, @"preview_photo", nil, nil, self.ssTrackDict);
        
        if (_delegate && [_delegate respondsToSelector:@selector(addMultiImagesView:clickedImageAtIndex:)]) {
            [_delegate addMultiImagesView:self clickedImageAtIndex:index];
        }
        
        NSMutableArray *selectedModels = [NSMutableArray array];
        for (TTForumPostImageCacheTask* task in self.selectedImageCacheTasks) {
            if (task.assetModel) {
                [selectedModels addObject:task.assetModel];
            } else if ([task.originalSource isKindOfClass:[UIImage class]]) {
                TTAssetModel *model = [[TTAssetModel alloc]init];
                model.cacheImage = task.originalSource;
                [selectedModels addObject:model];
            } else if ([task.originalSource isKindOfClass:[NSString class]]) {
                TTAssetModel *model = [[TTAssetModel alloc]init];
                [[TTForumPostImageCache sharedInstance] queryFilePathWithSource:task complete:^(NSString *path) {
                    UIImage *img = [[SDWebImageAdapter sharedAdapter] imageFromMemoryCacheForKey:path];
                    if (img == nil) {
                        NSData *data = [NSData dataWithContentsOfFile:path];
                        img = [UIImage sd_imageWithData:data];
                        if (img) {
                            [[SDWebImageAdapter sharedAdapter] storeImage:img imageData:nil forKey:path toDisk:NO completion:nil];
                        }
                    }
                    model.cacheImage = img;
                }];
                
                [selectedModels addObject:model];
            }
        }
        
        TTImagePreviewViewController *previewVC = [TTImagePreviewViewController deletePreviewViewControllerWithModes:selectedModels index:index delegate:self];
        previewVC.tapView = sender.assetImageView;
        [previewVC presentOn:self.viewController.navigationController];
        
    }
}

- (void)didDeleteAssetViewColumn:(FRPostAssetViewColumn *)sender {
    wrapperTrackEventWithCustomKeys(self.eventName, @"post_photo_delete", nil, nil, self.ssTrackDict);
    [self removeAssetViewColumn:sender];
}


#pragma mark  -- TTImagePreviewViewControllerDelegate
- (void)ttImagePreviewViewControllerDidDismiss:(TTImagePreviewViewController *)controller
{
    BOOL showAnimating = NO;
    if (controller.animatedImageView && _currentPreviewMaskView && _currentPreviewMaskView.superview) {
        showAnimating = YES;
        
        CGRect frame = [_currentPreviewMaskView convertRect:_currentPreviewMaskView.bounds toView:controller.view];
        
        [UIView animateWithDuration:0.2 animations:^{
            controller.animatedImageView.frame = frame;
        } completion:^(BOOL finished) {
            [_currentPreviewMaskView removeFromSuperview];
        }];
    }
    
    if (!showAnimating) {
        if (_currentPreviewMaskView) {
            [_currentPreviewMaskView removeFromSuperview];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImagesViewPresentedViewControllerDidDismiss)]) {
        [self.delegate addMultiImagesViewPresentedViewControllerDidDismiss];
    }
}

- (void)ttImagePreviewViewControllerScrollChange:(TTImagePreviewViewController *)controller index:(NSInteger)index {
    if (_currentPreviewMaskView) {
        [_currentPreviewMaskView removeFromSuperview];
    }
    FRPostAssetViewColumn *assetViewColumn = self.selectedImageViews[controller.currentIndex];
    CGRect frame = [assetViewColumn convertRect:assetViewColumn.bounds toView:self.viewController.view];
    if (!_currentPreviewMaskView) {
        _currentPreviewMaskView = [[UIView alloc] init];
        _currentPreviewMaskView.backgroundColor = [UIColor whiteColor];
    }
    _currentPreviewMaskView.frame = frame;
    [self.viewController.view addSubview:_currentPreviewMaskView];
}


- (void)ttImagePreviewViewControllerSelectChange:(TTImagePreviewViewController *)controller index:(NSInteger)index
{
    if (index < 0 || index >= self.selectedImageViews.count) {
        return;
    }
    [self removeAssetViewColumnWithIndex:index];
}


@end
