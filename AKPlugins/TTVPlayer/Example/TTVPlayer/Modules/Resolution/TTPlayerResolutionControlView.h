//
//  TTPlayerResolutionControlView.h
//  Article
//
//  Created by liuty on 2017/1/10.
//
//

#import <UIKit/UIKit.h>
#import <TTVideoEngineModel.h>

@interface TTPlayerResolutionView : UIView

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) void (^didResolutionChanged)(TTVideoEngineResolutionType resolution);

- (void)setSupportedTypes:(NSArray <NSNumber *> *)supportedTypes
              currentType:(TTVideoEngineResolutionType)type;

- (NSString *)titleForResolution:(TTVideoEngineResolutionType)resolution;

- (void)showInView:(UIView *)view atTargetPoint:(CGPoint)point;
- (void)dismiss;

@end

@interface TTPlayerResolutionControlView : TTPlayerResolutionView

@end
