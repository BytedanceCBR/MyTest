//
//  TTImagePreviewViewController.h
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import "TTAssetModel.h"
#import "TTImagePickerLoadingView.h"

@class TTImagePreviewViewController;

@protocol TTImagePreviewViewControllerDelegate <NSObject>

@optional

///下拉拖动关闭会调用背景渐变消失，或者点击关闭按钮会整个view消失
/// index 对应totalModel index。
- (void)ttImagePreviewViewControllerDidDismiss:(TTImagePreviewViewController *)controller;- (void)ttImagePreviewViewControllerSelectChange:(TTImagePreviewViewController *)controller index:(NSInteger)index;

/// 每次修改选择内容的回调
- (void)ttImagePreviewViewControllerScrollChange:(TTImagePreviewViewController *)controller index:(NSInteger)index;
/// 点击完成时回调
- (void)ttImagePreviewViewControllerSelectDidFinish:(TTImagePreviewViewController *)controller;

@end

@interface TTImagePreviewViewController : UIViewController

@property (nonatomic, copy, readonly) NSArray<TTAssetModel*> *allModels;
@property (nonatomic, strong, readonly) NSMutableArray<TTAssetModel*> *selectModels;  // 已经选择的图片，可以初始化，初始化后不受外部控制
@property (nonatomic, assign, readonly) NSUInteger currentIndex;  // 当前选择的照片，可以初始化，初始化后不受外部控制
@property (nonatomic, weak) id<TTImagePreviewViewControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger maxLimit; //最大选择数，默认最多为9张；小于1当1处理，大于传入的models count；以model count处理。 当为1张时，样式会不一样。

@property (nonatomic, strong, readonly) UIView* animatedImageView;

/// 用于点击扩散开的动画，如果不给值，则默认弹起动画。
@property (nonatomic, weak) UIImageView *tapView;
/// 是否自动根据present时刻的statusBar的隐藏状态来恢复隐藏状态，默认为YES
@property (nonatomic, assign, getter=isStatusBarAutoHidden) BOOL statusBarAutoHidden;
/// 当isStatusBarAutoHidden=NO时，可以设置在dismiss时应当恢复的导航栏隐藏状态，
@property (nonatomic, assign) BOOL lastHidden;

/// icloud进度条
@property (nonatomic,strong)TTImagePickerLoadingView *loadingView;
/// icloud任务未完成，是否能点击完成
@property (nonatomic,assign)BOOL canComplete;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * 发布器使用，返回样式只有上工具条，其中右侧为删除按钮
 *
 * @param: models   所有现在已经选择的资源，TTAssetModel中的localFilePath不能为空，避免上传时期用户进入相册中删除
 * @param: index    当前用户点击的图片索引
 */
+ (instancetype) deletePreviewViewControllerWithModes:(NSArray<TTAssetModel*>*)models
                                                index:(NSInteger)index
                                             delegate:(id<TTImagePreviewViewControllerDelegate>) delegate;

/**
 * 图片选择器使用，上工具条为返回和选中，下工具条为原图和完成
 *
 * @param: models   所有需要展示的数据
 * @param: selectModels 当前已经选中的数据
 * @param: index 用户点击的索引
 * @param: original 用户当前选中的资源是否为原图
 */
+ (instancetype) selectPreviewViewControllerWithModes:(NSArray<TTAssetModel*>*) models
                                              selects:(NSMutableArray<TTAssetModel*>*) selectModels
                                                index:(NSInteger) index
                                             delegate:(id<TTImagePreviewViewControllerDelegate>) delegate;


/// 单个视频预览
+ (instancetype) selectPreviewViewControllerWithVideo:(TTAssetModel *)model
                                             delegate:(id<TTImagePreviewViewControllerDelegate>) delegate;


/// 弹出预览控制器
- (void)presentOn:(UIViewController *)parentViewController;
/// 消失预览控制器，isGestureAnimate：用来指定是否手势缩小返回
- (void)dismiss:(BOOL)animated  isGestureAnimate:(BOOL)isGestureAnimate;
@end
