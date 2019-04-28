//
//  TTCertificationTakePhotoViewController.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTRealnameAuthCardCameraViewController.h"

@interface TTCertificationTakePhotoViewController : TTRealnameAuthCardCameraViewController

@property (nonatomic, copy) void (^didFinishBlock)(UIImage *image);
@property (nonatomic, assign) BOOL needEdging;

@end
