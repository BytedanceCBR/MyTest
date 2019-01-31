//
//  FHHouseOldDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseOldDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "FHTest1Cell.h"
#import "FHTest2Cell.h"
#import "FHTest3Cell.h"
#import "FHDetailBaseModel.h"

@implementation FHHouseOldDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHTest1Cell class] forCellReuseIdentifier:NSStringFromClass([FHTest1Cell class])];
    [self.tableView registerClass:[FHTest2Cell class] forCellReuseIdentifier:NSStringFromClass([FHTest2Cell class])];
    [self.tableView registerClass:[FHTest3Cell class] forCellReuseIdentifier:NSStringFromClass([FHTest3Cell class])];
}
// cell class
- (Class)cellClassForEntity:(id<FHDetailBaseModelProtocol>)model {
    if ([model isKindOfClass:[FHDetailTest1Model class]]) {
        return [FHTest1Cell class];
    }
    if ([model isKindOfClass:[FHDetailTest2Model class]]) {
        return [FHTest2Cell class];
    }
    if ([model isKindOfClass:[FHDetailTest3Model class]]) {
        return [FHTest3Cell class];
    }
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id<FHDetailBaseModelProtocol>)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}
// 网络数据请求
- (void)startLoadData {
    
    // test
    FHDetailTest1Model *test1 = [[FHDetailTest1Model alloc] init];
    [self.items addObject:test1];
    FHDetailTest2Model *test2 = [[FHDetailTest2Model alloc] init];
    [self.items addObject:test2];
    FHDetailTest3Model *test3 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test3];
    FHDetailTest3Model *test4 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test4];
    FHDetailTest3Model *test5 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test5];
    FHDetailTest3Model *test6 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test6];
    FHDetailTest3Model *test7 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test7];
    
    FHDetailTest3Model *test8 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test8];
    
    FHDetailTest3Model *test9 = [[FHDetailTest3Model alloc] init];
    [self.items addObject:test9];
    
    [self reloadData];
}

@end
