//
//  TTPanorama3DView.h
//  Pods
//
//  Created by rongyingjie on 2017/11/7.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/**
 * @class Panorama View
 * @author Robby Kraft
 * @date 8/24/13
 *
 * @availability iOS (5.0 and later)
 *
 * @discussion a dynamic GLKView with a touch and motion sensor interface to align and immerse the perspective inside an equirectangular panorama projection
 */
@interface TTPanorama3DView : GLKView

-(void) draw;  // place in GLKViewController's glkView:drawInRect:

/// set image
-(void) setImage:(UIImage*)image;

/// set image by path or bundle - will check at both
-(void) setImageWithName:(NSString*)fileName;

- (void)willDisplaying;
- (void)didEndDisplaying;
- (void)resumeDisplay;

@property (nonatomic, strong) CADisplayLink* displayLink;

//    由于加载图片比较耗时，缓存一下加载的图片，和sd中加载的图片比较一下
@property (nonatomic, readonly, strong) UIImage *image;

@property (nonatomic, weak) UITableView *tableView;

// At this point, it's still recommended to activate either OrientToDevice or TouchToPan, not both
//   it's possible to have them simultaneously, but the effect is confusing and disorienting


/// Activates accelerometer + gyro orientation
@property (nonatomic) BOOL orientToDevice;

/// Enables UIPanGestureRecognizer to affect view orientation
@property (nonatomic) BOOL touchToPan;

/// Fixes up-vector during panning. (trade off: no panning past the poles)
@property (nonatomic) BOOL preventHeadTilt;

@property (nonatomic, assign) BOOL isShowGyroTipView;

/*  projection & touches  */

/// Set of (UITouch*) touches currently active
@property (nonatomic, readonly) NSSet *touches;

/// The number of active screen touches
@property (nonatomic, readonly) NSInteger numberOfTouches;

/// Field of view in DEGREES
@property (nonatomic) float fieldOfView;

/// Enables UIPinchGestureRecognizer to affect FieldOfView
@property (nonatomic) BOOL pinchToZoom;

/**
 * Hit-detection for all active touches
 *
 * @param CGRect defined in image pixel coordinates
 * @return YES if touch is inside CGRect, NO otherwise
 */
-(BOOL) touchInRect:(CGRect)rect;

@end

