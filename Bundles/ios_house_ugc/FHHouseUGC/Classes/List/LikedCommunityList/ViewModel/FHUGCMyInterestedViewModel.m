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
#import "FHHouseUGCAPI.h"
#import "FHUGCMyInterestModel.h"

#define kCellId @"cell_id"

@interface FHUGCMyInterestedViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHUGCMyInterestedController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) NSMutableDictionary *cellHeightCaches;

@end

@implementation FHUGCMyInterestedViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCMyInterestedController *)viewController {
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc] init];
        _cellHeightCaches = [NSMutableDictionary dictionary];
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
    [self.requestTask cancel];
    
//    for (NSInteger i = 0; i < 15; i++) {
//        [self.dataList addObject:[NSString stringWithFormat:@"小区%li",(long)i]];
//    }
//    [self.tableView reloadData];
    
    [self.viewController startLoading];
    
    __weak typeof(self) wself = self;
    
    self.requestTask = [FHHouseUGCAPI requestRecommendSocialGroupsWithLatitude:0 longitude:0 class:[FHUGCMyInterestModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        FHUGCMyInterestModel *interestModel = (FHUGCMyInterestModel *)model;

        if (error) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }
        
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
            if (isHead) {
                [wself.dataList removeAllObjects];
            }
            [wself.dataList addObjectsFromArray:interestModel.data.recommendSocialGroups];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
                if(wself.viewController.type == FHUGCMyInterestedTypeEmpty){
                    [wself.viewController.emptyView showEmptyWithTip:@"你还没有关注任何小区圈\n去附近或发现逛逛吧" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
                }else{
                    [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                }
            }
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    FHUGCMyInterestDataRecommendSocialGroupsModel *model = self.dataList[indexPath.row];
    [cell refreshWithData:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.viewController.type == FHUGCMyInterestedTypeMore){
        return 70;
    }else{
        NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
        NSNumber *cellHeight = self.cellHeightCaches[tempKey];
        if (cellHeight) {
            return [cellHeight floatValue];
        }
        return UITableViewAutomaticDimension;
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
