//
//  FHHouseFilterBridge.m
//  Article
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHHouseFilterBridgeImp.h"
//#import "Bubble-Swift.h"
#import "FHConditionFilterFactory.h"
#import "FHSearchConfigModel.h"
#import "FHFilterModelParser.h"
#import "FHEnvContext.h"
#import <FHHouseType.h>

@interface FHHouseFilterBridgeImp()

@property(nonatomic , strong) FHConditionFilterViewModel* houseFilterViewModel;
@property(nonatomic , assign) FHHouseType houseType;
@end

@implementation FHHouseFilterBridgeImp

-(id)filterViewModelWithType:(FHHouseType)houseType
            showAllCondition:(BOOL)showAllCondition
                    showSort:(BOOL)showSort
          safeBottomPandding:(CGFloat)safeBottomPandding
{
//    FHHouseType ht = HouseTypeSecondHandHouse;
//    switch (houseType) {
//        case FHHouseTypeNewHouse:
//            ht = HouseTypeNewHouse;
//            break;
//        case FHHouseTypeRentHouse:
//            ht = HouseTypeRentHouse;
//            break;
//        case FHHouseTypeNeighborhood:
//            ht = HouseTypeNeighborhood;
//            break;
//        default:
//            ht = HouseTypeSecondHandHouse;
//            break;
//    }


    FHConditionFilterFactory* factory = [[FHConditionFilterFactory alloc] init];

    factory.safeBottomPandding = safeBottomPandding;
    NSArray<FHFilterNodeModel*>* configs = [FHFilterModelParser getConfigByHouseType:houseType];
    NSArray<FHFilterNodeModel*>* sortConfig = nil;
    if (showSort) {
        sortConfig = [FHFilterModelParser getSortConfigByHouseType:houseType].firstObject.children.firstObject.children;
    }
    _houseFilterViewModel = [factory createFilterPanelViewModel:houseType
                                                   allCondition:showAllCondition
                                                     sortConfig:sortConfig
                                                         config:configs];
    return _houseFilterViewModel;
}

-(id)filterViewModelWithType:(FHHouseType)houseType
            showAllCondition:(BOOL)showAllCondition
                    showSort:(BOOL)showSort
{
    CGFloat safeBottomPandding = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        if (@available(iOS 11.0, *)) {
            safeBottomPandding = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        } else {
            // Fallback on earlier versions
        }
    }
    return [self filterViewModelWithType:houseType
                        showAllCondition:showAllCondition
                                showSort:showSort
                      safeBottomPandding:safeBottomPandding];
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

-(NSString *)getAllQueryString
{
    return [_houseFilterViewModel allQueryString];
}

@end
