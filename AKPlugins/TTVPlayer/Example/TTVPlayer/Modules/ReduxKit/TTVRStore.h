//
//  TTVRStore.h
//  Created by panxiang on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVRState.h"
#import "TTVRAction.h"
#import "TTVRReducer.h"
#import "TTVRReduxProtocol.h"

@interface TTVRStore : NSObject<TTVRStoreProtocol>
@property (nonatomic,strong) id<TTVRStateProtocol> state;

- (NSString *)subscribe:(TTVSubscription)subscription;

@end
