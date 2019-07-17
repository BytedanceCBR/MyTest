//
//  FHCommentDetailViewModel.m
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import "FHCommentDetailViewModel.h"
#import "FHHouseListAPI.h"
#import "FHSugSubscribeItemCell.h"
#import "FHCommentDetailViewController.h"
#import "FHUserTracker.h"

@interface FHCommentDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCommentDetailViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;

@end

@implementation FHCommentDetailViewModel

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView
{   self = [super init];
    if (self) {
        self.listController = viewController;
        self.tableView = tableView;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[FHSugSubscribeItemCell class] forCellReuseIdentifier:@"FHSugSubscribeItemCell"];
}

- (void)startLoadData {
    
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
