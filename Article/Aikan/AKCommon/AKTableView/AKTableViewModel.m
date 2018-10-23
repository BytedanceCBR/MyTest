//
//  AKTableViewModel.m
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "AKTableViewModel.h"

@interface AKTableViewModel ()

@property (nonatomic, weak, readwrite) UITableView *tableView;
@property (nonatomic, copy, readwrite) NSArray<NSArray<id<AKTableViewDatasourceProtocol>> *> *datasourceArray;
@property (nonatomic, strong, readwrite) NSDictionary *extra;

//@property (nonatomic, strong, readwrite) NSNumber *datasourceHashValue;

@end

@implementation AKTableViewModel

- (void)dealloc
{
    LOGD(@"-----[AKTableViewModel] instance deallocated-----");
}

+ (instancetype)instanceServeForTableView:(__kindof UITableView *)tableView
                           withDatasource:(NSArray<NSArray<id<AKTableViewDatasourceProtocol>> *> *)datasource
                                    extra:(NSDictionary *)extra
{
    Class factoryClass = self.class;
    AKTableViewModel *model = [[factoryClass alloc] init];
    model.datasourceArray = datasource;
    model.tableView = tableView;
    model.extra = extra;
    
//    model.datasourceHashValue = @([model _hashValue]);
    
    return model;
}

- (void)registerIMP
{
    // 基类的默认实现
    self.tableView.numberOfSectionsBlock = ^NSInteger(UITableView *tableView) {
        return self.datasourceArray.count;
    };
    self.tableView.numberOfRowsBlock = ^NSInteger(UITableView *tableView, NSInteger section) {
        return [self.datasourceArray objectAtIndex:section].count;
    };
    self.tableView.heightForRowBlock = ^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        id<AKTableViewDatasourceProtocol> cellData = [[self.datasourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (cellData.cacheHeight) {
            return cellData.cacheHeight;
        } else {
            CGFloat cacHeight = [cellData caculateHeight];
            return cacHeight ? : 44.f;
        }
    };
    
    /*  subClass override...
     
    [self.tableView registerCellClass:nil];
     
    self.tableView.cellForRowBlock = ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        return [UITableViewCell new];
    };
     
    self.tableView.didSelectBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
        // todo
    };
    */
}

- (void)updateDatasource:(NSArray<NSArray<id<AKTableViewDatasourceProtocol>> *> *)datasource
{
    self.datasourceArray = datasource;
}

//- (NSUInteger)_hashValue
//{
//    NSUInteger hash = 0;
//    if (self.datasourceArray.count) {
//        for (NSArray * subArr in self.datasourceArray) {
//            for (NSObject *obj in subArr) {
//                hash += obj.hash;
//            }
//        }
//    }
//    return hash;
//}

@end
