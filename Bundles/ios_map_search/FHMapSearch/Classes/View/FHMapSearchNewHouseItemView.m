//
//  FHMapSearchNewHouseItemView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/8/10.
//

#import "FHMapSearchNewHouseItemView.h"
#import "FHHouseBaseNewHouseCell.h"
#import "FHHouseSearcher.h"
#import "ToastManager.h"
#import "UIViewController+HUD.h"
#import "TTRoute.h"
#import "FHUserTracker.h"

//#import "FHHomeBaseTableView.h"
#define kMapSearchCellNewHouseItemImageId @"FHHouseBaseNewHouseCell"
#define kMapSearchCellHeight 130

@interface FHMapSearchNewHouseItemView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UITableView *houseTable;
@property(nonatomic , strong) UIView *bottomLine;
@property(nonatomic , strong) UIButton *bottomAroundButton;
@property(nonatomic , strong) FHSearchHouseDataItemsModel *itemModel;
@property(nonatomic , strong) TTHttpTask *requestTask;

@end
@implementation FHMapSearchNewHouseItemView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
       _houseTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width,kMapSearchCellHeight) style:UITableViewStylePlain];
        [_houseTable registerClass:[FHHouseBaseNewHouseCell class] forCellReuseIdentifier:kMapSearchCellNewHouseItemImageId];

        _houseTable.dataSource = self;
        _houseTable.delegate = self;
//        _tableView.bounces = NO;
        //        _tableView.decelerationRate = 0.1;
        _houseTable.showsVerticalScrollIndicator = NO;
        _houseTable.estimatedRowHeight = 0;
        _houseTable.scrollEnabled = NO;
        _houseTable.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        [self addSubview:_houseTable];
                
        if (@available(iOS 11.0 , *)) {
            self.houseTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return self;
}

-(void)showNewHouse:(NSString *)query param:(NSDictionary *)param
{
    self.houseTable.hidden = YES;
    if (self.requestTask.state == TTHttpTaskStateRunning) {
          [self.requestTask cancel];
    }
    self.requestTask = [self requsetSecondHouse:query param:param isHead:0];
}

- (void)processData:(FHSearchHouseModel *)houseModel{
    _itemModel = houseModel.data.items.firstObject;
    self.houseTable.hidden = NO;
    [self.houseTable reloadData];
}

-(TTHttpTask *)requsetSecondHouse:(NSString *)query param:(NSDictionary *)param isHead:(BOOL)isHead
{
    [self.weakVC showLoadingAlert:nil];
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher houseSearchWithQuery:query param:param offset:0 class:[FHSearchHouseModel class] needCommonParams:YES callback:^(NSError * _Nullable error,FHSearchHouseModel * _Nullable houseModel) {
        [wself.weakVC dismissLoadingAlert];
        if (!wself) {
            return ;
        }
        if ((error || !houseModel || !houseModel.data) && wself.requestError) {
            wself.requestError();
        }
        [wself processData:houseModel];
    }];
    return task;
}

-(void)addHouseShowLog {
    FHSearchHouseDataItemsModel *cellModel = _itemModel;
    NSString *groupId = cellModel.groupId;
    NSString *imprId = cellModel.imprId;
    NSDictionary *logPb = cellModel.logPb;
    
   
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = @"new";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = @"mapfind";
    tracerDict[@"tab_name"] = @"new_tab";
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"element_from"] = @"new_tab";
    tracerDict[@"group_id"] = groupId ? : @"be_null";
    tracerDict[@"impr_id"] = imprId ? : @"be_null";
//    tracerDict[@"search_id"] = self.searchId ? : @"";
    tracerDict[@"rank"] = @(0);
    tracerDict[@"log_pb"] = logPb ? : @"be_null";
    if (_traceDict) {
        [tracerDict addEntriesFromDictionary:_traceDict];
    }
    
    [_traceDict setValue:cellModel.searchId forKey:@"search_id"];
    [_traceDict setValue:cellModel.searchId forKey:@"origin_search_id"];

    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMapSearchCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
       //to do 房源cell
    FHHouseBaseNewHouseCell *cell = [tableView dequeueReusableCellWithIdentifier:kMapSearchCellNewHouseItemImageId];
//     cell.delegate = self;
    [cell refreshTopMargin:4];
    if (_itemModel) {
        FHSearchHouseItemModel *itemModelForMap = [[FHSearchHouseItemModel alloc] initWithDictionary:[_itemModel toDictionary] error:nil];
        [cell updateHouseListNewHouseCellModel:itemModelForMap];
    }
//     [cell refreshIndexCorner:(indexPath.row == 0) andLast:(indexPath.row == (self.houseDataItemsModel.count - 1) && !self.hasMore)];
     return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_itemModel){
      [self addHouseShowLog];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHSearchHouseDataItemsModel *cellModel = _itemModel;
    
     NSMutableDictionary *traceParam = [NSMutableDictionary new];
     traceParam[@"card_type"] = @"left_pic";
     traceParam[@"log_pb"] = [cellModel logPb] ? : UT_BE_NULL;;
     traceParam[@"enter_from"] = @"mapfind";
     traceParam[@"origin_from"] = self.traceDict[@"origin_from"] ? : UT_BE_NULL;
     traceParam[@"origin_search_id"] = cellModel.searchId ? : UT_BE_NULL;
     traceParam[@"search_id"] = cellModel.searchId? : UT_BE_NULL;
     traceParam[@"rank"] = @(indexPath.row);
     NSMutableDictionary *dict = @{@"house_type":@(1),
                           @"tracer": traceParam
                           }.mutableCopy;
    if (_itemModel.hid) {
        NSURL *jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",_itemModel.hid]];
        if (jumpUrl != nil) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
