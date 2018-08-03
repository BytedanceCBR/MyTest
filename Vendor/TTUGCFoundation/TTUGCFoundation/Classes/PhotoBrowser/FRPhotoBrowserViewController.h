//
//  FRPhotoBrowserViewController.h
//  Article
//
//  Created by 王霖 on 17/1/18.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FRPhotoBrowserModel;

@interface FRPhotoBrowserViewController : UIViewController

//如果你发现随手拖动回去的时候，被挡住了，或者是加的白布不对，那就提供一个合适的画布吧。
- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models
                    startIndex:(NSUInteger)startIndex
                    targetView:(nullable UIView *)targetView;

- (instancetype)initWithModels:(NSArray <FRPhotoBrowserModel *> *)models
                    startIndex:(NSUInteger)startIndex;

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
@end

NS_ASSUME_NONNULL_END
