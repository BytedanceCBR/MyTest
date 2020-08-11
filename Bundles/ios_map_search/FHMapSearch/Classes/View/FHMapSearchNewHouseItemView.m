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

#define kMapSearchCellNewHouseItemImageId @"FHHouseBaseNewHouseCell"

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
       _houseTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width,118) style:UITableViewStylePlain];
        [_houseTable registerClass:[FHHouseBaseNewHouseCell class] forCellReuseIdentifier:kMapSearchCellNewHouseItemImageId];

        _houseTable.dataSource = self;
        _houseTable.delegate = self;
//        _tableView.bounces = NO;
        //        _tableView.decelerationRate = 0.1;
        _houseTable.showsVerticalScrollIndicator = NO;
        _houseTable.estimatedRowHeight = 0;
        [self addSubview:_houseTable];
                
        if (@available(iOS 11.0 , *)) {
            self.houseTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return self;
}

-(void)showNewHouse:(NSString *)query param:(NSDictionary *)param
{
    [self requsetSecondHouse:query param:param isHead:0];
}

- (void)processData:(FHSearchHouseModel *)houseModel{
    _itemModel = houseModel.data.items.firstObject;
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
    return 118;
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

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
