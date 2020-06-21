//
//  FHVRDetailWebViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/9/27.
//

#import "FHVRDetailWebViewController.h"
#import "BDImageView.h"
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"

@interface FHVRDetailWebViewController ()
@property(nonatomic,strong)BDImageView *maskLoadingView;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property (nonatomic, assign) BOOL isLoadingSuccess; //loading成功

@end

@implementation FHVRDetailWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLoadingSuccess = NO;

    __weak __typeof(self) weakSelf = self;
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        [weakSelf.ssWebView.ssWebContainer tt_endUpdataData];
        [weakSelf.maskLoadingView removeFromSuperview];
        weakSelf.isLoadingSuccess = YES;
        [weakSelf sendDurationKey:@"vr_page_loading_duration" withStatus:0];
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
    
    self.stayTime = [self getCurrentTime];
}

- (NSTimeInterval)getCurrentTime
{
    return  [[NSDate date] timeIntervalSince1970];
}

- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
    if(!parent){
    }else
    {
    }
}

- (void)sendDurationKey:(NSString *)keyStr withStatus:(NSInteger)status{
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    NSTimeInterval duration = ([self getCurrentTime] - self.stayTime) * 1000.0;
    [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
     NSMutableDictionary *uploadParams = [NSMutableDictionary new];
     [uploadParams setValue:@(duration) forKey:@"lynx_page_duration"];
    [[HMDTTMonitor defaultManager] hmdTrackService:keyStr metric:uploadParams category:@{@"status":@(status)} extra:paramsExtra];
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
       [self sendDurationKey:@"vr_page_duration" withStatus:self.isLoadingSuccess ? 0 : 1];
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
