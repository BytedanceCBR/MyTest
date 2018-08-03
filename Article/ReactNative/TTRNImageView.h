//
//  TTRNImageView.h
//  Article
//
//  Created by Chen Hong on 2016/10/25.
//
//

#import "RCTView.h"
#import "RCTResizeMode.h"

@interface TTRNImageView : UIView

@property (nonatomic, copy) NSDictionary *source;

//- (instancetype)initWithBridge:(RCTBridge *)bridge NS_DESIGNATED_INITIALIZER;

//@property (nonatomic, assign) UIEdgeInsets capInsets;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, assign) UIImageRenderingMode renderingMode;
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) RCTResizeMode resizeMode;

@end
