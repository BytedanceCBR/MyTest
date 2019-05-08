//
//  FacilityViewController.m
//  Demo
//
//  Created by leo on 2018/11/20.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FacilityViewController.h"
#import <Masonry/Masonry.h>
#import <FHHouseRent/FHHouseRent.h>
@interface FacilityViewController ()
{
    FHRowsView* _rowView;
}
@end

@implementation FacilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray* items = [[NSMutableArray alloc] init];
    FHHouseRentFacilityItemView* itemView = [[FHHouseRentFacilityItemView alloc] init];
    itemView.label.text = @"床";
    itemView.iconView.image = [UIImage imageNamed:@"bed"];

    [items addObject:itemView];
    itemView = [[FHHouseRentFacilityItemView alloc] init];
    itemView.label.text = @"床";
    itemView.iconView.image = [UIImage imageNamed:@"bed"];

    [items addObject:itemView];
    itemView = [[FHHouseRentFacilityItemView alloc] init];
    itemView.label.text = @"床";
    itemView.iconView.image = [UIImage imageNamed:@"bed"];

    [items addObject:itemView];
    itemView = [[FHHouseRentFacilityItemView alloc] init];
    itemView.label.text = @"床";
    itemView.iconView.image = [UIImage imageNamed:@"bed"];

    [items addObject:itemView];
    itemView = [[FHHouseRentFacilityItemView alloc] init];
    itemView.label.text = @"床";
    itemView.iconView.image = [UIImage imageNamed:@"bed"];

    [items addObject:itemView];
    itemView = [[FHHouseRentFacilityItemView alloc] init];
    itemView.label.text = @"床";
    itemView.iconView.image = [UIImage imageNamed:@"bed"];

    [items addObject:itemView];

    _rowView = [[FHRowsView alloc] initWithRowCount:5];
    [_rowView addItemViews:items];
    [self.view addSubview:_rowView];
    [_rowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(80);
        make.left.right.mas_equalTo(self.view);
        //        make.height.mas_equalTo(166);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
