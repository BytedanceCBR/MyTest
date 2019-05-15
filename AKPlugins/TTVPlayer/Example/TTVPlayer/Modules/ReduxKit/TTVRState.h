//
//  TTVRState.h
//  Created by panxiang on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVRReduxProtocol.h"

@interface TTVRState : NSObject<TTVRStateProtocol>
@property (nonatomic ,strong ,readonly)NSMutableDictionary *states;
- (void)setState:(id)state forKey:(Class <NSObject>)classKey;
- (id)stateForKey:(Class <NSObject>)classKey;
@end
