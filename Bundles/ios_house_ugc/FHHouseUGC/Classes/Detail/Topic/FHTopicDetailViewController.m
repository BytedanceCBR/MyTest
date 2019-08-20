//
//  FHTopicDetailViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHTopicDetailViewController.h"
#import "FHExploreDetailToolbarView.h"
#import "SSCommonLogic.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "FHCommentViewController.h"
#import "TTDeviceHelper.h"

@interface FHTopicDetailViewController ()


@end

@implementation FHTopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    [self setupDetailNaviBar];
    
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"话题";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
