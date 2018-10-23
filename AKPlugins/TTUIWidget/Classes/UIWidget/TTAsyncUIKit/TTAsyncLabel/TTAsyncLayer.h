//
//  TTAsyncLayer.h
//  Article
//
//  Created by zhaoqin on 11/11/2016.
//
//

#import <QuartzCore/QuartzCore.h>

@interface TTAsyncLayerDisplayTask : NSObject

@property (nonatomic, strong) void (^willDisplay)(CALayer *layer);
@property (nonatomic, strong) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));
@property (nonatomic, strong) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

@protocol TTAsyncLayerDelegate <NSObject>

@required
- (TTAsyncLayerDisplayTask *)asyncLayerDisplayTask;

@end

@interface TTAsyncLayer : CALayer
@property (nonatomic, assign) BOOL displaysAsynchronously;
@end
