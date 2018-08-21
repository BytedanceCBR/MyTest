//
//  TTImagePickerController.h
//  TestPhotos
//
//  Created by tyh on 2017/4/7.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTImagePickerManager.h"
#import "TTImagePickerDefineHead.h"


@protocol TTImagePickerControllerDelegate,CustomAlmumNavProtocol;

/// 图片选择器列表类
@interface TTImagePickerController : UIViewController

/// 用这个初始化方法
- (instancetype)initWithDelegate:(id<TTImagePickerControllerDelegate>)delegate;

/// 调用弹出图片选择器
- (void)presentOn:(UIViewController *)parentViewController;

/// 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;
/// 默认为TTImagePickerModePhoto
@property (nonatomic, assign) TTImagePickerMode imagePickerMode;

/// 默认为YES，如果设置为NO，拍照按钮将隐藏，用户将不能拍照
@property (nonatomic, assign) BOOL allowTakePicture;
/// 默认为YES，如果设置为NO，拍照后不自动将照片存到相册胶卷中
@property (nonatomic, assign) BOOL allowAutoSavePicture;

/// 当前已选中的数量，只读
@property (nonatomic, assign, readonly) NSUInteger selectedCount;

/// 默认为4，每一行的图片数
@property (nonatomic, assign) NSInteger columnNumber;


/// 影响- (void)imagePickerController:didFinishPickingPhotos:sourceAssets:代理方法
/// 是否需要回调带上Photos（UIImage数组），默认为YES，则会有从asset -> image的请求的延迟。 (图片越大，延迟越久,现在有做缓存，但是有可能选择完成的太快，缓存还没完成，则会造成延迟，)
/// 如果不想要延迟，可以设置此值为NO，则Photos数组返回为空，然后自行处理assets。
@property (nonatomic, assign) BOOL isRequestPhotosBack;

/// 提供导航栏定制，如果没有则用默认的UI样式
@property (nonatomic, strong) UIView<TTImagePickerNavProtocol>* customAlmumNav;

- (void)showPromptViewAtBottomViewTop:(UIView *)promptView;


@end

@protocol TTImagePickerControllerDelegate <NSObject>
@optional

/// 以下如果系统版本大于iOS8，assets数据中是PHAsset类的对象，否则是ALAsset类的对象，详见：TTAssetModel

/// 照片选择完成之后的回调
/// photos数组里的UIImage对象，默认是屏幕宽 * 2,如果isRequestPhotosBack为NO,则为nil，仅仅在 TTImagePickerModePhoto 下回调
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets;

/// 如果用户选择了一个视频，下面的handle会被执行 仅仅在 TTImagePickerModeVideo 下回调
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAsset:(TTAssetModel *)assetModel;

/// 仅仅在 TTImagePickerModeAll 下回调
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickerPhotosAndVideoWithSourceAssets:(NSArray<TTAssetModel *> *)assets;

/// 用户拍照完成之后的回调，如果拍照的同时有选择照片，则assets不为空
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info;

/// 选择器取消选择的回调
- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker;




@end


