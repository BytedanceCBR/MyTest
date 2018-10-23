//
//  TTUGCAsyncAttributedLabel.m
//  Article
//
//  Created by Jiyee Sheng on 10/11/2017.
//
//

#import "TTUGCAsyncAttributedLabel.h"
#import "TTUGCAsyncLayer.h"


@interface TTUGCAsyncAttributedLabel () <TTUGCAsyncLayerDelegate>

@end

@implementation TTUGCAsyncAttributedLabel

+ (Class)layerClass {
    return [TTUGCAsyncLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ((TTUGCAsyncLayer *) self.layer).displaysAsynchronously = YES;
        self.contentMode = UIViewContentModeRedraw;
    }

    return self;
}

- (TTUGCAsyncLayerDisplayTask *)asyncLayerDisplayTask {
    if (!self.text) {
        return nil;
    }

    TTUGCAsyncLayerDisplayTask *task = [[TTUGCAsyncLayerDisplayTask alloc] init];
    task.willDisplay = ^(CALayer *layer) {
        [layer removeAnimationForKey:@"contents"];
    };

    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        if (isCancelled()) {
            return;
        }

        if (self.attributedText.length == 0) {
            return;
        }

        CGRect rect = (CGRect) {CGPointZero, size};
        [super drawTextInRect:rect context:context];
    };

    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        if (!finished) {
            return;
        }

        [layer removeAnimationForKey:@"contents"];
    };

    return task;
}

- (void)setNeedsDisplay {
    CGImageRef image = (__bridge_retained CGImageRef) (self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            CFRelease(image);
        });
    }

    [super setNeedsDisplay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (self.disableHitTest) {
        if ([self pointInside:point withEvent:event]) {
            return self;
        }
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end
