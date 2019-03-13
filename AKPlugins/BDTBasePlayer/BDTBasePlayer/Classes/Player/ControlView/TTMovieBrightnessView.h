//
//  TTMovieBrightnessView.h
//  Article
//
//  Created by songxiangwu on 2016/9/22.
//
//

#import <UIKit/UIKit.h>

@interface TTMovieBrightnessView : UIView
@property (nonatomic ,assign)BOOL isFullScreen;
@property (nonatomic ,assign)BOOL enableRotate;
- (BOOL)isIOS7IPad;
- (CGAffineTransform)currentTransformInIOS7IPad;
- (CGPoint)currentCenterInIOS7IPad;

@end
