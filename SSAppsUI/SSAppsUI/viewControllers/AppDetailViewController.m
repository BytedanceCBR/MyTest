//
//  AppDetailViewController.m
//  SSAppsUI
//
//  Created by Dianwei on 13-9-4.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import "AppDetailViewController.h"
#import "AppDetailView.h"

@interface AppDetailViewController ()
@property(nonatomic, retain)AppDetailView *detailView;
@property(nonatomic, retain)NSString *name;
@end

@implementation AppDetailViewController

- (void)dealloc
{
    self.detailView = nil;
    self.name = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.detailView = [[[AppDetailView alloc] initWithFrame:self.view.bounds] autorelease];
        [self.view addSubview:_detailView];
    }
    
    return self;
}

- (void)refreshWithAppID:(NSString*)appID name:(NSString*)name
{
    [_detailView refreshWithAppID:appID];
    self.name = name;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = _name;
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
