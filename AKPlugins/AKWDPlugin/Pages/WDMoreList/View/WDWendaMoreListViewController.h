//
//  WDWendaMoreListViewController.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "SSViewControllerBase.h"
#import "WDMoreListViewModel.h"
#import "SSThemed.h"

@class WDListCellDataModel;
@class WDMoreListCellLayoutModel;

#define kWendaListQID @"qid"

extern NSString * const kWDWendaListMorePageSource;

@interface WDWendaMoreListViewController : SSViewControllerBase

@property(nonatomic, strong) SSThemedTableView *answerListView;
@property(nonatomic, strong) WDMoreListViewModel *viewModel;

- (void)_loadMore;

- (instancetype)initWithQuestionID:(NSString *)qID
                     baseCondition:(NSDictionary *)baseCondition
                      apiParameter:(NSDictionary *)apiParameter;

- (WDMoreListCellLayoutModel *)getCellLayoutModelFromDataModel:(WDListCellDataModel *)dataModel;

#pragma mark -- event

- (void)sendTrackWithLabel:(NSString *)label;

#pragma mark -- showing util

- (BOOL)_isListShowing;

@end
