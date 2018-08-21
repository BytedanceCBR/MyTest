//
//  WDWendaListViewController.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import <UIKit/UIKit.h>
#import "WDPluginBaseController.h"

/*
 * 9.18 列表页2.0UI改版需求竟然有三个AB开关：一个控制header，一个控制cell样式，一个控制用户名下边是否显示回答和阅读数量。简直丧心病狂
 * 9.27 补充一下，一共四个AB开关，除了上面三个外还有一个header底部的button样式。已经不止丧心病狂，这是要上天啊
 */

@class SSThemedTableView;
@class WDAnswerEntity;
@class WDListViewModel;
@class WDListCellDataModel;
@class WDListCellLayoutModel;

#define kWendaListQID @"qid"

@interface WDWendaListViewController : WDPluginBaseController

@property (nonatomic, strong) SSThemedTableView *answerListView;
@property (nonatomic, strong) WDListViewModel *viewModel;

// 空view
@property (nonatomic, assign) BOOL needShowEmptyView;
// 折叠view
@property (nonatomic, assign) BOOL needShowFoldView;

@property (nonatomic, assign) BOOL adjustPosition;
@property (nonatomic, assign) BOOL listViewHasScroll;

- (instancetype)initWithQuestionID:(NSString *)qID
                     baseCondition:(NSDictionary *)baseCondition
                      apiParameter:(NSDictionary *)apiParameter
                        needReturn:(BOOL)needReturn;

- (void)_loadMore;
- (void)_enterMoreListController;

- (void)locateIndexPath:(NSIndexPath *)indexPath;

- (void)addReadAnswerID:(NSString *)answerID;

- (WDListCellLayoutModel *)getCellLayoutModelFromDataModel:(WDListCellDataModel *)dataModel;

#pragma mark -- event

- (void)sendTrackWithLabel:(NSString *)label;
- (void)sendTrackWithDict:(NSDictionary *)dictInfo;

#pragma mark -- showing util

- (BOOL)_isListShowing;

@end
