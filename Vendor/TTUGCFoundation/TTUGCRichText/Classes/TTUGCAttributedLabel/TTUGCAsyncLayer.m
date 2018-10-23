//
//  TTUGCAsyncLayer.m
//  Article
//
//  Created by Jiyee Sheng on 05/16/2017.
//
//

#import "TTUGCAsyncLayer.h"
#import "TTUGCSentinel.h"


@implementation TTUGCAsyncLayerDisplayTask

@end

@interface TTUGCAsyncLayer ()

@property (nonatomic, strong) TTUGCSentinel *sentinel;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation TTUGCAsyncLayer

- (void)dealloc {
    [self.sentinel increase];
}

- (instancetype)init {
    self = [super init];
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    self.contentsScale = scale;
    self.contentsGravity = self.contentsAreFlipped ? kCAGravityBottomLeft : kCAGravityTopLeft;
    _sentinel = [[TTUGCSentinel alloc] init];
    _queue = dispatch_queue_create("com.bytedance.TTUGCAsyncLayer", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)setNeedsDisplay {
    if (self.displaysAsynchronously) {
        [self cancelAsyncDisplay];
    }

    [super setNeedsDisplay];
}

- (void)display {
    super.contents = super.contents;

    if (self.displaysAsynchronously) {
        [self displayAsync];
    } else {
        [self displaySync];
    }
}

- (void)displaySync {
    __strong id <TTUGCAsyncLayerDelegate> delegate = (id) self.delegate;
    TTUGCAsyncLayerDisplayTask *task = [delegate asyncLayerDisplayTask];

    if (task.willDisplay) {
        task.willDisplay(self);
    }
    if (task.display) {
        CGSize size = self.bounds.size;
        task.display(NULL, size, ^BOOL {
            return NO;
        });
    }
    if (task.didDisplay) {
        task.didDisplay(self, YES);
    }
}

- (void)displayAsync {
    __strong id <TTUGCAsyncLayerDelegate> delegate = (id) self.delegate;
    TTUGCAsyncLayerDisplayTask *task = [delegate asyncLayerDisplayTask];
    if (!task.display) {
        if (task.willDisplay) {
            task.willDisplay(self);
        }
        self.contents = nil;
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        }
        return;
    }

    if (task.willDisplay) {
        task.willDisplay(self);
    }
    TTUGCSentinel *sentinel = self.sentinel;
    int32_t value = sentinel.value;

    BOOL (^isCancelled)() = ^BOOL() {
        return value != sentinel.value;
    };
    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
    if (size.width < 1 || size.height < 1) {
        CGImageRef image = (__bridge_retained CGImageRef) (self.contents);
        self.contents = nil;
        if (image) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                CFRelease(image);
            });
        }
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        }
        CGColorRelease(backgroundColor);
        return;
    }

    dispatch_async(self.queue, ^{
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (opaque) {
            CGContextSaveGState(context);
            {
                if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
                if (backgroundColor) {
                    CGContextSetFillColorWithColor(context, backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
            }
            CGContextRestoreGState(context);
            CGColorRelease(backgroundColor);
        }
        task.display(context, size, isCancelled);
        if (isCancelled()) {
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.didDisplay) {
                    task.didDisplay(self, NO);
                }
            });
            return;
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (isCancelled()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.didDisplay) {
                    task.didDisplay(self, NO);
                }
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCancelled()) {
                if (task.didDisplay) {
                    task.didDisplay(self, NO);
                }
            } else {
                self.contents = (__bridge id) (image.CGImage);
                if (task.didDisplay) {
                    task.didDisplay(self, YES);
                }
            }
        });
    });
}

- (void)cancelAsyncDisplay {
    [self.sentinel increase];
}

@end
