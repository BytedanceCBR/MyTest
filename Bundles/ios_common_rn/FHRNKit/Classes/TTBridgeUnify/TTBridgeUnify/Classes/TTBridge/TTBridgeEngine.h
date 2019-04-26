//
//  TTBridgeEngine
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTBridgeDefines.h"

@protocol TTBridgeAuthorization;
@protocol TTBridgeEngine <NSObject>

@required

/**
 engine所在的ViewController, 提供Bridge更多的上下文. 可为空.
 */
@property (nonatomic, weak) UIViewController *sourceController;

/**
 engine当前页面地址
 */
@property (nonatomic, strong, readonly) NSURL *sourceURL;

/**
 engine挂载的对象，一般情况下是对应的view
 */
@property (nonatomic, weak, readonly) NSObject *sourceObject;

/**
 服务的端类型
 */
- (TTBridgeRegisterEngineType)engineType;

@optional
/**
 Bridge授权器, 每个业务方可自行注入. 默认为nil, 全部public权限
 */
@property (nonatomic, strong) id<TTBridgeAuthorization> authorization;

@end
