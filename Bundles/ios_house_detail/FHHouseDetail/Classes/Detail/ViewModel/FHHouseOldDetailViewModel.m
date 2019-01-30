//
//  FHHouseOldDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseOldDetailViewModel.h"
#import "FHDetailBaseCell.h"

@implementation FHHouseOldDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    // sub implements.........
    [self.tableView registerClass:[FHDetailBaseCell class] forCellReuseIdentifier:@"FHDetailBaseCell"];
}
// cell class
- (Class)cellClassForEntity:(id<FHDetailBaseModel>)model {
    // sub implements.........
    // Donothing
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id<FHDetailBaseModel>)model {
    // sub implements.........
    // Donothing
    return @"FHDetailBaseCell";
}
// 网络数据请求
//- (void)startLoadData {
//}

@end
