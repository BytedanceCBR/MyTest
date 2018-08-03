//
//  TTImageCropperViewController.h
//  Article
//
//  Created by tyh on 2017/6/6.
//
//


#import <UIKit/UIKit.h>

@class TTImageCropperViewController;

@protocol TTImageCropperDelegate <NSObject>

- (void)imageCropper:(TTImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(TTImageCropperViewController *)cropperViewController;

@end

@interface TTImageCropperViewController : UIViewController
@property (nonatomic, assign) id<TTImageCropperDelegate> delegate;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
