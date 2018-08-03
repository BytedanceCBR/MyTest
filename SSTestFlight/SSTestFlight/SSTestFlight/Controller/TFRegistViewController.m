//
//  TFRegistViewController.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFRegistViewController.h"
#import "TFRegistView.h"

@interface TFRegistViewController ()
@property(nonatomic, retain)TFRegistView * registView;
@end

@implementation TFRegistViewController

- (void)dealloc
{
    self.registView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.registView = [[[TFRegistView alloc] initWithFrame:self.view.bounds] autorelease];
    [self.view addSubview:_registView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_registView willAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_registView didAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_registView willDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_registView didDisappear];
}

@end
