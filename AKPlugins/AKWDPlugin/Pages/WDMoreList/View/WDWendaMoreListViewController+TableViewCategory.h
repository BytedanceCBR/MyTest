//
//  WDWendaMoreListViewController+TableViewCategory.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "WDWendaMoreListViewController.h"
#import "WDLoadMoreCell.h"
#import "SSImpressionManager.h"

@interface WDWendaMoreListViewController(TableViewCategory)<UITableViewDataSource, UITableViewDelegate, SSImpressionProtocol, WDLoadMoreCellDelegate>

- (void)_regist;
- (void)_unregist;
- (void)_willAppear;
- (void)_willDisappear;


@end
