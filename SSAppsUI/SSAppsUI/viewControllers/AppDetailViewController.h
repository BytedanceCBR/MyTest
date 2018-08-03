//
//  AppDetailViewController.h
//  SSAppsUI
//
//  Created by Dianwei on 13-9-4.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDetailViewController : UIViewController
- (void)refreshWithAppID:(NSString*)appID name:(NSString*)name;
@end
