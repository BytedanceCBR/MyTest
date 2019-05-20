//
//  FHEditUserViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import "FHEditUserViewModel.h"
#import <TTHttpTask.h>
#import <TTRoute.h>

@interface FHEditUserViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHEditUserController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;

@end

@implementation FHEditUserViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHEditUserController *)viewController
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
    
        self.tableView = tableView;
        
//        tableView.delegate = self;
//        tableView.dataSource = self;
        
        self.viewController = viewController;
        
        [self initData];
    }
    return self;
}

- (void)initData {
    
}

@end
