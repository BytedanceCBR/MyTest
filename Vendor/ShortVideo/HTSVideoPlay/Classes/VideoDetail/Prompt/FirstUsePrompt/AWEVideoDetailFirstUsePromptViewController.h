//
//  AWEVideoDetailFirstUsePromotionViewController.h
//  Pods
//
//  Created by Zuyang Kou on 30/06/2017.
//
//

#import <UIKit/UIKit.h>
#import "AWEVideoDetailFirstUsePromptDefine.h"

@interface AWEVideoDetailFirstUsePromptViewController : UIViewController

+ (void)showPromotionIfNeededWithDirection:(AWEPromotionDiretion)direction
                                  category:(AWEPromotionCategory)category
                  inViewController:(UIViewController *)containerViewController;

+ (BOOL)hasShownFirstLeftPromotion;

@end
