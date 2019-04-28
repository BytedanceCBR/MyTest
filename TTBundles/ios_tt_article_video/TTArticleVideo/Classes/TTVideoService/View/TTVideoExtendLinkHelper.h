//
//  TTVideoExtendLinkView.h
//  Article
//
//  Created by panxiang on 16/9/19.
//
//

#import "SSThemed.h"
@protocol TTVideoLinkViewDelegate <NSObject>
//old
- (void)videoLinkViewWillDisappear;
- (void)videoLinkViewWillAppear;
//new
- (void)videoLinkViewScrollIsUp:(BOOL)isUp percent:(CGFloat)percent;
- (void)videoLinkViewClickBackbutton;
- (void)videoLinkViewClickMorebutton;
- (void)videoLinkViewFullScreenTrackIsAuto:(BOOL)isAuto;
@end

@interface TTVideoLinkView : SSThemedView
@property (nonatomic ,weak)NSObject <TTVideoLinkViewDelegate> *delegate;
@property (nonatomic ,assign)CGRect halfFrame;
@property (nonatomic ,assign)CGRect fullFrame;
@property (nonatomic ,assign)BOOL hasEnterFull;
- (void)autoFull;
@end

@interface TTVideoExtendLinkHelper : NSObject
+ (UIViewController *)webControllerWithParameters:(NSDictionary *)parameters;
+ (TTVideoLinkView *)linkViewWithHalfFrame:(CGRect)halfFrame fullFrame:(CGRect)fullFrame parentViewController:(UIViewController *)parentViewController parameters:(NSDictionary *)parameters;
@end
