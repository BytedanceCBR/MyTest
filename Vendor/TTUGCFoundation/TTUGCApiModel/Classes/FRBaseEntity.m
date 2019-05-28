//
//  FRBaseEntity.m
//  Forum
//
//  Created by zhaopengwei on 15/5/10.
//
//

#import "FRBaseEntity.h"

@implementation FRBaseEntity

- (id)init
{
    self = [super init];
    if (self) {
        __entityHeightChangeFlag = 0;
    }
    return self;
}

- (void)entityHeightChanged
{
    self._entityHeightChangeFlag ++;
}

@end
