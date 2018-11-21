//
//  FHHouseFilterBridge.m
//  Article
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHHouseFilterBridgeImp.h"
#import "Bubble-Swift.h"

@interface FHHouseFilterBridgeImp()

@property(nonatomic , strong) HouseFilterViewModel* houseFilterViewModel;
@property(nonatomic , assign) FHHouseType houseType;
@end

@implementation FHHouseFilterBridgeImp

-(id)filterViewModelWithType:(FHHouseType)houseType
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
        default:
            ht = HouseTypeSecondHandHouse;
            break;
    }
    
    MapFindHouseFilterFactory* factory = [[MapFindHouseFilterFactory alloc] init];
    _houseFilterViewModel = [factory createFilterPanelViewModelWithHouseType:ht];
    return _houseFilterViewModel;
}

-(UIView *)filterPannel:(id)viewModel
{
    return [_houseFilterViewModel filterPanelView];
}

-(UIView *)filterBgView:(id)viewModel
{
    return [_houseFilterViewModel filterConditionPanel];
}

-(void)resetFilter:(id)viewModel withQueryParams:(NSDictionary * )params updateFilterOnly:(BOOL)updateFilterOnly
{
    [_houseFilterViewModel resetFilterConditionWithQueryParams:params updateFilterOnly:updateFilterOnly];
}

-(void)setViewModel:(id)viewModel withDelegate:(id<FHHouseFilterDelegate>)delegate
{
    _houseFilterViewModel.delegate = delegate;
}

-(NSString *)getConditions
{
    return [_houseFilterViewModel getConditions];
}

-(void)closeConditionFilterPanel
{
    [_houseFilterViewModel closeConditionFilterPanel];
}

-(NSString *) getNoneFilterQueryParams:(NSDictionary *) params
{
    return [_houseFilterViewModel getNoneFilterQueryWithParams:params];
}

@end