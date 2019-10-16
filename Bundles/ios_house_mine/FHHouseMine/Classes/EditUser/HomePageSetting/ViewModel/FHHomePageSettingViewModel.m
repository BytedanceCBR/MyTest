//
//  FHHomePageSettingViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHHomePageSettingViewModel.h"
#import "FHHomePageSettingCell.h"

@interface FHHomePageSettingViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHHomePageSettingController *viewController;

@end

@implementation FHHomePageSettingViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHHomePageSettingController *)viewController {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:[FHHomePageSettingCell class] forCellReuseIdentifier:@"cellId"];
        
        self.viewController = viewController;
    }
    return self;
}

- (void)initData {

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *items = self.dataList[indexPath.section];

    FHHomePageSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
//    cell.delegate = self;
//    [cell updateCell:items[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section != 0){
        return 10.0f;
    }
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if(section != 0){
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10.0f)];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//    NSArray *items = self.dataList[indexPath.section];
//    NSDictionary *dic = items[indexPath.row];
//    if(dic[@"isAuditing"] && [dic[@"isAuditing"] boolValue]){
//        //审核中不可编辑
//        return;
//    }
//    [self doOtherAction:dic[@"key"]];
}

@end


