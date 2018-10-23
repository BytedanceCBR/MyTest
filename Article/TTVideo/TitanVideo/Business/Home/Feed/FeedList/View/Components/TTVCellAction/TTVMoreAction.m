//
//  TTVMoreAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"

@implementation TTVMoreActionEntity

@end

@implementation TTVMoreAction
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super init];
    if (self) {
        self.entity = entity;
    }
    return self;
}

- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }
}
@end
