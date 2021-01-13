//
//  FHFloorPanListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHFloorPanListCell.h"
#import "FHEnvContext.h"
#import "FHHouseDetailSubPageViewController.h"
#import <FHDetailNewModel.h>

@interface FHFloorPanListDetailViewModel () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,weak) UITableView *tableView;
@property(nonatomic,weak) NSArray *itemArray;
@property(nonatomic,weak) NSDictionary *subPageParams;
@property (nonatomic,weak) NSMutableDictionary *elementShowCache;
@end


@implementation FHFloorPanListDetailViewModel

- (instancetype)initWithTableView:(UITableView *)tableView itemArray:(NSArray *)itemArray subPageParams:(NSDictionary *)subPageParams elementShowCache:(NSMutableDictionary *)elementShowCache {
    if(self = [super init]) {
        self.tableView = tableView;
        self.itemArray = itemArray;
        self.subPageParams = subPageParams;
        self.elementShowCache = elementShowCache;
        [self processDataToShow];
    }
    return self;
}

- (void)processDataToShow {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self registerCellClasses];
    
    if (self.itemArray.count == 0) {
        [[ToastManager manager] showToast:@"暂无相关房型~"];
    }
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0, -20);
}

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHFloorPanListCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanListCell class])];
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;
    FHFloorPanListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHFloorPanListCell class])];
    BOOL isFirst = (index == 0);
    BOOL isLast = (index == self.itemArray.count - 1);
    
    if (!cell) {
        cell = (FHFloorPanListCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([FHFloorPanListCell class])];
    }
    
    if ([cell isKindOfClass:[FHFloorPanListCell class]] && self.itemArray.count > index) {
        [cell refreshWithData:[self.itemArray objectAtIndex:index]];
        [cell refreshWithData:isFirst andLast:isLast];
    }
    cell.backgroundColor = [UIColor themeGray7];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if(index >= 0 && index < self.itemArray.count) {
        FHDetailNewDataFloorpanListListModel *model = [self.itemArray objectAtIndex:index];
        if ([model isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            
            NSMutableDictionary *subPageParams = [self.subPageParams mutableCopy];
            subPageParams[@"contact_phone"] = nil;
            NSDictionary *tracer = subPageParams[@"tracer"];
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
            if (tracer) {
                [traceParam addEntriesFromDictionary:tracer];
            }
            traceParam[@"enter_from"] = @"house_model_list";
//            traceParam[@"log_pb"] = self.baseViewModel.listLogPB;
//            traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"rank"] = @(indexPath.row);
//            traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
            traceParam[@"element_from"] = @"be_null";
            traceParam[@"log_pb"] = model.logPb;

            NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
            [infoDict setValue:model.id forKey:@"floor_plan_id"];
            [infoDict addEntriesFromDictionary:subPageParams];
            infoDict[@"house_type"] = @(1);
            infoDict[@"tracer"] = traceParam;
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
        } 
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index >= 0 && index < self.itemArray.count) {
        FHDetailNewDataFloorpanListListModel *itemModel = [self.itemArray objectAtIndex:index];
        NSString *groupId =  itemModel.groupId ?: itemModel.id;
        // 添加element_show埋点
        if (groupId && !self.elementShowCache[groupId]) {
            self.elementShowCache[groupId] = @(YES);
            
            NSDictionary *subPageParams = self.subPageParams;
            NSDictionary *tracer = subPageParams[@"tracer"];
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
            if ([tracer isKindOfClass:[NSDictionary class]]) {
                [traceParam addEntriesFromDictionary:tracer];
            }
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"rank"] = @(indexPath.row);
            traceParam[@"element_type"] = @"house_model";
            traceParam[@"page_type"] = @"house_model_list";
            traceParam[@"house_type"] = @"house_model";
            //[traceParam removeObjectForKey:@"enter_from"];
            [traceParam removeObjectForKey:@"element_from"];
            
            if ([tracer isKindOfClass:[NSDictionary class]] && [tracer[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
                [traceParam addEntriesFromDictionary:tracer[@"log_pb"]];
            }
            
            if (itemModel.logPb) {
                [traceParam setValue:itemModel.logPb forKey:@"log_pb"];
            }
            
            if (itemModel.searchId) {
                [traceParam setValue:itemModel.searchId forKey:@"search_id"];
            }
            
            if (itemModel.groupId) {
                [traceParam setValue:itemModel.groupId forKey:@"group_id"];
            }else
            {
                [traceParam setValue:itemModel.id forKey:@"group_id"];
            }
            
            if (itemModel.imprId) {
                [traceParam setValue:itemModel.imprId forKey:@"impr_id"];
            }
            
            [FHEnvContext recordEvent:traceParam andEventKey:@"house_show"];
        }
    }
}

@end


