//
//  TTFollowWebViewController.h
//  Article
//
//  Created by 王双华 on 16/5/4.
//
//

#import "SSViewControllerBase.h"

@interface TTFollowWebViewController : SSViewControllerBase

+ (void)setCanShowFollowTip:(BOOL)canShow;
+ (BOOL)canShowFollowTip;

+ (void)setCanPreload:(BOOL)canPreload;
+ (BOOL)canPreload;
@end
