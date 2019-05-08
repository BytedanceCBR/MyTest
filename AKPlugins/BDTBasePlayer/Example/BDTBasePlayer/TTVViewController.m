//
//  TTVViewController.m
//  BDTBasePlayer
//
//  Created by pxx914 on 09/21/2017.
//  Copyright (c) 2017 pxx914. All rights reserved.
//

#import "TTVViewController.h"
#import "TTVBaseDemandPlayer.h"

@interface TTVViewController ()
@property (nonatomic ,strong)TTVBaseDemandPlayer *player;
@end

@implementation TTVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)applicationWillResignActive:(NSNotification *)noti {
    self.player = nil;
}

- (void)playaction
{
    self.player = [[TTVBaseDemandPlayer alloc] init];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
