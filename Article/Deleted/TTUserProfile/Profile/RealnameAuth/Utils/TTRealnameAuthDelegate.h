//
//  TTRealnameAuthDelegate.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <Foundation/Foundation.h>

@protocol RealnameAuthViewDelegate <NSObject>

@required
- (void)setupViewsWithModel:(TTRealnameAuthModel *)model;
- (void)updateViewsWithModel:(TTRealnameAuthModel *)model;

@end

@protocol AuthButtonTouchDelegate <NSObject>

@required
- (void)startButtonTouched:(UIButton *)sender;
@optional
- (void)retakeButtonTouched:(UIButton *)sender;

@end

@protocol CameraButtonTouchDelegate <NSObject>

@required
- (void)captureButtonTouched:(UIButton *)sender;
- (void)dismissButtonTouched:(UIButton *)sender;
@optional
- (void)flashButtonTouched:(UIButton *)sender;
- (void)flipButtonTouched:(UIButton *)sender;

@end
