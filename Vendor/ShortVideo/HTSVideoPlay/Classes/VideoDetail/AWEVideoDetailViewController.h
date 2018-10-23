//
//  AWEVideoDetailViewController.h
//  Pods
//
//  Created by 01 on 17/5/3.
//  Copyright © 2016年 Bytedance. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SSViewControllerBase.h"
#import "TTRoute.h"
#import <SSThemed.h>

@class TTShortVideoModel;
@class AWEVideoDetailViewController;

extern NSString * const TSVVideoDetailVisibilityDidChangeNotification;
extern NSString * const TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey;
extern NSString * const TSVVideoDetailVisibilityDidChangeNotificationEntranceKey;

@interface AWEVideoDetailViewController : SSViewControllerBase <TTRouteLogicDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong, readonly) SSThemedView *commentView;

@property (nonatomic, strong, readonly) TTShortVideoModel *model;

@end
