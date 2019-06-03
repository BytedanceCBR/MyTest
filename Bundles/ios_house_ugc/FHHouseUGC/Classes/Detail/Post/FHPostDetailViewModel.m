//
//  FHPostDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHPostDetailViewModel.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"

@interface FHPostDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHPostDetailViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;

@end

@implementation FHPostDetailViewModel

-(instancetype)initWithController:(FHPostDetailViewController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
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
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.listController.hasValidateData == YES) {
//        FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleImageCellId];
//        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
//        id model = _houseList[indexPath.row];
//        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//        CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
//        [cell updateWithHouseCellModel:cellModel];
//        [cell refreshTopMargin: 20];
//        return cell;
//    } else {
//        // PlaceholderCell
//        FHPlaceHolderCell *cell = (FHPlaceHolderCell *)[tableView dequeueReusableCellWithIdentifier:kPlaceholderCellId];
//        return cell;
//    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = @"123";
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

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
}


@end
