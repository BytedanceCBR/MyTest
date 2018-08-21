//
//  TTActionSheetController.m
//  Article
//
//  Created by zhaoqin on 9/1/16.
//
//

#import "TTActionSheetController.h"
#import "TTActionSheetConst.h"
#import "TTActionSheetAnimated.h"
#import "TTActionSheetModel.h"
#import "TTActionSheetManager.h"
#import "TTActionSheetCellModel.h"
#import "TTActionSheetTableController.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTBaseMacro.h"
#import "TTThemeConst.h"
#import "TTTracker.h"

//UIWindow的rootViewController
@interface TTActionSheetViewController : UIViewController

@end

@implementation TTActionSheetViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end

//TTActionSheet的rootViewContrller
@interface TTActionSheetRootViewController : UINavigationController<UINavigationControllerDelegate>

@end

@implementation TTActionSheetRootViewController

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
        return [TTActionSheetAnimated transitionWithTransitionType:TTActionSheetTransitionTypePresent];
    }
    if (operation == UINavigationControllerOperationPop) {
        return [TTActionSheetAnimated transitionWithTransitionType:TTActionSheetTransitionTypeDismiss];
    }
    return nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end


@interface TTActionSheetController ()
@property (nonatomic, strong) UIWindow *backWindow;
@property (nonatomic, strong) TTActionSheetRootViewController *rootViewController;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) void (^completion)(NSDictionary *);
@property (nonatomic, strong) TTActionSheetManager *manager;
@property (nonatomic, strong) TTActionSheetViewController *actionSheetViewController;
@property (nonatomic, assign) NSInteger lastDislikeCount;
@property (nonatomic, assign) NSInteger lastReportCount;
@property (nonatomic, assign) BOOL isCancel;
@end

@implementation TTActionSheetController

static TTActionSheetController *sharedInstance;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTActionSheetFinishedClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastDislikeCount = 0;
        self.lastReportCount = 0;
        
        _backWindow = [[UIWindow alloc] init];
        _backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _backWindow.windowLevel = UIWindowLevelAlert;
        _backWindow.rootViewController = self.actionSheetViewController;
        [_backWindow setBackgroundColor:[UIColor clearColor]];
        _backWindow.hidden = YES;
    }
    return self;
}

- (void)initBaseConfig {
    
    [self.actionSheetViewController.view addSubview:self.maskView];
    [self.actionSheetViewController.view addSubview:self.rootViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickFinished:) name:TTActionSheetFinishedClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)applicationStautsBarDidRotate {
    if (self.actionSheetViewController) {
        [self willTransitionToSize:[UIApplication sharedApplication].keyWindow.bounds.size];
    }
}

