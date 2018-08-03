//
//  TTLiveCameraViewController.h
//  Article
//
//  Created by matrixzk on 7/27/16.
//
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSUInteger, TTCameraType)
//{
//    TTCameraPhotoOnly = 0, //只拍照
//    TTCameraVideoOnly = 1, //只录视频
//    TTCameraVideoPhoto     //录视频和拍照
//};

typedef NS_ENUM(NSUInteger, TTLiveCameraType)
{
    TTLiveCameraTypePhoto = 0,      //只拍照
    TTLiveCameraTypeVideo,          //只录视频
    TTLiveCameraTypeVideoAndPhoto   //录视频和拍照
};

@class TTLiveCameraViewController;

@protocol TTLiveCameraVCDelegate <NSObject>
@optional

//拍照成功返回
- (void)ttCameraPhotoBackAssetUrl:(NSURL *)url image:(UIImage *)cameraImage;

//视频成功返回文件URL以及视频预览图片
- (void)ttCameraVideoBack:(NSURL *)videoUrl previewImage:(UIImage *)previewImage;

- (void)ttCameraViewControllerDidCanceled:(TTLiveCameraViewController *)cameraViewController;

@end

@interface TTLiveCameraViewController : UIViewController

@property (nonatomic, weak) id<TTLiveCameraVCDelegate> delegate;

//根据类型进行初始化
- (instancetype)initWithCamreraType:(TTLiveCameraType)cameraType beautyModeEnable:(BOOL)beautyEnable preSelfieEnable:(BOOL)preSelfieEnable;

//统计
- (void)setSsTrackerDic:(NSDictionary *)ssTrackerDic;

@end