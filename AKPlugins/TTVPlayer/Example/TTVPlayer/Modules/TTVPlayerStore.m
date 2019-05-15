//
//  TTVPlayerStore.m
//  Article
//
//  Created by panxiang on 2018/7/22.
//

#import "TTVPlayerStore.h"
#import "TTVPlayerState.h"

@implementation TTVPlayerStore
@dynamic state;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = [[TTVPlayerState alloc] init];
    }
    return self;
}
@end


