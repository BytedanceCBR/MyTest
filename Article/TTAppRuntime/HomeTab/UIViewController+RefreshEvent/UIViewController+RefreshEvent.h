//
//  UIViewController+RefreshEvent.h
//  Article
//
//  Created by 邱鑫玥 on 16/8/30.
//
//

/***
 这个类别是为了刷新统计事件抽出的共用逻辑
 使用在TTExploreMainViewController，TTPhotoTabViewController，TTVideoTabViewController
 包含两个功能：
 1.判断刷新时当前对应的tabbar是否有提示
 2.修改上报事件时的label，加上频道名
 
 */

#import <UIKit/UIKit.h>

@class TTCategory;

@interface UIViewController (RefreshEvent)

- (NSString *)modifyEventLabelForRefreshEvent:(NSString *)label
                                categoryModel:(TTCategory *)model;

- (BOOL)isTabbarHasTip;

@end
