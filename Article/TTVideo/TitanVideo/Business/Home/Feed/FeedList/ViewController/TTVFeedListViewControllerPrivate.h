//
//  TTVFeedListViewControllerPrivate.h
//  Article
//
//  Created by panxiang on 2017/4/1.
//
//

#import <Foundation/Foundation.h>
#import "TTSubEntranceBar.h"
#import "TTVFeedListViewController.h"
@interface TTVFeedListViewController()
@property(nonatomic, retain)TTSubEntranceBar *subEntranceBar;
// 处理松手后bar自动显示/隐藏
@property(nonatomic, assign)BOOL isHeaderViewBarVisible;
@end
