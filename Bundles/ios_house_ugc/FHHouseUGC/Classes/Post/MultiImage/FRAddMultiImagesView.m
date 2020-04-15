//
//  FRAddMultiImagesView.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import "FRAddMultiImagesView.h"
#import "FRPostAssetViewColumn.h"
#import "TTPostThreadDefine.h"
//#import "TTPostThreadBridge.h"

#import <TTUIWidget/TTIndicatorView.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <TTUIWidget/TTThemedAlertController.h>
#import <TTThemed/SSThemed.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import <TTImagePicker/TTImagePicker.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/UIImageAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import "SDImageCache.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <TTBaseLib/TTUIResponderHelper.h>

#define NumberOfImagesPerRow 3
#define ImagesInterval 4.f
#define kImageHeightInterval 4.f

@interface FRAddMultiImagesView() <FRPostAssetViewColumnDelegate, UIActionSheetDelegate,TTImagePickerControllerDelegate,TTImagePreviewViewControllerDelegate>
{
    CGFloat _imageSize;
}

@property (nonatomic, strong) NSMutableArray *selectedImageViews;

@property (nonatomic, readwrite) NSMutableArray *selectedImageCacheTasks;

@property (nonatomic, strong) id<TTImagePickTrackDelegate> imageTrackerIMP;

@property (nonatomic, strong) UIView *currentPreviewMaskView; //蒙在当前预览view上的

@property (nonatomic, strong) UIButton *addImagesButton;

@property (nonatomic, strong) UIView *disableInteractionView;

@end

@implementation FRAddMultiImagesView

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray *)assets images:(NSArray <UIImage *> *)images
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dragEnable = YES;
        _imageSize = (self.width - (NumberOfImagesPerRow - 1) * ImagesInterval) / NumberOfImagesPerRow;
        self.backgroundColor = [UIColor clearColor];
        self.selectionLimit = DefaultImagesSelectionLimit;
        self.selectedImageViews = [NSMutableArray array];
        self.selectedImageCacheTasks = [NSMutableArray array];
        
        self.addImagesButton = [FHAddPhotoButton buttonWithType:UIButtonTypeCustom];
        self.addImagesButton.frame = CGRectMake(0, 0, _imageSize, _imageSize);
        self.addImagesButton.layer.cornerRadius = 4.0;
        self.addImagesButton.backgroundColor = [UIColor themeGray7];
        [self.addImagesButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.addImagesButton];
        
        [self changeHeight:(_addImagesButton.bottom) notiy:YES];
        [self reloadThemeUI];
        
        
        [self addAssets:assets];
        [self addImages:images];
    }
    return self;
}

- (void)setHideAddImagesButtonWhenEmpty:(BOOL)hideAddImagesButtonWhenEmpty
{
    if (!_hideAddImagesButtonWhenEmpty == hideAddImagesButtonWhenEmpty) {
        _hideAddImagesButtonWhenEmpty = hideAddImagesButtonWhenEmpty;
        [self hideAddImagesButtonIfNeed];
    }
}

- (void)hideAddImagesButtonIfNeed
{
    // 通过数据来判断，而不是ImageView的个数，因为有动画
    if (self.selectedImageCacheTasks.count >= self.selectionLimit) {
        self.addImagesButton.hidden = YES;
    } else if (self.hideAddImagesButtonWhenEmpty && self.selectedImageCacheTasks.count == 0) {
        self.addImagesButton.hidden = YES;
    } else {
        self.addImagesButton.hidden = NO;
    }
}

- (void)restoreDraft:(NSArray *)models {
    if (self.selectedImageCacheTasks.count > 0) {
        return;
    }
    for (FRUploadImageModel *model in models) {
        if ([model.cacheTask isCompressed]) {
            [self.selectedImageCacheTasks addObject:model.cacheTask];
            [self appendAssetViewColumnByImage:model.thumbnailImg task:nil];
        }
    }
}

- (void)startTrackImagepicker {
    //开始伴随本类的生命周期，做图片选择器的埋点
//    self.imageTrackerIMP = [[TTPostThreadBridge sharedInstance] imagePickerTrackerWithEventName:self.eventName extraParams:self.ssTrackDict];
}

