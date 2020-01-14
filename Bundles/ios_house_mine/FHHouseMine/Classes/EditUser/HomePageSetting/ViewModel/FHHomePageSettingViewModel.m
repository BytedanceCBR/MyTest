//
//  FHHomePageSettingViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHHomePageSettingViewModel.h"
#import "FHHomePageSettingCell.h"
#import "FHHomePageSettingItemModel.h"
#import "FHMineAPI.h"
#import "ToastManager.h"
#import <FHUserInfoManager.h>

@interface FHHomePageSettingViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHHomePageSettingController *viewController;

@end

@implementation FHHomePageSettingViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHHomePageSettingController *)viewController {
    self = [super init];
    if (self) {
        self.dataList = [NSMutableArray array];
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:[FHHomePageSettingCell class] forCellReuseIdentifier:@"cellId"];
        
        self.viewController = viewController;
    }
    return self;
}

- (void)loadData {
    [self.dataList removeAllObjects];
    
    NSArray *options = @[
        @{
            @"name":@"公开",
            @"auth":@0,
        },
        @{
            @"name":@"仅个人可见",
            @"auth":@1,
        }
    ];
    
    for (NSDictionary *option in options) {
        FHHomePageSettingItemModel *item = [[FHHomePageSettingItemModel alloc] init];
        item.name = option[@"name"];
        item.auth = [option[@"auth"] integerValue];
        item.isSelected = (item.auth == self.viewController.currentAuth);
        
        [self.dataList addObject:item];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHHomePageSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if(indexPath.row < self.dataList.count){
        FHHomePageSettingItemModel *model = self.dataList[indexPath.row];
        [cell refreshWithData:model];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row < self.dataList.count){
        FHHomePageSettingItemModel *model = self.dataList[indexPath.row];
        if(model.auth != self.viewController.currentAuth){
            __weak typeof(self) wself = self;
            [FHMineAPI setHomePageAuth:model.auth completion:^(BOOL success, NSError * _Nonnull error) {
                if(success && !error){
                    //更新数据
                    wself.viewController.currentAuth = model.auth;
                    [FHUserInfoManager sharedInstance].userInfo.data.fHomepageAuth = [NSString stringWithFormat:@"%i",model.auth];
                    [wself loadData];
                    
                    if(wself.viewController.delegate && [wself.viewController.delegate respondsToSelector:@selector(reloadAuthDesc:)]){
                        [wself.viewController.delegate reloadAuthDesc:model.auth];
                    }
                    
                }else{
                    [[ToastManager manager] showToast:@"个人主页设置失败"];
                }
            }];
        }
    }
}

@end


