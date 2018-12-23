//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeListViewModel.h"

@interface FHHomeListViewModel()

@property (nonatomic, strong) UITableView *tableViewV;

@property (nonatomic, strong) FHHomeViewController *homeViewController;

@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC
{
    self = [super init];
    if (self) {
        self.tableViewV = tableView;
        self.homeViewController = homeVC;
    }
    return self;
}



@end