- (void)changeHeight:(CGFloat)height notiy:(BOOL)notify {
    self.height = height;
    [self hideAddImagesButtonIfNeed];
    if (notify && self.delegate && [self.delegate respondsToSelector:@selector(addMultiImagesView:changeToSize:)]) {
        [self.delegate addMultiImagesView:self changeToSize:self.frame.size];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
}

- (void)appendSelectedImage:(UIImage *)image {
    TTUGCImageCompressTask* task = [[TTUGCImageCompressManager sharedInstance] generateTaskWithImage:image];
    if (task) {
        UIImage * thumbnail = [image thumbnailImage:_imageSize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
        [self.selectedImageCacheTasks addObject:task];
        [self appendAssetViewColumnByImage:thumbnail task:nil];
    }
}

- (void)appendAssetViewColumnByImage:(UIImage *)image task:(TTUGCImageCompressTask *)task {
    FRPostAssetViewColumn * assetViewColumn = [[FRPostAssetViewColumn alloc] initWithFrame:self.addImagesButton.frame];
    assetViewColumn.dragEnable = self.dragEnable;
    assetViewColumn.layer.cornerRadius = 4;
    assetViewColumn.clipsToBounds = YES;
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
    }else{
        UIView *lastImageView = self.selectedImageViews.lastObject;
        if(self.selectedImageViews.count >= self.selectionLimit && lastImageView) {
            [self changeHeight:(lastImageView.bottom) notiy:YES];
        } else {
            [self changeHeight:(_addImagesButton.bottom) notiy:YES];
        }
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
            TTUGCImageCompressTask* task = [_selectedImageCacheTasks objectAtIndex:index];
            [[TTUGCImageCompressManager sharedInstance] removeCompressTask:task];
            [self.selectedImageCacheTasks removeObjectAtIndex:index];
        }
        
        [assetViewColumn removeFromSuperview];
        [self.selectedImageViews removeObjectAtIndex:index];
        
        if (self.selectedImageViews.count < 9) {
            self.addImagesButton.hidden = NO;
            [self changeHeight:(_addImagesButton.bottom) notiy:YES];
        }
        if (self.hideAddImagesButtonWhenEmpty && self.selectedImageCacheTasks.count == 0) {
            self.addImagesButton.hidden = YES;
        }
    }
    [self onDraggingLayout];
}

- (void)removeAssetViewColumnWithIndex:(NSUInteger)index
{
    FRPostAssetViewColumn *assetViewColumn = self.selectedImageViews[index];
    [self removeAssetViewColumn:assetViewColumn];
}

- (void)showImagePicker
{
    if (self.shouldAddPictureHandle) {
        self.shouldAddPictureHandle();
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(addImagesButtonDidClickedOfAddMultiImagesView:)]) {
        [self.delegate addImagesButtonDidClickedOfAddMultiImagesView:self];
    }
    if ([self.selectedImageCacheTasks count] >= self.selectionLimit) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"最多可选%ld张图片", (long)self.selectionLimit] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    TTImagePickerController *imgPick = [[TTImagePickerController alloc] initWithDelegate:self];
    imgPick.enableICloud = YES;
    imgPick.maxResourcesCount = self.selectionLimit - [self.selectedImageCacheTasks count];
    imgPick.isGetOriginResource = NO;
    imgPick.isHideGIF = YES;
    [imgPick presentOn:self.viewController.navigationController];
    
    [TTTrackerWrapper eventV3:@"click_add_image" params:nil];
}

