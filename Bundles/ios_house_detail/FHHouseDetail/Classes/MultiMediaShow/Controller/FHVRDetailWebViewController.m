//
//  FHVRDetailWebViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/9/27.
//

#import "FHVRDetailWebViewController.h"
#import "BDImageView.h"
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>

@interface FHVRDetailWebViewController ()
@property(nonatomic,strong)BDImageView *maskLoadingView;
@end

@implementation FHVRDetailWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        [weakSelf.ssWebView.ssWebContainer tt_endUpdataData];
        [weakSelf.maskLoadingView removeFromSuperview];
    } forMethodName:@"closeLoading"];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if (!_maskLoadingView) {
        UIImage *imageData = [UIImage imageNamed:@"fh_vr_loading"];
        _maskLoadingView = [BDImageView new];
        [_maskLoadingView setImage:imageData];
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
