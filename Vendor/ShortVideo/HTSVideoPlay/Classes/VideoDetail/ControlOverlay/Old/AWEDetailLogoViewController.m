//
//  AWEDetailLogoViewController.m
//  Pods
//
//  Created by Zuyang Kou on 22/08/2017.
//
//

#import "AWEDetailLogoViewController.h"
#import "TTShortVideoModel.h"
#import "AWEVideoConstants.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "AWEVideoDetailTracker.h"
#import "TTModuleBridge.h"
#import <extobjc.h>
#import "TSVVideoDetailPromptManager.h"
#import "TTSettingsManager.h"
#import "TSVLogoAction.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "AWEVideoPlayTransitionBridge.h"

@interface AWEDetailLogoViewController ()

@property (nonatomic, strong) UIImageView *view;

@end

@implementation AWEDetailLogoViewController

@dynamic view;

- (void)loadView
{
    self.view = [[UIImageView alloc] init];

    self.view.clipsToBounds = YES;
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoClicked:)]];
}

- (void)setModel:(TTShortVideoModel *)model
{
    _model = model;

    [self refreshLogoImage];
}

- (void)refreshLogoImage
{
    NSDictionary *configDict = [AWEVideoPlayTransitionBridge getConfigDictWithGroupSource:self.model.groupSource];
    [self.view sda_setImageWithURL:[NSURL URLWithString:configDict[@"old_icon_url"]] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
}

- (IBAction)logoClicked:(id)sender
{
    [[TSVLogoAction sharedInstance] clickLogoWithModel:self.model
                               commonTrackingParameter:self.commonTrackingParameter
                                   detailPromptManager:self.detailPromptManager
                                              position:@"detail_top_bar"];
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
