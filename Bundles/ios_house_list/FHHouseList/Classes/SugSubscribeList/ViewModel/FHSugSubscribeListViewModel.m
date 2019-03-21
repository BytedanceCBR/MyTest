//
//  FHSugSubscribeListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeListViewModel.h"
#import "FHHouseListAPI.h"


@interface FHSugSubscribeListViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHSugSubscribeListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;

@end

@implementation FHSugSubscribeListViewModel

-(instancetype)initWithController:(FHSugSubscribeListViewController *)viewController tableView:(UITableView *)tableView
{   self = [super init];
    if (self) {
        self.listController = viewController;
        self.tableView = tableView;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
//    [_tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kSingleImageCellId];
//    [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceholderCellId];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listController.hasValidateData == YES) {
//        return _houseList.count;
    } else {
        // PlaceholderCell Count
        return 10;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.listController.hasValidateData == YES) {
//        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleImageCellId];
//        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
//        id model = _houseList[indexPath.row];
//        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//        CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
//        [cell updateWithHouseCellModel:cellModel];
//        [cell refreshTopMargin: 20];
//        [cell refreshBottomMargin:(isLastCell ? 20 : 0)+reasonHeight];
//        return cell;
//    } else {
//        // PlaceholderCell
//        FHPlaceHolderCell *cell = (FHPlaceHolderCell *)[tableView dequeueReusableCellWithIdentifier:kPlaceholderCellId];
//        return cell;
//    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.listController.hasValidateData == YES && indexPath.row < self.houseList.count) {
//        NSInteger rank = indexPath.row - 1;
//        NSString *recordKey = [NSString stringWithFormat:@"%ld",rank];
//        if (!self.houseShowTracerDic[recordKey]) {
//            // 埋点
//            self.houseShowTracerDic[recordKey] = @(YES);
//            [self addHouseShowLog:indexPath];
//        }
//    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listController.hasValidateData) {
        
//        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
//        if (indexPath.row < self.houseList.count) {
//
//            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//            CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
//            if (height < 1) {
//                CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
//                height = [tableView fd_heightForCellWithIdentifier:kSingleImageCellId cacheByIndexPath:indexPath configuration:^(FHSingleImageInfoCell *cell) {
//                    [cell updateWithHouseCellModel:cellModel];
//                    [cell refreshTopMargin: 20];
//                    [cell refreshBottomMargin:(isLastCell ? 20 : 0)+reasonHeight];
//                }];
//            }
//            return height;
//        }
    }
    
    return 105;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self jump2DetailPage:indexPath];
}

@end
