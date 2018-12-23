//
//  FHBaseHouseListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/7.
//

#import "FHBaseHouseListViewModel.h"

@interface FHBaseHouseListViewModel ()

@end

@implementation FHBaseHouseListViewModel

-(NSString *)categoryName
{
    return @"be_null";
}

-(instancetype)initWithTableView:(UITableView *)tableView viewControler:(FHHouseListViewController *)vc routeParam:(TTRouteParamObj *)paramObj {
    
    
}

-(void)loadData:(BOOL)isRefresh {

}

-(void)onConditionChanged:(NSString *)condition
{
    
}

-(void)onConditionWillPanelDisplay
{
    
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject {
    
}

-(void)resetCondition {
    
}

-(void)backAction:(UIViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}



-(void)showInputSearch {
    
}

-(void)showMapSearch {
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    
}



@end
