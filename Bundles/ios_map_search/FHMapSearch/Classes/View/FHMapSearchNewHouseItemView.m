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

//#import "FHHomeBaseTableView.h"
#define kMapSearchCellNewHouseItemImageId @"FHHouseBaseNewHouseCell"
#define kMapSearchCellHeight 130

@interface FHMapSearchNewHouseItemView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UITableView *houseTable;
@property(nonatomic , strong) UIView *bottomLine;
@property(nonatomic , strong) UIButton *bottomAroundButton;
@property(nonatomic , strong) FHSearchHouseDataItemsModel *itemModel;

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
    [self requsetSecondHouse:query param:param isHead:0];
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
        [self.weakVC dismissLoadingAlert];
        if (!wself) {
            return ;
        }
        [wself processData:houseModel];
    }];
    return task;
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
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
         
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
//            traceParam[@"enter_from"] =@"";
//            traceParam[@"log_pb"] = theModel.logPb;
//            traceParam[@"origin_from"] = [self pageTypeString];
//            traceParam[@"card_type"] = @"left_pic";
//            traceParam[@"rank"] = [self getRankFromHouseId:theModel.idx indexPath:indexPath];
//            traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";
//            traceParam[@"element_from"] = @"maintab_list";
//            traceParam[@"enter_from"] = @"maintab";
//
//            NSInteger houseType = 0;
//            if ([theModel.houseType isKindOfClass:[NSString class]]) {
//                houseType = [theModel.houseType integerValue];
//            }
//
//            if (houseType == 0) {
//                houseType = self.houseType;
//            }
    //        if (houseType != 0) {
    //            if (houseType != self.houseType) {
    //                return;
    //            }
    //        }else
    //        {
    //            houseType = self.houseType;
    //        }
                    
            NSMutableDictionary *dict = @{@"house_type":@(1),
                                   @"tracer": traceParam
                                   }.mutableCopy;
//            dict[INSTANT_DATA_KEY] = theModel;
//            dict[@"biz_trace"] = theModel.bizTrace;
            NSURL *jumpUrl = nil;
            
           
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",_itemModel.hid]];
            
            if (jumpUrl != nil) {
                TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
                [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
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
