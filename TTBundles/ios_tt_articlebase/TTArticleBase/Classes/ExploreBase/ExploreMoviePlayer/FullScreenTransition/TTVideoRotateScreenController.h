//
//  TTVideoRotateScreenController.h
//  test_rotate
//
//  Created by xiangwu on 2016/12/18.
//  Copyright © 2016年 xiangwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TTVideoRotateCompleteBlock)();

@protocol TTVideoRotateViewProtocol <NSObject>

@property (nonatomic, weak) UITableView *baseTableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGRect rotateViewRect;
@property (nonatomic, weak) UIView *rotateSuperView;

@optional
- (void)forceStop;

@end

@interface TTVideoRotateScreenController : NSObject

@property (nonatomic, weak) UIView<TTVideoRotateViewProtocol> *rotateView;
@property (nonatomic, assign) BOOL enableRotate; // default:NO
@property (nonatomic, assign, readonly) BOOL inFullScreen;
@property (nonatomic, assign, readonly) BOOL duringAnimation;

- (instancetype)initWithRotateView:(UIView<TTVideoRotateViewProtocol> *)rotateView;
- (void)enterFullScreen:(BOOL)animated completion:(TTVideoRotateCompleteBlock)completion;
- (void)exitFullScreen:(BOOL)animated completion:(TTVideoRotateCompleteBlock)completion;
- (void)changeRotationOfLandscape;

@end
