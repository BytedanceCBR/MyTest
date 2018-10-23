//
//  AWEVideoDetailSecondUsePromptViewController.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/8/23.
//

#import <UIKit/UIKit.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@interface AWEVideoDetailSecondUsePromptViewController : UIViewController

+ (void)showSecondSwipePromptWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager
                                     currentIndex:(NSInteger)index
                                 inViewController:(UIViewController *)containerViewController;

+ (void)dismiss;

@end
