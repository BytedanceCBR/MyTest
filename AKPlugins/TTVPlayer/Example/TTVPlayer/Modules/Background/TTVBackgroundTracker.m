//
//  TTVBackgroundTracker.m
//  Article
//
//  Created by panxiang on 2018/12/11.
//

#import "TTVBackgroundTracker.h"
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"

@implementation TTVBackgroundTracker
- (void)setStore:(TTVPlayerStore *)store
{
    if (store != _store) {
        _store = store;
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
        }];
    }
}

@end