// 发 问答 图片上传模型
- (NSMutableArray<WDImageObjectUploadImageModel *> *)selectedImages {
    if (self.selectedImageCacheTasks.count > 0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (TTUGCImageCompressTask *task in self.selectedImageCacheTasks) {
            // 图片资源
            if (task.preCompressFilePath.length > 0) {
                NSData *uploadData = [NSData dataWithContentsOfFile:task.preCompressFilePath];
                if (uploadData) {
                    UIImage *uploadImage = [UIImage sd_imageWithData:uploadData];
                    if (uploadImage) {
                        WDImageObjectUploadImageModel *imageModel = [[WDImageObjectUploadImageModel alloc] initWithcompressImg:uploadImage];
                        [tempArray addObject:imageModel];
                    }
                }
            } else if (task.assetModel.cacheImage) {
                UIImage *image = task.assetModel.cacheImage;
                WDImageObjectUploadImageModel *imageModel = [[WDImageObjectUploadImageModel alloc] initWithcompressImg:image];
                [tempArray addObject:imageModel];
            } else if (task.assetModel.imageURL) {
                WDImageObjectUploadImageModel *imageModel = [[WDImageObjectUploadImageModel alloc] initWithcompressImg:nil];
                [imageModel loadImageWithURL:task.assetModel.imageURL];
                [tempArray addObject:imageModel];
            } else {
                UIImage *image = task.assetModel.thumbImage;
                WDImageObjectUploadImageModel *imageModel = [[WDImageObjectUploadImageModel alloc] initWithcompressImg:image];
                [tempArray addObject:imageModel];
            }
        }
        return tempArray;
    }
    return nil;
}

#pragma mark - Add asset or image

- (void)addAssets:(NSArray *)assets {
    
    if (!assets) {
        return;
    }
        
    for (id asset in assets) {
        if([asset isKindOfClass:[UIImage class]]) {
            [self appendSelectedImage:asset];
        } else if ([asset isKindOfClass:[TTAssetModel class]]){
            TTUGCImageCompressTask *task = [[TTUGCImageCompressManager sharedInstance] generateTaskWithAssetModel:asset];
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

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAsset *> *)assets {

    NSMutableArray *oldAssets = [NSMutableArray arrayWithCapacity:assets.count];
    
    [assets enumerateObjectsUsingBlock:^(TTAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAssetModel *oldAssetModel = [TTAssetModel modelWithAsset:asset.asset type:asset.type];
        [oldAssets addObject:oldAssetModel];
    }];
    
    
    if (!SSIsEmptyArray(oldAssets)) {
        [self addAssets:oldAssets];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImagesViewPresentedViewControllerDidDismiss)]) {
        [self.delegate addMultiImagesViewPresentedViewControllerDidDismiss];
    }
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAsset *> *)assets withInfo:(NSDictionary *)info {

    NSMutableArray *oldAssets = [NSMutableArray arrayWithCapacity:assets.count];
    
    [assets enumerateObjectsUsingBlock:^(TTAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAssetModel *oldAssetModel = [TTAssetModel modelWithAsset:asset.asset type:asset.type];
        [oldAssets addObject:oldAssetModel];
    }];
    
    if (!SSIsEmptyArray(oldAssets)) {
        [self addAssets:oldAssets];
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
        for (TTUGCImageCompressTask* task in self.selectedImageCacheTasks) {
            if (task.assetModel) {
                [selectedModels addObject:task.assetModel];
            } else if ([task.originalSource isKindOfClass:[UIImage class]]) {
                TTAssetModel *model = [[TTAssetModel alloc]init];
                model.cacheImage = task.originalSource;
                [selectedModels addObject:model];
            } else if ([task.originalSource isKindOfClass:[NSString class]]) {
                TTAssetModel *model = [[TTAssetModel alloc]init];
                [[TTUGCImageCompressManager sharedInstance] queryFilePathWithTask:task complete:^(NSString *path) {
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

- (void)onDragingAssetViewColumn:(FRPostAssetViewColumn *)sender atPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(addMultiImagesViewNeedEndEditing)]) {
        [self.delegate addMultiImagesViewNeedEndEditing];
    }
    NSUInteger index = [self.selectedImageViews indexOfObject:sender];
    NSUInteger targetIndex = [self pointIndexgAssetViewColumn:point];
    if (index != NSNotFound && targetIndex != NSNotFound && index != targetIndex) {
        if (self.selectedImageCacheTasks.count == self.selectedImageViews.count) {
            TTUGCImageCompressTask *obj = [self.selectedImageCacheTasks objectAtIndex:index];
            [self.selectedImageCacheTasks removeObjectAtIndex:index];
            [self.selectedImageCacheTasks insertObject:obj atIndex:targetIndex];
        }
        if (self.selectedThumbImages.count == self.selectedImageViews.count) {
            UIImage *obj = [self.selectedThumbImages objectAtIndex:index];
            [self.selectedThumbImages removeObjectAtIndex:index];
            [self.selectedThumbImages insertObject:obj atIndex:targetIndex];
        }
        [self.selectedImageViews removeObject:sender];
        [self.selectedImageViews insertObject:sender atIndex:targetIndex];
        
        [self onDraggingLayout];
    }
}

- (NSUInteger)pointIndexgAssetViewColumn:(CGPoint)point {
    CGFloat x, y = 0;
    int index = 0;
    
    for (; index < _selectedImageViews.count; index++) {
        int column = index / NumberOfImagesPerRow;
        int row = index % NumberOfImagesPerRow;
        y = column * (_imageSize + kImageHeightInterval);
        x = row * (_imageSize + ImagesInterval);
        CGRect frame = CGRectMake(x, y, _imageSize, _imageSize);
        if (CGRectContainsPoint(frame, point)) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)onDraggingLayout {
    __block CGFloat x, y = 0;
    __block int index = 0;
    
    [CATransaction begin];
    CAMediaTimingFunction *funtion = [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
    [CATransaction setAnimationTimingFunction:funtion];
    WeakSelf;
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        StrongSelf;
        if (self == nil) {
            return;
        }
        for (FRPostAssetViewColumn *imageView in self->_selectedImageViews) {
            int column = index / NumberOfImagesPerRow;
            int row = index % NumberOfImagesPerRow;
            y = column * (self->_imageSize + kImageHeightInterval);
            x = row * (self->_imageSize + ImagesInterval);
            [imageView setDragTargetFrame:CGRectMake(x, y, self->_imageSize, self->_imageSize)];
            index++;
        }
    } completion:^(BOOL finished) {
    }];
    [CATransaction commit];
    
    int column = index / NumberOfImagesPerRow;
    int row = index % NumberOfImagesPerRow;
    y = column * (_imageSize + kImageHeightInterval);
    x = row * (_imageSize + ImagesInterval);
    self.addImagesButton.frame = CGRectMake(x, y, _imageSize, _imageSize);
    [self changeHeight:(_addImagesButton.bottom) notiy:YES];
}

- (void)assetViewColumnDidBeginDragging:(FRPostAssetViewColumn *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImageViewDidBeginDragging:)]) {
        [self.delegate addMultiImageViewDidBeginDragging:self];
    }
}

