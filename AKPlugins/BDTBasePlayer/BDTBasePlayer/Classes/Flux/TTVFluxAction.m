//
//  TTVFluxAction.m
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import "TTVFluxAction.h"

@interface TTVFluxAction ()

@end

@implementation TTVFluxAction

- (instancetype)initWithActionType:(NSInteger)actionType payload:(id)payload {
    self = [super init];
    if (self) {
        _actionType = actionType;
        _payload = payload;
    }
    return self;
}

@end
