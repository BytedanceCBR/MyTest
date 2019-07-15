//
//  FRImageViewAdapter.h
//  TTUGCFoundation
//
//  Created by lipeilun on 2018/6/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BDImageView;

@interface FRImageViewAdapter : NSObject
@property (nonatomic, assign) BOOL enableAutoPlay;
@property (nonatomic, assign) BOOL foreverLoop;
@property (nonatomic, strong, readonly) BDImageView *imageView;
@property (nonatomic, strong) NSData *animatedImageData;
@property (nonatomic, copy) void(^gifLoopCompletionBlock)();

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)init NS_UNAVAILABLE;

- (void)setAnimatedImageData:(NSData *)animatedImageData completedBlock:(void (^)())completedBlock;

/*
 * completedBlock在异步线程
 */
- (void)decodeWithImageData:(NSData *)animatedImageData completedBlock:(void (^)(id image))completedBlock;

- (void)startGifAnimation;
- (void)stopGifAnimation;
@end
