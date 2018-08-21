//
//  AppsUIUtil.m
//  SSAppsUI
//
//  Created by Dianwei on 13-9-5.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import "AppsUIUtil.h"

@implementation AppsUIUtil
+ (UIViewController*)topViewControllerFor:(UIResponder*)responder
{
	UIResponder *topResponder = responder;
	while(topResponder &&
		  ![topResponder isKindOfClass:[UIViewController class]])
	{
		topResponder = [topResponder nextResponder];
	}
    
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
	
	return (UIViewController*)topResponder;
}
@end
