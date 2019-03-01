//
//  TTVFluxDispatcher.h
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import <Foundation/Foundation.h>
#import "TTVFluxStore.h"
@class TTVFluxAction;
@interface TTVFluxDispatcher : NSObject
- (void)dispatchAction:(TTVFluxAction *)action;
- (void)registerStore:(TTVFluxStore *)store;
@end
