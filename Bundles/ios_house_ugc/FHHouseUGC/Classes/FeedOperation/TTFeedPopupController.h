//
//  TTFeedPopupController.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 弹框 content 导航器，可类比 UINavigationController
 */
@interface TTFeedPopupController : NSObject

@property (nullable, nonatomic, strong, readonly) UIView *topView;
@property (nonatomic) BOOL isArrowOnTop;

- (instancetype)initWithContainer:(UIView *)container contentView:(UIView *)contentView NS_DESIGNATED_INITIALIZER;
- (void)pushView:(UIView *)view animated:(BOOL)animated;
- (void)popViewAnimated:(BOOL)animated;

@end


@interface UIView (TTFeedPopup)
@property (nonatomic, assign) IBInspectable CGSize contentSizeInPopup;
@property (nullable, nonatomic, weak) TTFeedPopupController *popupController;
@end

NS_ASSUME_NONNULL_END

