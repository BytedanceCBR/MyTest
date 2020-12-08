//
//  FHPersonalHomePageFeedListViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageFeedListViewModel.h"
#import "FHPersonalHomePageViewController.h"


@interface FHPersonalHomePageFeedListViewModel () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property(nonatomic,weak) FHPersonalHomePageFeedListViewController *viewController;
@property(nonatomic,weak) UITableView *tableView;
@end

@implementation FHPersonalHomePageFeedListViewModel


-(instancetype)initWithController:(FHPersonalHomePageFeedListViewController *)viewController tableView:(UITableView *)tableView {
    if(self = [super init]) {
        _viewController = viewController;
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [self randomColor];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if(!self.viewController.cell.viewController.enableScroll) {
        scrollView.contentOffset = CGPointZero;
    }
    offset = scrollView.contentOffset.y;
    if(offset < 0){
        self.viewController.cell.viewController.enableScroll = NO;
        scrollView.contentOffset = CGPointZero;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHPersonalHomePageEnableScrollChangeNotification object:nil];
    }
}



- (UIColor*) randomColor{
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 255;
    NSInteger b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

@end
