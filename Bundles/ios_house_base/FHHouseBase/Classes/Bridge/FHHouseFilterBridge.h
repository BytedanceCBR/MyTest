//
//  FHHouseFilterBridge.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/18.
//

#ifndef FHHouseFilterBridge_h
#define FHHouseFilterBridge_h

#import "FHHouseType.h"
#import "FHHouseFilterDelegate.h"

@protocol  FHHouseFilterBridge<NSObject>

@required

-(id)filterViewModelWithType:(FHHouseType)houseType showAllCondition:(BOOL)showAllCondition showSort:(BOOL)showSort;

-(UIView *)filterPannel:(id)viewModel;

-(UIView *)filterBgView:(id)viewModel;

-(void)resetFilter:(id)viewModel withQueryParams:(NSDictionary * )params updateFilterOnly:(BOOL)updateFilterOnly;

-(void)setViewModel:(id)viewModel withDelegate:(id<FHHouseFilterDelegate>)delegate;

-(NSString *)getConditions;

-(NSString *) getNoneFilterQueryParams:(NSDictionary *) params;

-(void)closeConditionFilterPanel;

-(void)clearSortCondition;

-(void)showBottomLine:(BOOL)show;

-(void)trigerConditionChanged;

@optional

-(void)setFilterConditions:(NSDictionary*)params;

#pragma mark 获取所有query条件，包括condition和非condition
-(NSString *)getAllQueryString;
@end




#endif /* FHHouseFilterBridge_h */
