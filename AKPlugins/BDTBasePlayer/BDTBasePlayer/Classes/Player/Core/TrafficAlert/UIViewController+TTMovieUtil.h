//
//  UIViewController+TTMovieUtil.h
//  Article
//
//  Created by songxiangwu on 2016/10/31.
//
//

#import <UIKit/UIKit.h>

extern NSString *ttv_getFormattedTimeStrOfPlay(NSTimeInterval playTimeInterval);

@interface UIViewController (TTMovieUtil)

+ (UIViewController*) ttmu_currentViewController;

@end
