//
//  FHCommunityViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHCommunityViewController.h"
#import "FHPostUGCViewController.h"
#import "TTNavigationController.h"
#import "FHWDPostViewController.h"

@interface FHCommunityViewController ()

@end

@implementation FHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    FHPostUGCViewController *vc = [[FHPostUGCViewController alloc] init];
    TTNavigationController *navVC = [[TTNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVC animated:YES completion:nil];
}

@end
