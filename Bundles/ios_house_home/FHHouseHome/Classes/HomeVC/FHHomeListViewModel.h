//
//  FHHomeListViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import <Foundation/Foundation.h>
#import "FHHomeViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHomeListViewModel : NSObject

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC;

- (void)reloadHomeTableHeaderSection;

- (void)requestRecommendHomeList;

@end

NS_ASSUME_NONNULL_END
