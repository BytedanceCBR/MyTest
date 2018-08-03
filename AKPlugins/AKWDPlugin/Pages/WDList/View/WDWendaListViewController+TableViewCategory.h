//
//  WDWendaListViewController+TableViewCategory.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDWendaListViewController.h"
#import "WDLoadMoreCell.h"
#import "SSImpressionManager.h"

@interface WDWendaListViewController(TableViewCategory)<UITableViewDataSource, UITableViewDelegate, SSImpressionProtocol, WDLoadMoreCellDelegate>

- (void)_regist;
- (void)_unregist;
- (void)_willAppear;
- (void)_willDisappear;

@end
