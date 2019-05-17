//
//  AKTableViewModel.h
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import <Foundation/Foundation.h>
#import "UITableView+Block.h"

/*
 *  数据源协议
 */
@protocol AKTableViewDatasourceProtocol <NSObject>

@optional
// 缓存高度
@property (nonatomic, assign) CGFloat cacheHeight;

@required
// 计算高度
- (CGFloat)caculateHeight;

@end

@interface AKTableViewModel : NSObject

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, copy, readonly) NSArray<NSArray<id<AKTableViewDatasourceProtocol>> *> *datasourceArray;
@property (nonatomic, strong, readonly) NSDictionary *extra;

//@property (nonatomic, strong, readonly) NSNumber *datasourceHashValue;

/*
 *  创建viewModel
 *  @param tableView    服务的tableView实例
 *  @param datasource   数据源。格式为二维数组,对应tableView的section-row结构
                        最内层数据实现AKTableViewDatasourceProtocol协议
 *  @param extra        额外的业务上下文参数
 */
+ (instancetype)instanceServeForTableView:(__kindof UITableView *)tableView
                           withDatasource:(NSArray<NSArray<id<AKTableViewDatasourceProtocol>> *> *)datasource
                                    extra:(NSDictionary *)extra;

/*
 *  实现tableView代理业务逻辑
 */
- (void)registerIMP;

/*
 *  刷新数据源。自动调用reload
 * @param datasource 数据源
 */
- (void)updateDatasource:(NSArray<NSArray<id<AKTableViewDatasourceProtocol>> *> *)datasource;

@end