- (void)willTransitionToSize:(CGSize)size {
    if ([TTDeviceHelper OSVersionNumber] < 8){
        CGRect frame = CGRectZero;
        frame.size = size;
        self.backWindow.frame = frame;
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    self.maskView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
}

- (void)insertDislikeArray:(NSArray * _Nullable)dislikeArray reportArray:(NSArray * _Nullable)reportArray {
    [self initBaseConfig];
    if (!self.manager.dislikeModel) {
        if (dislikeArray) {
            TTActionSheetModel *dislikeModel = [[TTActionSheetModel alloc] init];
            dislikeModel.type = TTActionSheetTypeDislike;
            dislikeModel.dataArray = dislikeArray;
            [self.manager addActionSheetMode:dislikeModel];
        }
    }
    
    if (!self.manager.reportModel) {
        TTActionSheetModel *reportModel = [[TTActionSheetModel alloc] init];
        reportModel.type = TTActionSheetTypeReport;
        reportModel.dataArray = reportArray;
        [self.manager addActionSheetMode:reportModel];
    }
    
}

- (void)insertReportArray:(NSArray * _Nullable)reportArray {
    [self insertDislikeArray:nil reportArray:reportArray];
}

- (void)insertDislikeArray:(NSArray * _Nullable)dislikeArray {
    [self insertDislikeArray:dislikeArray reportArray:nil];
}

- (void)performWithSource:(TTActionSheetSourceType)source completion:(nullable void (^)(NSDictionary *_Nonnull parameters))completion {
    if (!self.backWindow) {
        _backWindow = [[UIWindow alloc] init];
        _backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _backWindow.windowLevel = UIWindowLevelAlert;
        _backWindow.rootViewController = self.actionSheetViewController;
        [_backWindow setBackgroundColor:[UIColor clearColor]];
        _backWindow.hidden = YES;
    }
    
    [self.backWindow makeKeyAndVisible];
    
    [self configGesture];
    [self configNavigation:source];
    self.completion = completion;
    
    CGRect rect = self.rootViewController.view.frame;
    rect.origin.y += rect.size.height;
    self.rootViewController.view.frame = rect;
    [UIView animateWithDuration:TTActionSheetAnimationDuration animations:^{
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

- (void)configNavigation:(TTActionSheetSourceType)source {
    if (!self.manager.dislikeModel && !self.manager.reportModel) {
        return;
    }
    
    TTActionSheetTableController *tableController = [[TTActionSheetTableController alloc] init];
    tableController.adID = self.adID;
    WeakSelf;
    tableController.trackBlock = ^{
        StrongSelf;
        if (self.trackBlock) {
            self.trackBlock();
        }
    };
    tableController.source = source;
    tableController.manager = self.manager;
    switch (source) {
            case TTActionSheetSourceTypeDislike:
            tableController.model = self.manager.dislikeModel;
            tableController.manager.source = @"dislike_finish";
            break;
            case TTActionSheetSourceTypeReport:
            case TTActionSheetSourceTypeWendaQuestion:
            case TTActionSheetSourceTypeWendaAnswer:
            case TTActionSheetSourceTypeUser:
            tableController.model = self.manager.reportModel;
            tableController.manager.source = @"report_finish";
            break;
    }
    
    [self.rootViewController setViewControllers:@[tableController] animated:NO];
    
    self.rootViewController.navigationBar.clipsToBounds = YES;
    
}

- (void)dismissController {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [UIView animateWithDuration:TTActionSheetAnimationDuration animations:^{
        CGRect rect = self.rootViewController.view.frame;
        rect.origin.y += rect.size.height;
        self.rootViewController.view.frame = rect;
    } completion:^(BOOL finished) {
        self.backWindow.hidden = YES;
        self.backWindow = nil;
        NSMutableString *dislikeOptions = [[NSMutableString alloc] init];
        if (self.manager.dislikeModel) {
            for (TTActionSheetCellModel *cellModel in self.manager.dislikeModel.dataArray) {
                if (cellModel.isSelected) {
                    [dislikeOptions appendString:[NSString stringWithFormat:@"%@,", cellModel.identifier]];
                }
            }
            if (![dislikeOptions isEqualToString:@""]) {
                dislikeOptions = [[dislikeOptions substringToIndex:dislikeOptions.length - 1] copy];
            }
        }
        
        NSString *criticism = [[self.manager criticismInput] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableString *reportOptions = [[NSMutableString alloc] init];
        if (self.manager.reportModel) {
            for (TTActionSheetCellModel *cellModel in self.manager.reportModel.dataArray) {
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
        if (dislikeOptions && dislikeOptions.length > 0) {
            [parameters setValue:dislikeOptions forKey:@"dislike"];
        }
        if (reportOptions && reportOptions.length > 0) {
            [parameters setValue:reportOptions forKey:@"report"];
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
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TTActionSheetFinishedClickNotification object:nil];
        
    }];
}

#pragma mark - get method
- (TTActionSheetRootViewController *)rootViewController {
    if (!_rootViewController) {
        _rootViewController = [[TTActionSheetRootViewController alloc] init];
    }
    return _rootViewController;
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

- (TTActionSheetManager *)manager {
    if (!_manager) {
        _manager = [[TTActionSheetManager alloc] init];
        _manager.adID = self.adID;
    }
    return _manager;
}

- (TTActionSheetViewController *)actionSheetViewController {
    if (!_actionSheetViewController) {
        _actionSheetViewController = [[TTActionSheetViewController alloc] init];
    }
    return _actionSheetViewController;
}

#pragma mark - TTActionSheetFinishedClickNotification
- (void)clickFinished:(NSNotification *)notification {
    if (self.isSendTrack && self.itemID) {
        NSDictionary *userInfo = nil;
        NSInteger currentDislikeCount = 0;
        NSInteger currentReportCount = 0;
        NSString *style = @"report_and_dislike";
        NSString *type = nil;
        
        if (self.manager.dislikeModel) {
            for (TTActionSheetCellModel *cellModel in self.manager.dislikeModel.dataArray) {
                if (cellModel.isSelected) {
                    currentDislikeCount++;
                }
            }
        }
        else {
            style = @"report";
        }
        
        if (self.manager.reportModel) {
            for (TTActionSheetCellModel *cellModel in self.manager.reportModel.dataArray) {
                if (cellModel.isSelected) {
                    currentReportCount++;
                }
            }
        }
        
        if (!isEmptyString(self.manager.criticismInput)) {
            currentReportCount++;
        }
        
        userInfo = notification.userInfo;
        if (currentDislikeCount > 0 || currentReportCount > 0) {
            type = @"confirm_with_reason";
        }
        else {
            type = @"confirm_invalid";
        }
        
        NSInteger diffDislike = currentDislikeCount - self.lastDislikeCount;
        NSInteger diffReport = currentReportCount - self.lastReportCount;
        NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] init];
        [extraDic setValue:self.itemID forKey:@"item_id"];
        [extraDic setValue:type forKey:@"click_type"];
        [extraDic setValue:style forKey:@"style"];
        [extraDic setValue:@(diffDislike) forKey:@"dislike"];
        [extraDic setValue:@(diffReport) forKey:@"report"];
        if ([self.adID integerValue] > 0) {
            [extraDic setObject:self.adID forKey:@"aid"];
        }
        if (self.extra) {
            [extraDic addEntriesFromDictionary:self.extra];
        }
        ttTrackEventWithCustomKeys(@"detail", self.manager.source, self.groupID, self.source, extraDic);
        
        self.lastDislikeCount = currentDislikeCount;
        self.lastReportCount = currentReportCount;
    }
    
    [self dismissController];
}

- (void)clickMask {
    if (self.isSendTrack && self.itemID) {
        NSInteger currentDislikeCount = 0;
        NSInteger currentReportCount = 0;
        NSString *style = @"report_and_dislike";
        NSString *type = nil;
        
        if (self.manager.dislikeModel) {
            for (TTActionSheetCellModel *cellModel in self.manager.dislikeModel.dataArray) {
                if (cellModel.isSelected) {
                    currentDislikeCount++;
                }
            }
        }
        else {
            style = @"report";
        }
        
        if (self.manager.reportModel) {
            for (TTActionSheetCellModel *cellModel in self.manager.reportModel.dataArray) {
                if (cellModel.isSelected) {
                    currentReportCount++;
                }
            }
        }
        
        if (!isEmptyString(self.manager.criticismInput)) {
            currentReportCount++;
        }
        
        if (currentDislikeCount > 0 || currentReportCount > 0) {
            type = @"click_shadow_click_with_reason";
        }
        else {
            type = @"click_shadow_click_invalid";
        }
        
        NSInteger diffDislike = currentDislikeCount - self.lastDislikeCount;
        NSInteger diffReport = currentReportCount - self.lastReportCount;
        NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] init];
        [extraDic setValue:self.itemID forKey:@"item_id"];
        [extraDic setValue:type forKey:@"click_type"];
        [extraDic setValue:style forKey:@"style"];
        [extraDic setValue:@(diffDislike) forKey:@"dislike"];
        [extraDic setValue:@(diffReport) forKey:@"report"];
        if ([self.adID integerValue] > 0) {
            [extraDic setObject:self.adID forKey:@"aid"];
        }
        if (self.extra) {
            [extraDic addEntriesFromDictionary:self.extra];
        }
        ttTrackEventWithCustomKeys(@"detail", self.manager.source, self.groupID, self.source, extraDic);
        
        self.lastDislikeCount = currentDislikeCount;
        self.lastReportCount = currentReportCount;
    }
    [self dismissController];
}

- (void)clickFinished {
    self.isCancel = NO;
    [self dismissController];
}

@end
