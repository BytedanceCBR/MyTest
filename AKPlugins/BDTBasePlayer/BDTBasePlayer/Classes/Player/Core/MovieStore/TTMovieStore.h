//
//  TTMovieStore.h
//  Article
//
//  Created by panxiang on 2017/5/3.
//
//

#import <Foundation/Foundation.h>

@protocol TTMovieStoreAction <NSObject>
@required
- (void)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL finished))completion;
- (void)stop;
@end

@interface TTMovieStore : NSObject
+ (instancetype)shareTTMovieStore;
- (void)addMovie:(UIView <TTMovieStoreAction> *)movieView;
- (void)removeAll;
- (void)removeExcept:(UIView <TTMovieStoreAction> *)movieView;
@end
