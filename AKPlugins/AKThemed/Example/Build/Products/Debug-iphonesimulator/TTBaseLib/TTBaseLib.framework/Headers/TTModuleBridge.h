//
//  ModuleBridge.h
//  TestModally
//
//  Created by yuxin on 1/14/16.
//  Copyright © 2016 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

// 临时兼容火山，新业务禁用，后续用TTMessageCenter代替
DEPRECATED_ATTRIBUTE

typedef _Nullable id (^TTActionBlock)(_Nullable id object, _Nullable id params);
typedef void (^TTListenerBlock)(_Nullable id params);
typedef void (^TTCompleteBlock)(_Nullable id result);

@interface TTModuleBridge : NSObject

+ (instancetype)sharedInstance_tt;

//主动调用
- (void)registerAction:(nonnull NSString*)actName withBlock:(nonnull TTActionBlock)block;

- (void)removeAction:(nonnull NSString*)actName;

- (void)triggerAction:(nonnull NSString*)actName object:(nullable id)object withParams:(nullable id)params complete:(nullable TTCompleteBlock)complete;


//被动回调
- (void)registerListener:(nonnull id)listener object:(nullable id)observedObj forKey:(nonnull NSString*)keyName withBlock:(nonnull TTListenerBlock)block;
//dealloc 里需要remove
- (void)removeListener:(nonnull id)listener forKey:(nonnull NSString*)keyName;

- (void)notifyListenerForKey:(nonnull NSString*)keyName object:(nonnull id)observedObj withParams:(nullable id)params complete:(nullable TTCompleteBlock)complete;

@end


/* Usage
 Register Action
    [[ModuleBridge sharedInstance_tt] registerAction:@"GetSecondVCStatus" withBlock:^id(id param) {
        NSLog(@"param %@",param);
        return @(self.status);
    }];
Trigger Action
     [[ModuleBridge sharedInstance_tt] triggerAction:@"GetSecondVCStatus" withParams:nil complete:^void(id result) {
     
     NSLog(@"%@",result);
     }];

 
Register Listener
 [[TTModuleBridge sharedInstance_tt] registerListener:self forKey:@"MIXBASEscrollViewDidScroll" withBlock:^(id params) {
    NSLog(@"%f",[(UIScrollView*)params contentOffset].y);
 }];
 
Nofity Listener
 [[TTModuleBridge sharedInstance_tt] notifyListenerForKey:@"MIXBASEscrollViewDidScroll" object:self withParams:scrollView complete:^(id result) {
 NSLog(@"END");
 }];
*/
