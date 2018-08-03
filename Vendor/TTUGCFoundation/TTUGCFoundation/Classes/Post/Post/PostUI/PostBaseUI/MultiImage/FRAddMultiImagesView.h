//
//  FRAddMultiImagesView.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"
#import "TTForumPostImageCache.h"
#import "FRUploadImageModel.h"

@class FRAddMultiImagesView;
@class ALAssetsLibrary;
@class ALAsset;
#import "TTAssetModel.h"
@protocol FRAddMultiImagesViewDelegate <NSObject>

@optional
- (void)addImagesButtonDidClickedOfAddMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView;

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView clickedImageAtIndex:(NSUInteger)index;

- (void)addMultiImagesViewPresentedViewControllerDidDismiss;

@end

typedef void(^FRAddMultiImagesViewFrameChangedBlock)(CGSize size);

@interface FRAddMultiImagesView : SSThemedView
@property (nonatomic, assign)   NSInteger selectionLimit;

@property (nonatomic, readonly) NSMutableArray<TTForumPostImageCacheTask*> * selectedImageCacheTasks;
@property (nonatomic, readonly) NSMutableArray<UIImage*> * selectedThumbImages;

// Umeng Event Name
@property(nonatomic, copy) NSString * eventName;
@property (nonatomic, strong) UIButton        * addImagesButton;
@property(nonatomic, weak)id delegate;
@property (nonatomic, copy)NSDictionary *ssTrackDict;

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray *)assets images:(NSArray <UIImage *> *)images;

- (void)restoreDraft:(NSArray<FRUploadImageModel *> *)models;

- (void)addImagesButtonClicked:(id)sender;

- (void)frameChangedBlock:(FRAddMultiImagesViewFrameChangedBlock)block;

- (NSArray *)imageViews;//返回值是UIImageViews

- (void)startTrackImagepicker;

@end
