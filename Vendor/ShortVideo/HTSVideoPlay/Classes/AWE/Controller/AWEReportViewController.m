//
//
//  Created by zhaoqin on 9/1/16.
//
//

#import "AWEReportViewController.h"
#import "AWEActionSheetConst.h"
#import "AWEActionSheetAnimated.h"
#import "AWEActionSheetModel.h"
#import "AWEVideoCommentDataManager.h"
#import "AWEActionSheetCellModel.h"
#import "AWEActionSheetTableController.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTThemeConst.h"

//UIWindow的rootViewController
@interface AWEActionSheetViewController : UIViewController

@end

@implementation AWEActionSheetViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end

//AWEActionSheet的rootViewContrller
@interface AWEActionSheetRootViewController : UINavigationController<UINavigationControllerDelegate>

@end

@implementation AWEActionSheetRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self.view setBackgroundColor:[UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"1b1b1b"]];
}


- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        return [AWEActionSheetAnimated transitionWithTransitionType:AWEActionSheetTransitionTypePresent];
    }
    if (operation == UINavigationControllerOperationPop) {
        return [AWEActionSheetAnimated transitionWithTransitionType:AWEActionSheetTransitionTypeDismiss];
    }
    return nil;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end


@interface AWEReportViewController ()
@property (nonatomic, strong) UIWindow *backWindow;
@property (nonatomic, strong) AWEActionSheetRootViewController *rootViewController;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) void (^completion)(NSDictionary *);
@property (nonatomic, strong) AWEVideoCommentDataManager *manager;
@property (nonatomic, strong) AWEActionSheetViewController *actionSheetViewController;
@property (nonatomic, assign) NSInteger lastReportCount;
@property (nonatomic, assign) BOOL isCancel;
@end

@implementation AWEReportViewController

static AWEReportViewController *sharedInstance;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AWEActionSheetFinishedClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastReportCount = 0;
    }
    return self;
}

- (void)initBaseConfig {
    
    [self.actionSheetViewController.view addSubview:self.maskView];
    [self.actionSheetViewController.view addSubview:self.rootViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickFinished:) name:AWEActionSheetFinishedClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)applicationStautsBarDidRotate {
    if (self.actionSheetViewController) {
        [self willTransitionToSize:[UIApplication sharedApplication].keyWindow.bounds.size];
    }
}

- (void)willTransitionToSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size = size;
    self.backWindow.frame = frame;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    self.maskView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
}

- (void)initReportModelWithOptions:(NSArray<NSDictionary *> *)reportOptions
{
    if (!self.manager.reportModel) {
        AWEActionSheetModel *reportModel = [[AWEActionSheetModel alloc] init];
        reportModel.dataArray = reportOptions;
        [self.manager addActionSheetMode:reportModel];
    }
}

- (void)performWithReportOptions:(NSArray<NSDictionary *> *)reportOptions completion:(nullable void (^)(NSDictionary *_Nonnull parameters))completion
{
    [self initBaseConfig];
    [self initReportModelWithOptions:reportOptions];
    [self.backWindow makeKeyAndVisible];
    [self configGesture];
    [self configNavigation];
    self.completion = completion;
    
    CGRect rect = self.rootViewController.view.frame;
    rect.origin.y += rect.size.height;
    self.rootViewController.view.frame = rect;
    [UIView animateWithDuration:AWEActionSheetAnimationDuration animations:^{
        CGRect rect = self.rootViewController.view.frame;
        rect.origin.y -= rect.size.height;
        self.rootViewController.view.frame = rect;
    }];
    
}

- (void)configGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMask)];
    self.isCancel = YES;
    [self.maskView addGestureRecognizer:tap];
}

- (void)configNavigation {
    if (!self.manager.reportModel) {
        return;
    }
    
    AWEActionSheetTableController *tableController = [[AWEActionSheetTableController alloc] init];
    tableController.reportType = self.reportType;
    tableController.manager = self.manager;
    tableController.model = self.manager.reportModel;
    
    [self.rootViewController setViewControllers:@[tableController] animated:NO];
    self.rootViewController.navigationBar.clipsToBounds = YES;
}

