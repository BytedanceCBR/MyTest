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

-(instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        
    }
    return self;    
}

-(void)loadData:(BOOL)isRefresh {

}

-(void)onConditionChanged:(NSString *)condition
{
    
}

-(void)onConditionWillPanelDisplay
{
    
}

-(void)showInputSearch {
    
}

-(void)showMapSearch {
    
    
}

-(void)showMessageList {
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    
}

- (void)addNotiWithNaviBar:(FHFakeInputNavbar *)naviBar {
    
}

- (void)refreshMessageDot {
    
}

@end
