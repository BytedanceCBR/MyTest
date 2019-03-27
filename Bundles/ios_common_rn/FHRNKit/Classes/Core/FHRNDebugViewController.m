//
//  FHRNDebugViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/27.
//

#import "FHRNDebugViewController.h"

@interface FHRNDebugViewController ()

@end

@implementation FHRNDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

# pragma mark - TTRNKitProtocol
- (UIViewController *)presentor{
    return self;
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
