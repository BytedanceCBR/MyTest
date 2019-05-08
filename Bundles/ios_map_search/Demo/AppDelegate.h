//
//  AppDelegate.h
//  Demo
//
//  Created by 谷春晖 on 2018/11/16.
//  Copyright © 2018年 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

