//
//  TTMovieStore.m
//  Article
//
//  Created by panxiang on 2017/5/3.
//
//

#import "TTMovieStore.h"

@interface TTMovieStore()
@property (nonatomic,strong) NSHashTable *registMovieViewHash;
@property (nonatomic,weak) UIView <TTMovieStoreAction> *toResumeMovie;
@end

@implementation TTMovieStore
+ (instancetype)shareTTMovieStore
{
    static TTMovieStore *_share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[TTMovieStore alloc] init];
    });
    return _share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registMovieViewHash = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}

- (void)addMovie:(UIView <TTMovieStoreAction> *)movieView
{
    if (![_registMovieViewHash containsObject:movieView]) {
        [_registMovieViewHash addObject:movieView];
    }
}

- (void)removeAll
{
    for (UIView <TTMovieStoreAction> *movie in _registMovieViewHash) {
        if ([movie respondsToSelector:@selector(stop)]) {
            [movie stop];
        }
        [movie removeFromSuperview];
    }
}

- (void)removeExcept:(UIView <TTMovieStoreAction> *)movieView
{
    for (UIView <TTMovieStoreAction> *movie in _registMovieViewHash) {
        if (movie == movieView) {
            continue;
        }
        if ([movie respondsToSelector:@selector(stop)]) {
            [movie stop];
        }
        [movie removeFromSuperview];
    }
}
@end
