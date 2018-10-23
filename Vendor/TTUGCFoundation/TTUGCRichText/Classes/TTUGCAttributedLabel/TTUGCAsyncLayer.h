//
//  TTUGCAsyncLayer.h
//  Article
//
//  Created by Jiyee Sheng on 05/16/2017.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface TTUGCAsyncLayerDisplayTask : NSObject

@property (nonatomic, strong) void (^willDisplay)(CALayer *layer);
@property (nonatomic, strong) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));
@property (nonatomic, strong) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

@protocol TTUGCAsyncLayerDelegate <CALayerDelegate>

@required
- (TTUGCAsyncLayerDisplayTask *)asyncLayerDisplayTask;

@end

@interface TTUGCAsyncLayer : CALayer

@property (nonatomic, assign) BOOL displaysAsynchronously;

@end
