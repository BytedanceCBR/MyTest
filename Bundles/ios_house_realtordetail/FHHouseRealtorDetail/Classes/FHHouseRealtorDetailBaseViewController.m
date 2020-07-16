//
//  FHHouseRealtorDetailBaseViewController.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHHouseRealtorDetailBaseViewController.h"
#import "FHBaseTableView.h"
#import "Masonry.h"

@interface FHHouseRealtorDetailBaseViewController ()

@end

@implementation FHHouseRealtorDetailBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 800)];
    self.tableView.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}

- (UITableView *)tableView {
    if (!_tableView) {
         UITableView *mainTable = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
           mainTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
           mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//           UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//           tapGesturRecognizer.cancelsTouchesInView = NO;
//           tapGesturRecognizer.delegate = self;
//           [_mainTable addGestureRecognizer:tapGesturRecognizer];
           if (@available(iOS 11.0 , *)) {
               mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
           }
           mainTable.estimatedRowHeight = UITableViewAutomaticDimension;
           mainTable.estimatedSectionFooterHeight = 0;
           mainTable.estimatedSectionHeaderHeight = 0;
        [self.view addSubview:mainTable];
        _tableView = mainTable;
    }
    return _tableView;
}

@end
