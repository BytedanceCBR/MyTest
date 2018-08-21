//
//  AWEVideoDetailFirstUsePromptTypeBViewController.h
//  Pods
//
//  Created by Zuyang Kou on 02/08/2017.
//
//

#import <UIKit/UIKit.h>
#import "AWEVideoDetailFirstUsePromptDefine.h"

@interface AWEVideoDetailSwipePromptAnimationViewController : UIViewController<AWEVideoDetailFirstUsePromptViewController>

- (instancetype)initWithText:(NSString *)text;

@property (nonatomic, assign) AWEPromotionDiretion direction;

@end
