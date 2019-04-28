//
//  ExploreWidgetBaseViewController.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-10.
//
//

#import "ExploreWidgetBaseViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "ExploreExtenstionDataHelper.h"
#import "ExploreWidgetFetchListManager.h"
#import "ExploreWidgetView.h"
#import "TTWidgetTool.h"
#import "ExploreWidgetImpressionManager.h"

@interface ExploreWidgetBaseViewController ()<NCWidgetProviding, ExploreWidgetFetchListManagerDelegate, ExploreWidgetViewDelegate>
{
    BOOL _needRefreshUI;
    BOOL _isAppearing;
}
@property(nonatomic, retain)ExploreWidgetFetchListManager * listManger;
@property(nonatomic, retain)ExploreWidgetView * widgetView;
@property(nonatomic, retain)ExploreWidgetImpressionManager * impressionManager;
@end

@implementation ExploreWidgetBaseViewController

- (void)dealloc
{
    _listManger.delegate = nil;
    _widgetView.deleagte = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([TTWidgetTool OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
        if ([self.extensionContext widgetActiveDisplayMode] == NCWidgetDisplayModeCompact) {
            self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeCompact].height);
        }
#pragma clang diagnostic pop
        else {
            self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), [ExploreWidgetView preferredInitHeight]);
        }
    }
    else {
        self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), [ExploreWidgetView preferredInitHeight]);
    }
    
    self.impressionManager = [[ExploreWidgetImpressionManager alloc] init];
    _needRefreshUI = YES;
    self.listManger = [[ExploreWidgetFetchListManager alloc] init];
    _listManger.delegate = self;
    self.widgetView = [[ExploreWidgetView alloc] initWithFrame:self.view.bounds];
    _widgetView.deleagte = self;
    [self.view addSubview:_widgetView];
    
    
    if ([_listManger.itemModels count] == 0) {
        [self refreshEmptyView:ExploreWidgetEmptyViewTypeLoading];
    }
    else {
        [self refreshListView];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isAppearing = YES;
    [_impressionManager startRecordItems:_listManger.itemModels];
    [_listManger tryFetchRequest];
    
    if ([TTWidgetTool OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
#pragma clang diagnostic pop
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isAppearing = NO;
    [_impressionManager endRecord];
    [_impressionManager save];
    //[[SDImageCache sharedImageCache] cleanDisk];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    if (_needRefreshUI) {
        if ([_listManger.itemModels count] > 0) {
            [self refreshListView];
        }
        _needRefreshUI = NO;
        completionHandler(NCUpdateResultNewData);
        NSLog(@"***widget widgetPerformUpdateWithCompletionHandler NCUpdateResultNewData");
    }
    else {
        completionHandler(NCUpdateResultNoData);
        NSLog(@"***widget widgetPerformUpdateWithCompletionHandler NCUpdateResultNoData");
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {

    if ([_listManger.itemModels count] == 0) {
        self.preferredContentSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeCompact];
    }
    else {
        if (activeDisplayMode == NCWidgetDisplayModeCompact) {
            self.preferredContentSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeCompact];
            [self refreshListView];
        }
        else {
            self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), [ExploreWidgetView heightForModels:_listManger.itemModels]);
            [self refreshListView];
        }
    }
    [self.widgetView showOpenHostAppButton:(activeDisplayMode == NCWidgetDisplayModeExpanded)];
}
#pragma clang diagnostic pop

#pragma mark -- 

- (void)refreshEmptyView:(ExploreWidgetEmptyViewType)type
{
    if ([_listManger.itemModels count] == 0) {
        CGFloat height = [ExploreWidgetView heightForModels:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
            _widgetView.frame = self.view.bounds;
            [_widgetView refreshEmptyView:type];
        });
    }
}

- (void)refreshListView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = [ExploreWidgetView heightForModels:_listManger.itemModels];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        NCWidgetDisplayMode currentMode = NCWidgetDisplayModeExpanded;
#pragma clang diagnostic pop
        NSInteger maxCellCount = [_listManger.itemModels count];
        
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            currentMode = [self.extensionContext widgetActiveDisplayMode];
            CGSize maxSize = [self.extensionContext widgetMaximumSizeForDisplayMode:currentMode];
#pragma clang diagnostic pop
            
            if (height > maxSize.height) {
                maxCellCount = [ExploreWidgetView maxModelCountForHeightLimit:maxSize.height models:_listManger.itemModels fixedHeight:&height];
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            if (currentMode == NCWidgetDisplayModeCompact) {
#pragma clang diagnostic pop
                height = maxSize.height;
            }
        }
        
        self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
        
        CGRect frame = self.view.bounds;
        frame.size.height = height;
        _widgetView.frame = frame;
        [_widgetView refreshWithModels:_listManger.itemModels widgetDisplayMode:currentMode maxCellCount:maxCellCount];
        if (_isAppearing) {
            [_impressionManager startRecordItems:_listManger.itemModels];
        }
        else {
            [_impressionManager endRecord];
        }
        
    });
}

#pragma mark -- ExploreWidgetFetchListManagerDelegate

- (void)widgetLoadDataFailed:(ExploreWidgetFetchListManager *)manager
{
    if (manager == _listManger) {
        [self refreshEmptyView:ExploreWidgetEmptyViewTypeError];
    }
}

- (void)widgetLoadDataFinish:(ExploreWidgetFetchListManager *)manager
{
    if (manager == _listManger) {
        if ([_listManger.itemModels count] == 0) {
            [self refreshEmptyView:ExploreWidgetEmptyViewTypeError];
        }
        else {
            [self refreshListView];
        }
        _needRefreshUI = YES;
    }
}

#pragma mark -- ExploreWidgetViewDelegate

- (void)widgetView:(ExploreWidgetView *)widgetView openURL:(NSString *)urlStr
{
    if (widgetView == _widgetView && urlStr) {
        [self openCustomURLStr:urlStr];
    }
}

- (void)widgetViewClickErrorEmptyButtn:(ExploreWidgetView *)widgetView
{
    [_listManger fetchRequest];
}

#pragma mark -- util

- (void)openCustomURLStr:(NSString *)url
{
    [self.extensionContext openURL:[NSURL URLWithString:url] completionHandler:nil];
}


@end
