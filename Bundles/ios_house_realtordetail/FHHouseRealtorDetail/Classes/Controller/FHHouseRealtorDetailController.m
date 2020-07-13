//
//  FHHouseRealtorDetailController.m
//  Pods
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseRealtorDetailController.h"
#import <FHHouseBase/FHBaseTableView.h>
@interface FHHouseRealtorDetailController ()
@property (weak , nonatomic) UITableView *mainTable;
@end

@implementation FHHouseRealtorDetailController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self createTracerDic:paramObj.allParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)createTracerDic:(NSDictionary *)dic {
    
}

- (UITableView *)mainTable {
    if (!_mainTable) {
         _mainTable = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
           _mainTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
           _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//           UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//           tapGesturRecognizer.cancelsTouchesInView = NO;
//           tapGesturRecognizer.delegate = self;
//           [_mainTable addGestureRecognizer:tapGesturRecognizer];
           if (@available(iOS 11.0 , *)) {
               _mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
           }
           _mainTable.estimatedRowHeight = UITableViewAutomaticDimension;
           _mainTable.estimatedSectionFooterHeight = 0;
           _mainTable.estimatedSectionHeaderHeight = 0;
    }
}

@end
