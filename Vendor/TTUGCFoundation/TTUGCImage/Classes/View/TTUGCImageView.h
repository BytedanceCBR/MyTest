//
//  TTUGCImageView.h
//  Article
//
//  FLAnimatedImageView的代理容器，所有下载、播放逻辑全都来自内部宿主ImageView。
//  Created by jinqiushi on 2018/1/9.
//

#import <UIKit/UIKit.h>
#import <BDWebImageURLFilter.h>

@class FRImageInfoModel;

extern NSString * const kUGCImageViewGifRequestOverNotification;
extern NSString * const kUGCImageViewGifDecodeOverNotification;
extern NSString * const kUGCImageViewBDGifRequestOverNotification;

extern NSString * const kUGCImageViewGifInfoModelKey;

@class TTUGCImageView;
@protocol TTUGCImageViewGifPlayDelegate <NSObject>
- (void)gifPlayOverImageView:(TTUGCImageView *)imageView;
@end

@interface TTUGCImageView : UIView

+ (UIImage *)imageFromMemoryCacheForImageModel:(FRImageInfoModel *)imageInfoModel;

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) FRImageInfoModel *largeImageModel;
@property (nonatomic, assign) BOOL enableAutoPlay;
@property (nonatomic, assign) BOOL foreverLoop;
@property (nonatomic, assign) BOOL enableNightCover;
@property (nonatomic, assign) BOOL enableGifLoadingAnimation;
@property (nonatomic, assign) CGSize preferredContentSize;
@property (nonatomic, weak) id<TTUGCImageViewGifPlayDelegate> gifDelegate;
@property (nonatomic, assign) BOOL enablefirstLoadAnimation;


- (void)willAppear;

- (void)didDisappear;

- (void)clearImage;

- (void)ugc_setImageWithModel:(FRImageInfoModel *)imageModel;

- (void)ugc_setImageWithLargeModel:(FRImageInfoModel *)largeModel
                    thumbModel:(FRImageInfoModel *)thumbModel;

- (void)ugc_setImageWithLocalPath:(NSString *)localPath;

- (void)startGifAnimation;

- (void)stopGifAnimation;

- (void)loadingGifStart;

- (void)loadingGifEnd;

@end

@interface NSURL (TTUGCSource)

@property (nonatomic, strong) NSString *ttugc_source;

@end

@interface TTUGCBDWebImageURLFilter : BDWebImageURLFilter

- (instancetype)initWithOriginFilter:(BDWebImageURLFilter *)originFilter;

@end
