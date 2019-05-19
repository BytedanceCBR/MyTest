//
//  TTVRReducer.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVRReducer.h"

@implementation TTVRReducer

- (void)executeWithAction:(TTVRAction *)action state:(TTVRState *)state finishBlock:(void (^)(id<TTVRStateProtocol>))finishBlock
{
    if ([action.type isEqualToString:@""]) {
        
    }else{
        
    }
    finishBlock ? finishBlock(state) : nil;
    
}

@end

