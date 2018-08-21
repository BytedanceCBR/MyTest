//
//  TSVSlideLeftEnterProfilePromptViewController.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/11/14.
//

#import <UIKit/UIKit.h>

@interface TSVSlideLeftEnterProfilePromptViewController : UIViewController

+ (void)showSlideLeftPromotionIfNeededInViewController:(UIViewController *)containerViewController;

+ (BOOL)needSlideLeftPromotion;
+ (void)setSlideLeftPromotionShown;

+ (void)increaseVideoPlayCountForProfileSlideLeft;

@end
