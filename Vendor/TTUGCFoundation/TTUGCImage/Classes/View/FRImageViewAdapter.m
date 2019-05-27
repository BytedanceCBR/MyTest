//
//  FRImageViewAdapter.m
//  TTUGCFoundation
//
//  Created by lipeilun on 2018/6/21.
//

#import "FRImageViewAdapter.h"
#import <BDWebImage/BDWebImage.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTKitchen/TTKitchen.h> 
#import <TTKitchen/TTCommonKitchenConfig.h>
#import <TTKitchen/TTKitchen.h> 
#import <TTKitchen/TTCommonKitchenConfig.h>

@interface FRImageViewAdapter(){
    dispatch_queue_t _decodeTaskQueue;
}
//@property (nonatomic, strong) FLAnimatedImageView *flImageView;
@property (nonatomic, strong) BDImageView *bdImageView;
@end

@implementation FRImageViewAdapter
@dynamic enableAutoPlay, foreverLoop;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        [self initImageViewWithFrame:frame];
        _decodeTaskQueue = dispatch_queue_create("com.bytedance.decode.task", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)initImageViewWithFrame:(CGRect)frame {
    self.bdImageView = [[BDImageView alloc] initWithFrame:frame];
    self.bdImageView.autoPlayAnimatedImage = YES;
    self.bdImageView.infinityLoop = YES;
    WeakSelf;
    self.bdImageView.loopCompletionBlock = ^{
        StrongSelf;
        if (self.bdImageView.infinityLoop) {
            return;
        }
        
        [self.bdImageView stopAnimation];
        if (self.gifLoopCompletionBlock) {
            self.gifLoopCompletionBlock();
        }
    };
}

#pragma mark - public

- (void)startGifAnimation {
    [self.bdImageView startAnimation];
}

- (void)stopGifAnimation {
    [self.bdImageView stopAnimation];
}

#pragma mark - GET/SET

- (UIImageView *)imageView {
    return self.bdImageView;
}

- (void)setEnableAutoPlay:(BOOL)enableAutoPlay {
    self.bdImageView.autoPlayAnimatedImage = enableAutoPlay;
}

- (BOOL)enableAutoPlay {
    return self.bdImageView.autoPlayAnimatedImage;
}

- (void)setForeverLoop:(BOOL)foreverLoop {
    self.bdImageView.infinityLoop = foreverLoop;
}

- (BOOL)foreverLoop {
    return self.bdImageView.infinityLoop;
}

- (void)decodeWithImageData:(NSData *)animatedImageData completedBlock:(void (^)(id image))completedBlock {
    if (!animatedImageData) {
        if (completedBlock) {
            completedBlock(nil);
        }
    }
    
    dispatch_async(_decodeTaskQueue, ^{
        BDImage *bdImage = [BDImage imageWithData:animatedImageData];
        if (completedBlock) {
            completedBlock(bdImage);
        }
    });
}

- (void)setAnimatedImageData:(NSData *)animatedImageData {
    [self setAnimatedImageData:animatedImageData completedBlock:nil];
}

- (void)setAnimatedImageData:(NSData *)animatedImageData completedBlock:(void (^)())completedBlock {
    if (!animatedImageData) {
        self.bdImageView.image = nil;
        return;
    }
    
    dispatch_async(_decodeTaskQueue, ^{
        BDImage *bdImage = [BDImage imageWithData:animatedImageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bdImageView.image = bdImage;
            if (completedBlock) {
                completedBlock();
            }
        });
    });
    
}

@end
