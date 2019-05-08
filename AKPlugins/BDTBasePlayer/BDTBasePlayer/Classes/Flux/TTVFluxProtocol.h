//
//  TTVFluxProtocol.h
//  Pods
//
//  Created by xiangwu on 2017/3/5.
//
//

#import <Foundation/Foundation.h>
@class TTVFluxAction;

@protocol TTVFluxStoreCallbackProtocol <NSObject>

- (void)actionChangeCallbackWithAction:(TTVFluxAction *)action state:(id)state;

@end
