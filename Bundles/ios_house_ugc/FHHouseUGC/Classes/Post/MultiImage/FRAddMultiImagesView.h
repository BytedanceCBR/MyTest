//
//  FRAddMultiImagesView.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import <TTThemed/SSViewBase.h>
#import <TTThemed/SSThemed.h>
#import <TTUGCFoundation/TTUGCImageCompressManager.h>
#import <ios_house_im/FRUploadImageModel.h>
#import "WDImageObjectUploadImageModel.h"
#import <TTImagePicker/ALAssetsLibrary+TTImagePicker.h>

@class FRAddMultiImagesView;
@protocol FRAddMultiImagesViewDelegate <NSObject>

@optional
- (void)addImagesButtonDidClickedOfAddMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView;

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView clickedImageAtIndex:(NSUInteger)index;

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView changeToSize:(CGSize)size;

- (void)addMultiImagesViewPresentedViewControllerDidDismiss;

- (void)addMultiImagesViewNeedEndEditing;

- (void)addMultiImageViewDidBeginDragging:(FRAddMultiImagesView *)addMultiImagesView;

- (void)addMultiImageViewDidFinishDragging:(FRAddMultiImagesView *)addMultiImagesView;

@end


@interface FRAddMultiImagesView : SSThemedView

@property (nonatomic, assign) NSInteger selectionLimit;
@property (nonatomic, assign) BOOL hideAddImagesButtonWhenEmpty; // 是否在没有图片时依然隐藏+号，通过代码添加有效图片后就恢复
@property (nonatomic, readonly) NSMutableArray<TTUGCImageCompressTask *> *selectedImageCacheTasks;
@property (nonatomic, readonly) NSMutableArray<WDImageObjectUploadImageModel *> *selectedImages; // 问答 所需模型数据
@property (nonatomic, readonly) NSMutableArray<UIImage *> *selectedThumbImages;
@property (nonatomic, weak) id<FRAddMultiImagesViewDelegate> delegate;
@property (nonatomic, copy) void(^shouldAddPictureHandle)(void);
@property (nonatomic, assign)   BOOL       dragEnable;// 默认是YES

// Umeng Event Name
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSDictionary *ssTrackDict;

- (instancetype)initWithFrame:(CGRect)frame
                       assets:(NSArray *)assets
                       images:(NSArray<UIImage *> *)images;

- (void)restoreDraft:(NSArray<FRUploadImageModel *> *)models;

- (void)startTrackImagepicker;

- (void)showImagePicker;

@end

// + 按钮
@interface FHAddPhotoButton : UIButton

@end
