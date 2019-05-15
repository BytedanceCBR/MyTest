//
//  TTVRAction.h
//  Created by panxiang on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVRReduxProtocol.h"

@interface TTVRAction : NSObject<TTVRActionProtocol>
+ (instancetype)actionWithType:(NSString *)type info:(NSDictionary *)info;
@end