- (void)assetViewColumnDidFinishDragging:(FRPostAssetViewColumn *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addMultiImageViewDidFinishDragging:)]) {
        [self.delegate addMultiImageViewDidFinishDragging:self];
    }
}

#pragma mark  -- TTImagePreviewViewControllerDelegate
- (void)ttImagePreviewViewControllerDidDismiss:(TTImagePreviewViewController *)controller {
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

- (void)ttImagePreviewViewControllerSelectChange:(TTImagePreviewViewController *)controller index:(NSInteger)index {
    if (index < 0 || index >= self.selectedImageViews.count) {
        return;
    }
    [self removeAssetViewColumnWithIndex:index];
}

@end


// FHAddPhotoButton
@interface FHAddPhotoButton ()

@property (nonatomic, strong)   UIImageView       *addImageView;
@property (nonatomic, strong)   UILabel       *addLabel;

@end

@implementation FHAddPhotoButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _addImageView = [[UIImageView alloc] initWithImage:ICON_FONT_IMG(40, @"\U0000e69b", [UIColor themeGray4])];//fh_ugc_add_pic_normal
    [self addSubview:_addImageView];
    _addLabel = [[UILabel alloc] init];
    _addLabel.text = @"添加照片";
    _addLabel.textColor = [UIColor themeGray3];
    _addLabel.font = [UIFont themeFontRegular:14];
    _addLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_addLabel];
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - (NumberOfImagesPerRow - 1) * ImagesInterval) / NumberOfImagesPerRow;
    CGFloat offset = (w - 69) / 2;
    // 布局
    [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(offset);
        make.centerX.mas_equalTo(self);
        make.height.width.mas_equalTo(40);
    }];
    [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addImageView.mas_bottom).offset(9);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
}

@end