- (void)dismissController {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [UIView animateWithDuration:AWEActionSheetAnimationDuration animations:^{
        CGRect rect = self.rootViewController.view.frame;
        rect.origin.y += rect.size.height;
        self.rootViewController.view.frame = rect;
    } completion:^(BOOL finished) {
        self.backWindow.hidden = YES;
        self.backWindow = nil;
        NSString *criticism = [[self.manager criticismInput] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableString *reportOptions = [[NSMutableString alloc] init];
        if (self.manager.reportModel) {
            for (AWEActionSheetCellModel *cellModel in self.manager.reportModel.dataArray) {
                if (cellModel.isSelected) {
                    [reportOptions appendString:[NSString stringWithFormat:@"%@,", cellModel.identifier]];
                }
            }
            //如果有评论内容，举报选项加入参数0
            if (![criticism isEqualToString:@""]) {
                [reportOptions appendString:@"0,"];
            }
            if (![reportOptions isEqualToString:@""]) {
                reportOptions = [[reportOptions substringToIndex:reportOptions.length - 1] copy];
            }
        }
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        if (reportOptions && reportOptions.length > 0) {
            [parameters setValue:reportOptions forKey:@"report"];
        }
        if (self.isCancel) {
            [parameters setValue:@(1) forKey:@"cancel"];
        }
        if (criticism && criticism.length > 0) {
            [parameters setValue:criticism forKey:@"criticism"];
        }
        if (self.isCancel) {
            [parameters setValue:@(1) forKey:@"cancel"];
        }

        if (self.completion) {
            self.completion(parameters);
        }
        self.backWindow = nil;
        self.rootViewController = nil;
        self.actionSheetViewController = nil;
        self.maskView = nil;
        self.completion = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AWEActionSheetFinishedClickNotification object:nil];
        
    }];
}

#pragma mark - get method
- (AWEActionSheetRootViewController *)rootViewController {
    if (!_rootViewController) {
        _rootViewController = [[AWEActionSheetRootViewController alloc] init];
    }
    return _rootViewController;
}

- (UIWindow *)backWindow {
    if (!_backWindow) {
        _backWindow = [[UIWindow alloc] init];
        _backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _backWindow.windowLevel = UIWindowLevelAlert;
        _backWindow.rootViewController = self.actionSheetViewController;
        [_backWindow setBackgroundColor:[UIColor clearColor]];
        _backWindow.hidden = YES;
    }
    return _backWindow;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat temp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = temp;
        }
        _maskView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        _maskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground9];
    }
    return _maskView;
}

- (AWEVideoCommentDataManager *)manager {
    if (!_manager) {
        _manager = [[AWEVideoCommentDataManager alloc] init];
    }
    return _manager;
}

- (AWEActionSheetViewController *)actionSheetViewController {
    if (!_actionSheetViewController) {
        _actionSheetViewController = [[AWEActionSheetViewController alloc] init];
    }
    return _actionSheetViewController;
}

#pragma mark - AWEActionSheetFinishedClickNotification
- (void)clickFinished:(NSNotification *)notification {
    NSDictionary *userInfo = nil;
    NSInteger currentDislikeCount = 0;
    NSInteger currentReportCount = 0;
    NSString *style = @"report";
    NSString *type = nil;
    
    if (self.manager.reportModel) {
        for (AWEActionSheetCellModel *cellModel in self.manager.reportModel.dataArray) {
            if (cellModel.isSelected) {
                currentReportCount++;
            }
        }
    }
    
    if (!self.manager.criticismInput) {
        currentReportCount++;
    }
    
    userInfo = notification.userInfo;
    if (currentDislikeCount > 0 || currentReportCount > 0) {
        type = @"confirm_with_reason";
    }
    else {
        type = @"confirm_invalid";
    }
    
    NSInteger diffReport = currentReportCount - self.lastReportCount;
    NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] init];
    //        [extraDic setValue:@(self.article.itemID.longLongValue) forKey:@"item_id"];
    [extraDic setValue:type forKey:@"click_type"];
    [extraDic setValue:style forKey:@"style"];
    [extraDic setValue:@(diffReport) forKey:@"report"];
    
    self.lastReportCount = currentReportCount;
    
    
    [self dismissController];
}

- (void)clickMask {
    NSInteger currentDislikeCount = 0;
    NSInteger currentReportCount = 0;
    NSString *style = @"report";
    NSString *type = nil;
    
    if (self.manager.reportModel) {
        for (AWEActionSheetCellModel *cellModel in self.manager.reportModel.dataArray) {
            if (cellModel.isSelected) {
                currentReportCount++;
            }
        }
    }
    
    if (!self.manager.criticismInput) {
        currentReportCount++;
    }
    
    if (currentDislikeCount > 0 || currentReportCount > 0) {
        type = @"click_shadow_click_with_reason";
    }
    else {
        type = @"click_shadow_click_invalid";
    }
    
    NSInteger diffReport = currentReportCount - self.lastReportCount;
    NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] init];
    //    [extraDic setValue:@(self.model.itemID.longLongValue) forKey:@"item_id"];
    [extraDic setValue:type forKey:@"click_type"];
    [extraDic setValue:style forKey:@"style"];
    [extraDic setValue:@(diffReport) forKey:@"report"];
    
    self.lastReportCount = currentReportCount;
    [self dismissController];
}

- (void)clickFinished {
    self.isCancel = NO;
    [self dismissController];
}

@end
