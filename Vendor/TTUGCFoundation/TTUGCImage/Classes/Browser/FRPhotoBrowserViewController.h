//
//  FRPhotoBrowserViewController.h
//  Article
//
//  Created by 王霖 on 17/1/18.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kFRPhotoUGCActionTag 1001
#define kFRPhotoBrowserSavePictureNotification @"kFRPhotoBrowserSavePictureNotification"
#define kFRPhotoBrowserQrcodeNotification @"kFRPhotoBrowserQrcodeNotification"

@class FRPhotoBrowserModel;

@protocol FRPhotoBrowserViewUGCDelegate <NSObject>

@optional
- (void)photoBrowserMoreAction:(id)sender qrcode:(BOOL)qrcode;
- (void)photoBrowserForwardAction:(id)sender;
- (void)photoBrowserCommentAction:(id)sender;
- (void)photoBrowserDiggAction:(id)sender;
- (NSDictionary *)photoBrowserTrackDict;

@end

@protocol FRPhotoBrowserCellTargetViewDelegate <NSObject>
@optional
- (void)photoBrowserWillDisappear;
@end

@interface FRPhotoBrowserViewUGCParams : NSObject
+ (FRPhotoBrowserViewUGCParams *)ugcParamsForwardTitle:(NSString *)sForward
                                          commentTitle:(NSString *)sComment
                                             diggTitle:(NSString *)sDigg
                                             hasDigged:(BOOL)digged
                                              showSave:(BOOL)showSave
                                              delegate:(id<FRPhotoBrowserViewUGCDelegate>)delegate;
+ (FRPhotoBrowserViewUGCParams *)ugcParamsForwardTitle:(NSString *)sForward
                                          commentTitle:(NSString *)sComment
                                             diggTitle:(NSString *)sDigg
                                           diggIconKey:(NSString *)diggIconKey
                                             hasDigged:(BOOL)digged
                                              showSave:(BOOL)showSave
                                              delegate:(nonnull id<FRPhotoBrowserViewUGCDelegate>)delegate;
@end

@interface FRPhotoBrowserViewController : UIViewController

- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models
                    startIndex:(NSUInteger)startIndex;

//如果你发现随手拖动回去的时候，被挡住了，或者是加的白布不对，那就提供一个合适的画布吧。
- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models
                    startIndex:(NSUInteger)startIndex
                    targetView:(nullable UIView *)targetView;

- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models
                    startIndex:(NSUInteger)startIndex
                    targetView:(nullable UIView *)targetView
                     ugcParams:(nullable FRPhotoBrowserViewUGCParams *)uParams;

//当前浏览图片的index发生变化时候，图片浏览器内部会调用
@property (nonatomic, copy, nullable) void (^indexUpdatedBlock)(NSInteger lastIndex, NSInteger currentIndex);
//当图片浏览器dismiss的时候，会调用
@property (nonatomic, copy, nullable) void (^willDismissBlock)(NSInteger currentIndex);

//更新index处图片的占位图
- (void)updatePlaceholderImage:(UIImage *)placeholderImage atIndex:(NSUInteger)index;
//更新index处图片的原始位置
- (void)updateOriginFrame:(NSValue *)originalFrame atIndex:(NSUInteger)index;

- (void)showPhotoBrowserInViewController:(nullable UIViewController *)viewController;

//是否正在展示图片选择器
+ (BOOL)photoBrowserAtTop;

/*
 * 如果正在展示图片选择器，则dismiss
 */
+ (void)dismissPhotoBrowserAnimated:(BOOL)animated;

/*
 * @param : animated，是否动画
 */
- (void)dismissAnimated:(BOOL)animated;


@end

NS_ASSUME_NONNULL_END
