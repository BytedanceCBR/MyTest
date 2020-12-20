//
//  FHFlutterViewController.h
//  ABRInterface
//
//  Created by 谢飞 on 2020/8/25.
//

#import <UIKit/UIKit.h>
#import "FlutterViewWrapperController.h"
#import <TTRoute/TTRoute.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFlutterViewController : FlutterViewWrapperController<TTRouteInitializeProtocol>

@end

NS_ASSUME_NONNULL_END
