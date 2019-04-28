//
//  TTPhotoDetailContainerViewController.h
//  Article
//
//  Created by xuzichao on 16/7/7.
//
//


#import "SSViewControllerBase.h"
#import "TTDetailViewController.h"

typedef enum:NSInteger{
    
    kPhotoDetailMoveDirectionNone,           //未知
    kPhotoDetailMoveDirectionVerticalTop,    //向上
    kPhotoDetailMoveDirectionVerticalBottom  //向下
    
} TTPhotoDetailMoveDirection;


#define KPhotoDeMoveDirectionRecognizer   20

@interface TTPhotoDetailContainerViewController : SSViewControllerBase <TTDetailViewController,UIScrollViewDelegate>

- (instancetype)initWithDetailViewModel:(TTDetailModel *)model;

@end


@interface TTPhotoDetailManager : NSObject

@property (nonatomic ,assign)  BOOL  moveAnimateSwicth;

+ (instancetype)shareInstance;
- (void)setTransitionActionValid:(BOOL)valid;

+ (UIView *)addScreenShotViewBeforePushSelf:(UIViewController *)aimVC;
+ (UIView *)tabBarSnapShotFromViewController:(UIViewController *)viewController;

@end
