//
//  FHMainManager+Toast.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHMainManager+Toast.h"
#import "FHHouseBridgeManager.h"

@implementation FHMainManager (Toast)

-(void)showToast:(NSString *)toast duration:(CGFloat)duration
{
    [self showToast:toast duration:duration inView:nil];
}

-(void)showToast:(NSString *)toast duration:(CGFloat)duration inView:(UIView *)view
{
    id<FHHouseEnvContextBridge> bridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    [bridge showToast:toast duration:duration inView:view];
}

@end
