//
//  FHTopicDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/22.
//

#import "FHTopicDetailViewModel.h"
#import "FHHouseListAPI.h"
#import "FHUserTracker.h"
#import "FHUGCBaseCell.h"
#import "FHUGCReplyCell.h"
#import "FHHouseUGCAPI.h"

@interface FHTopicDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHTopicDetailViewController *detailController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property (nonatomic, assign)   BOOL       canScroll;
@property (nonatomic, weak)     UIScrollView       *weakScroolView;

@end

@implementation FHTopicDetailViewModel

-(instancetype)initWithController:(FHTopicDetailViewController *)viewController
{   self = [super init];
    if (self) {
        self.detailController = viewController;
        self.ugcCellManager = [[FHUGCCellManager alloc] init];
        self.canScroll = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCGoTop" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadData {
    [self.detailController endLoading];
    self.detailController.isLoadingData = NO;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger row = indexPath.row;
//    if (row >= 0 && row < self.items.count) {
//        id data = self.items[row];
//        NSString *identifier = [self cellIdentifierForEntity:data];
//        if (identifier.length > 0) {
//            FHUGCBaseCell *cell = (FHUGCBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
//            cell.baseViewModel = self;
//            [cell refreshWithData:data];
//            return cell;
//        }
//    }
    FHUGCBaseCell * cell = [[FHUGCBaseCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
//    self.cellHeightCaches[tempKey] = cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
//    if (cellHeight) {
//        return [cellHeight floatValue];
//    }
//    return UITableViewAutomaticDimension;
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    FHUGCBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.didClickCellBlk) {
//        cell.didClickCellBlk();
//    }
}
#pragma mark - UIScrollViewDelegate
//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.weakScroolView = scrollView;
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<=0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCLeaveTop" object:nil userInfo:@{@"canScroll":@"1"}];
    }
}

-(void)acceptMsg:(NSNotification *)notification{
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:@"kFHUGCGoTop"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    }else if([notificationName isEqualToString:@"kFHUGCLeaveTop"]){
        self.weakScroolView.contentOffset = CGPointZero;
        self.canScroll = NO;
    }
}



@end
