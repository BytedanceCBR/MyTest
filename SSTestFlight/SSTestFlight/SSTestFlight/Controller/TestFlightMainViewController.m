//
//  TestFlightMainViewController.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TestFlightMainViewController.h"
#import "TFMainView.h"

@interface TestFlightMainViewController ()

@property(nonatomic, retain)TFMainView * mainView;

@end

@implementation TestFlightMainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.mainView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.mainView = [[[TFMainView alloc] initWithFrame:self.view.bounds] autorelease];
    [self.view addSubview:_mainView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)willEnterForeground
{
    [_mainView willAppear];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mainView willAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_mainView didAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mainView willDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_mainView didDisappear];
}





@end
