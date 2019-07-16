//
//  FHCommentDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHUGCBaseViewModel.h"
#import "FHCommentBaseDetailViewController.h"
#import "FHUGCBaseCell.h"
#import "TTHttpTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommentBaseDetailViewModel : FHUGCBaseViewModel

+(instancetype)createDetailViewModelWithPostType:(FHUGCPostType)postType withController:(FHCommentBaseDetailViewController *)viewController tableView:(UITableView *)tableView;
-(instancetype)initWithController:(FHCommentBaseDetailViewController *)viewController tableView:(UITableView *)tableView;
-(instancetype)initWithController:(FHCommentBaseDetailViewController *)viewController tableView:(UITableView *)tableView postType:(FHUGCPostType)postType;
@property (nonatomic, assign)   FHUGCPostType postType; // 帖子类型

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCommentBaseDetailViewController *detailController;
@property (nonatomic, strong) NSMutableArray *items;// 子类维护的数据源
@property(nonatomic , weak) TTHttpTask *httpTask;

// 子类实现
- (void)registerCellClasses;
- (Class)cellClassForEntity:(id)model;
- (NSString *)cellIdentifierForEntity:(id)model;
- (void)startLoadData;

// 刷新数据
- (void)reloadData;
- (void)refreshToolbarView;
- (void)clearCacheHeight;

@end

NS_ASSUME_NONNULL_END
