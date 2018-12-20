//
//  FirstViewController.m
//  Demo
//
//  Created by leo on 2018/11/15.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FirstViewController.h"
#import <FHHouseBase/FHHouseBase.h>
#import <Masonry/Masonry.h>
#import "DemoFilterItemView.h"
#import "ConditionSelectView.h"

@interface FirstViewController ()
{
    FHFilterViewModel* _filterViewModel;
}
@end

@implementation FirstViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.



    NSArray<DemoFilterItemView*>* items = @[[[DemoFilterItemView alloc] init],
                       [[DemoFilterItemView alloc] init],
                       ];
    FilterItemBar* filterBar = [FilterItemBar instanceWithItems:items];
    filterBar.backgroundColor = [UIColor redColor];
    [self.view addSubview:filterBar];
    [filterBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(45);
        make.top.mas_equalTo(80);
        make.left.right.mas_equalTo(self.view);
    }];

    FHFilterContainerPanel* panel = [[FHFilterContainerPanel alloc] init];
    [self.view addSubview:panel];
    [panel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(filterBar.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    panel.backgroundColor = [UIColor lightGrayColor];
    panel.alpha = 0.8;
    [panel setHidden:YES];

    ConditionSelectView* selectView = [[ConditionSelectView alloc] initWithName:@"1"];
    [selectView setHidden:YES];
    [panel addSubview:selectView];
    [selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(panel);
    }];
    items[0].conditionSelectPanel = selectView;

    selectView = [[ConditionSelectView alloc] initWithName:@"2"];
    selectView.backgroundColor = [UIColor whiteColor];
    [selectView setHidden:YES];
    [panel addSubview:selectView];
    [selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(panel);
        make.bottom.mas_equalTo(panel).mas_offset(-200);
    }];
    items[1].conditionSelectPanel = selectView;

    _filterViewModel = [FHFilterViewModel instanceWithItemBar:filterBar
                                                    withPanel:panel];
    NSDictionary* dict = [FileUtils readLocalFileWithName:@"search_config"];
    NSLog(@"%@", dict);
}


@end
