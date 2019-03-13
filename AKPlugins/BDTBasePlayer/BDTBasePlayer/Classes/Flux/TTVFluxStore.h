//
//  TTVFluxStore.h
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import <Foundation/Foundation.h>
#import "TTVFluxProtocol.h"

typedef void (^TTVFluxActionChangeCallback)(TTVFluxAction *action);

@interface TTVFluxStore : NSObject

@property (nonatomic, strong, readonly) id state;

- (void)registerForActionClass:(Class)actionClass observer:(id)observer;
- (void)unregisterForActionClass:(Class)actionClass observer:(id)observer;
- (BOOL)respondToAction:(TTVFluxAction *)action;
- (void)receiveAction:(TTVFluxAction *)action;
- (void)reduceAction:(TTVFluxAction **)action; //implement by subclass
- (id)defaultState; //implement by subclass
@end
