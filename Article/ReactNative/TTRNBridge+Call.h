//
//  TTRNBridge+Call.h
//  Article
//
//  Created by Chen Hong on 16/8/17.
//
//

#import "TTRNBridge.h"

typedef void (^TTRNMethod)(NSDictionary *result, RCTResponseSenderBlock callback);

@interface TTRNBridge (Call)

- (void)registerHandler:(TTRNMethod)handler forMethod:(NSString *)method;

- (void)unregisterAllHandlers;

@end

@interface TTRNBridge ()
@property(nonatomic, strong)NSMutableDictionary<NSString *, TTRNMethod> * methodHandlers;
@end
