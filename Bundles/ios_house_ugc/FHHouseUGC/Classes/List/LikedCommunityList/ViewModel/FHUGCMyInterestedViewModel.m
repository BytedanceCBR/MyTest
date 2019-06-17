//
//  FHUGCMyInterestedViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/13.
//

#import "FHUGCMyInterestedViewModel.h"
#import <TTHttpTask.h>
#import "FHRefreshCustomFooter.h"
#import "FHUGCMyInterestedCell.h"
#import "FHUGCMyInterestedSimpleCell.h"

#define kCellId @"cell_id"

@interface FHUGCMyInterestedViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHUGCMyInterestedController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;

@end

@implementation FHUGCMyInterestedViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCMyInterestedController *)viewController {
    self = [super init];
    if (self) {
        self.dataList = [[NSMutableArray alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        _viewController = viewController;
        _tableView = tableView;
        
        if(viewController.type == FHUGCMyInterestedTypeMore){
            [tableView registerClass:[FHUGCMyInterestedSimpleCell class] forCellReuseIdentifier:kCellId];
        }else{
            [tableView registerClass:[FHUGCMyInterestedCell class] forCellReuseIdentifier:kCellId];
        }
    }
    return self;
}

- (void)requestData:(BOOL)isHead {
    for (NSInteger i = 0; i < 15; i++) {
        [self.dataList addObject:[NSString stringWithFormat:@"小区%li",(long)i]];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *model = self.dataList[indexPath.row];
    
    [cell refreshWithData:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.viewController.type == FHUGCMyInterestedTypeMore){
        return 70;
    }else{
        return 192;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    FHSystemMsgDataItemsModel *model = self.dataList[indexPath.row];
//
//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[@"category_name"] = [self.viewController categoryName];
//    tracerDict[@"log_pb"] = model.logPb ? : @"be_null";
//    tracerDict[@"official_message_id"] = model.id;
//    TRACK_EVENT(@"click_official_message", tracerDict);
//
//    NSURL* url = [NSURL URLWithString:model.openUrl];
//    if ([url.scheme isEqualToString:@"fschema"]) {
//        NSString *newModelUrl = [model.openUrl stringByReplacingOccurrencesOfString:@"fschema:" withString:@"snssdk1370:"];
//        url = [NSURL URLWithString:newModelUrl];
//    }
//
//    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

@end
