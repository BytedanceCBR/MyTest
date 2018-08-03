//
//  AppDelegate.m
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import "AppDelegate.h"
#include "MasterViewController.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // 1. Create the master View Controller
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    // 2. Add the view controller to the Window's content view
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
