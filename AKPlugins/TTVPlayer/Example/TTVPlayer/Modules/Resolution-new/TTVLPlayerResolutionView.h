//
//  TTVLPlayerResolutionView.h
//  Article
//
//  Created by 戚宽 on 2018/3/19.
//

#import <UIKit/UIKit.h>
#import "TTPlayerResolutionControlView.h"

@interface TTVLPlayerResolutionView : TTPlayerResolutionView
@property (nonatomic, strong) NSDictionary *sizeForClarityDictionary;
- (void)showContainerViewIsPortrait:(BOOL)isPortrait;

@end
