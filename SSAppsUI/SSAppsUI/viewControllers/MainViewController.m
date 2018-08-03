//
//  MainViewController.m
//  SSAppsUI
//
//  Created by Dianwei on 13-9-4.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import "MainViewController.h"
#import "UIAppView.h"

@interface MainViewController ()
@property(nonatomic, retain)UIAppView *appView;
@end

@implementation MainViewController
- (void)dealloc
{
    self.appView = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.appView = [[[UIAppView alloc] initWithFrame:self.view.bounds] autorelease];
        [self.view addSubview:_appView];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"设计预览";
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
