//
//  TTAWapNavigationBar.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/21/17.
//
//

#import <UIKit/UIKit.h>



@interface TTAWapNavigationBar : UINavigationBar
/** The color of Bottom line */
@property (nonatomic, strong) UIColor *hairlineColor;

/** The color of Bar Background */
@property (nonatomic, strong) UIColor *barBackgroundColor;

/** 是否支持透明 */
@property (nonatomic, assign) BOOL transparency;
@end



#pragma mark - UIBarButtonItem (TTABarButtonItemControl)

@interface UIBarButtonItem (TTABarButtonItemControl)

+ (UIView *)tta_barTitleViewWithTitle:(NSString *)titleString;

+ (UIBarButtonItem *)tta_backBarButtonItemWithTarget:(id)target
                                              action:(SEL)action;

+ (UIBarButtonItem *)tta_backBarButtonItemWithText:(NSString *)textString
                                        arrowImage:(BOOL)arrowImageEnabled
                                            target:(id)target
                                            action:(SEL)action;

+ (UIBarButtonItem *)tta_refreshBarButtonItemWithTarget:(id)target
                                                 action:(SEL)action;
@end



#pragma mark - UIViewController (TTAWapNavgiationBar)

@interface UIViewController (TTAWapNavgiationBar)

@property (nonatomic, strong) TTAWapNavigationBar *tta_wapNavigationBar;

@end

