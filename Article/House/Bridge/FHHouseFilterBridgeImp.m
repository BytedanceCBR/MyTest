//
//  FHHouseFilterBridge.m
//  Article
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHHouseFilterBridgeImp.h"
#import "Bubble-Swift.h"
#import "FHConditionFilterFactory.h"
@interface FHHouseFilterBridgeImp()

@property(nonatomic , strong) FHConditionFilterViewModel* houseFilterViewModel;
@property(nonatomic , assign) FHHouseType houseType;
@end

@implementation FHHouseFilterBridgeImp

-(id)filterViewModelWithType:(FHHouseType)houseType showAllCondition:(BOOL)showAllCondition showSort:(BOOL)showSort
{
    HouseType ht = HouseTypeSecondHandHouse;
    switch (houseType) {
        case FHHouseTypeNewHouse:
            ht = HouseTypeNewHouse;
            break;
        case FHHouseTypeRentHouse:
            ht = HouseTypeRentHouse;
            break;
        case FHHouseTypeNeighborhood:
            ht = HouseTypeNeighborhood;
            break;
        default:
            ht = HouseTypeSecondHandHouse;
            break;
    }

    FHConditionFilterFactory* factory = [[FHConditionFilterFactory alloc] init];
    NSArray<FHFilterNodeModel*>* configs = [FHFilterConditionParser getConfigByHouseTypeWithHouseType:ht];
    NSArray<FHFilterNodeModel*>* sortConfig = nil;
    if (showSort) {
        sortConfig = [FHFilterConditionParser getSortConfigByHouseTypeWithHouseType:ht];
    }
    _houseFilterViewModel = [factory createFilterPanelViewModel:ht
                                                   allCondition:showAllCondition
                                                        sortConfig: sortConfig
                                                         config:configs];
    return _houseFilterViewModel;
}

-(UIView *)filterPannel:(id)viewModel
{
    return [_houseFilterViewModel filterBar];
}

-(UIView *)filterBgView:(id)viewModel
{
    return [_houseFilterViewModel filterConditionPanel];
}

-(void)resetFilter:(id)viewModel withQueryParams:(NSDictionary * )params updateFilterOnly:(BOOL)updateFilterOnly
{
    [_houseFilterViewModel resetFilterConditionWithQueryParams:params updateFilterOnly:updateFilterOnly];
}

-(void)setViewModel:(id)viewModel withDelegate:(id<FHConditionFilterViewModelDelegate>)delegate
{
    _houseFilterViewModel.delegate = delegate;
}

-(NSString *)getConditions
{
    return [_houseFilterViewModel conditionQueryString];
}

-(void)closeConditionFilterPanel
{
    [_houseFilterViewModel closeConditionFilterPanel];
}

-(NSString *) getNoneFilterQueryParams:(NSDictionary *) params
{
    NSString *query =  [_houseFilterViewModel getNoneFilterQueryWithParams:params];
    return query;
}

-(void)clearSortCondition
{
    [_houseFilterViewModel cleanSortCondition];
}

-(void)showBottomLine:(BOOL)show
{
    [_houseFilterViewModel setFilterPanelBottomLineHidden:!show];
}

-(void)trigerConditionChanged {
    [_houseFilterViewModel trigerConditionChanged];
}

-(void)setFilterConditions:(NSDictionary*)params {
    
    [_houseFilterViewModel setFilterConditions:params];
}

@end
