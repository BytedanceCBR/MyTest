//
//  TTRNKitBaseViewController.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/7.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRNKit.h"
#import "TTRNKitViewWrapper.h"

@interface TTRNKitBaseViewController : UIViewController<TTRNKitProtocol>
- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper;
@end
