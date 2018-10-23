//
//  SSDebugUserDefaultsViewController.m
//  Article
//
//  Created by SunJiangting on 15-3-8.
//
//

#if INHOUSE

#import "SSDebugUserDefaultsViewController.h"
#import "MBProgressHUD.h"
#import "SSDebugViewControllerBase.h"


@interface SSDebugUserDefaultsViewController ()

@property(nonatomic, strong) STDebugTextView *textView;

@end

@implementation SSDebugUserDefaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"NSUserDefaults";
    
    self.textView = [[STDebugTextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.textView];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.detailsLabelText = @"正在读取";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *userDefaultPath = [NSString stringWithFormat:@"Preferences/%@.plist", [TTSandBoxHelper bundleIdentifier]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *path = [paths[0] stringByAppendingPathComponent:userDefaultPath];
        NSDictionary *userDefaults = [NSDictionary dictionaryWithContentsOfFile:path];
        if (userDefaults) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.textView appendText:userDefaults.description];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.textView appendText:@"没有读取到任何内容"];
            });
        }
    });
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

#endif
