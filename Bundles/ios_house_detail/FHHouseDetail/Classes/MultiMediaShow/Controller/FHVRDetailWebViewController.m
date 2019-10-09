//
//  FHVRDetailWebViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/9/27.
//

#import "FHVRDetailWebViewController.h"

@interface FHVRDetailWebViewController ()
@property(nonatomic,strong)UIImageView *maskLoadingView;
@end

@implementation FHVRDetailWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        [_maskLoadingView removeFromSuperview];
    } forMethodName:@"closeLoading"];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if (!_maskLoadingView) {
        _maskLoadingView = [UIImageView new];
        [_maskLoadingView setImage:[UIImage imageNamed:@"fh_vr_loading"]];
        [_maskLoadingView setFrame:self.view.frame];
        _maskLoadingView.contentMode = UIViewContentModeScaleAspectFill;
        [_maskLoadingView setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:_maskLoadingView];
        [self.view bringSubviewToFront:_maskLoadingView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
