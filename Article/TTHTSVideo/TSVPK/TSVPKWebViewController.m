//
//  TSVPKWebViewController.m
//  Article
//
//  Created by 王双华 on 2018/1/16.
//

#import "TSVPKWebViewController.h"
#import "SSWebViewContainer.h"
#import <TTRoute.h>
#import "TSVPublishStatusOriginalData.h"
#import "TSVShortVideoOriginalData.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTPlatformUIModel/TTCategoryDefine.h>
#import "TTUGCPostCenterProtocol.h"
#import "TSVShortVideoPostTaskProtocol.h"
//#import "TSVPublishManager.h"
#import <TTBaseLib/NSStringAdditions.h>
#import "TTNetworkUtilities.h"
#import "UIViewController+NavigationBarStyle.h"
#import <TTAlphaThemedButton.h>
#import <TTThemeManager.h>
#import <UIView+Refresh_ErrorHandler.h>
#import <ExploreOrderedData.h>

@interface TSVPKWebViewController ()<YSWebViewDelegate>

@property (nonatomic, strong) TTAlphaThemedButton *backButton;
@property (nonatomic, strong) SSWebViewContainer * webView;
@property (nonatomic, copy) NSString *requestURL;
@property (nonatomic, strong) NSMutableArray *fakeIDArray;
@property (nonatomic, assign) BOOL hasGotUploadingList;
@property (nonatomic, copy) NSString *challengeGroupID;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, assign) BOOL shouldAppendCommonParam;
@property (nonatomic, assign) TTThemeMode originThemeMode;

@end

@implementation TSVPKWebViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"short_video_pk");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    if (self = [super initWithRouteParamObj:paramObj]) {
        NSDictionary *allParams = paramObj.allParams;
        self.requestURL = [allParams tt_stringValueForKey:@"url"];
        self.challengeGroupID = [allParams tt_stringValueForKey:@"challenge_group_id"];
        self.groupID = [allParams tt_stringValueForKey:@"group_id"];
        self.shouldAppendCommonParam = [allParams tt_boolValueForKey:@"should_append_common_param"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    self.ttHideNavigationBar = YES;

    self.fakeIDArray = [NSMutableArray array];
    ///需要判断是小视频活动
    @weakify(self);
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskBeginNotification object:nil]
//      takeUntil:self.rac_willDeallocSignal]
//     subscribeNext:^(NSNotification * _Nullable notification) {
//         @strongify(self);
//         [self receiveTaskUpdateNotification:notification];
//     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskResumeNotification object:nil]
//      takeUntil:self.rac_willDeallocSignal]
//     subscribeNext:^(NSNotification * _Nullable notification) {
//         @strongify(self);
//         [self receiveTaskUpdateNotification:notification];
//     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskdProgressUpdateNotification object:nil]
//      takeUntil:self.rac_willDeallocSignal]
//     subscribeNext:^(NSNotification * _Nullable notification) {
//         @strongify(self);
//         [self receiveTaskUpdateNotification:notification];
//     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskFailNotification object:nil]
//      takeUntil:self.rac_willDeallocSignal]
//     subscribeNext:^(NSNotification * _Nullable notification) {
//         @strongify(self);
//         [self receiveTaskUpdateNotification:notification];
//     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskSuccessNotification object:nil]
//      takeUntil:self.rac_willDeallocSignal]
//     subscribeNext:^(NSNotification * _Nullable notification) {
//         @strongify(self);
//         [self receiveTaskUpdateNotification:notification];
//     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskDeletedNotification object:nil]
//      takeUntil:self.rac_willDeallocSignal]
//     subscribeNext:^(NSNotification * _Nullable notification) {
//         @strongify(self);
//         [self deleteFakeThreadNotification:notification];
//     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"TSVShortVideoDiggCountSyncNotification" object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification * _Nullable notification) {
         @strongify(self);
         NSDictionary *userInfo = notification.userInfo;
         NSString *groupID = [userInfo tt_stringValueForKey:@"group_id"];
         BOOL userDigg = [userInfo tt_boolValueForKey:@"user_digg"];
         if (userDigg) {
             [self didDigUpdate:groupID];
         } else {
             [self didCancelDiggUpdate:groupID];
         }
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTSVShortVideoDeleteNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification * _Nullable notification) {
         @strongify(self);
         NSDictionary *userInfo = notification.userInfo;
         NSString *groupID = [userInfo tt_stringValueForKey:kTSVShortVideoDeleteUserInfoKeyGroupID];
         [self didDeleteUpdate:groupID];
     }];
    
    [self setupWebView];
    [self setupBackButton];
    [self refreshWebView];
    
    //周玉玮说背景图要黑色，所以只能用要夜间的loading态，日间的跟黑色背景叠加就看不到了，只能都切到夜间，我都是被逼的，实在不想改TTFullScreenLoadingView
    [RACObserve(self, webView.ttLoadingView) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if ([self.webView.ttLoadingView isKindOfClass:[SSThemedView class]]) {
            ((SSThemedView *)self.webView.ttLoadingView).themeMode = SSThemeModeAlwaysNight;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.backButton.frame = CGRectMake(12, 0, 68, 44);
    self.backButton.top = [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 44)];
    self.webView.frame = self.view.bounds;
}

- (void)setupWebView
{
    self.webView = [[SSWebViewContainer alloc] initWithFrame:CGRectZero];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.webView.ssWebView addDelegate:self];
    [self.view addSubview:self.webView];
    [self.webView hiddenProgressView:YES];
    self.webView.ssWebView.disableThemedMask = YES;
    self.webView.ssWebView.colorKey = 5;//背景色全黑
    self.webView.ssWebView.scrollView.bounces = NO;
}

- (void)refreshWebView
{
    NSURL *url = [NSURL tt_URLWithString:self.requestURL
                     joinCommonPatameters:self.shouldAppendCommonParam];
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableArray *queryItems = [NSMutableArray array];
    if (components.queryItems.count > 0) {
        [queryItems addObjectsFromArray:components.queryItems];
    }
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"challenge_group_id" value:self.challengeGroupID]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"group_id" value:self.groupID]];
    components.queryItems = [queryItems copy];
    [self.webView loadRequest:[NSURLRequest requestWithURL:components.URL]];
    
    @weakify(self);
//    [self.webView.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//        int64_t fakeID = [result tt_longValueForKey:@"id"];
//        NSString *concernID = [result tt_stringValueForKey:@"concern_id"];
//        NSString *actionType = [result tt_stringValueForKey:@"type"];
//        if ([actionType isEqualToString:@"retry"]) {
//            [[TSVPublishManager class] retryWithFakeID:fakeID concernID:concernID];
//        } else if ([actionType isEqualToString:@"delete"]) {
//            [[TSVPublishManager class] deleteWithFakeID:fakeID concernID:concernID];
//        }
//        TTR_CALLBACK_SUCCESS
//    } forMethodName:@"TTShortVideoCellActionHandle"];
    
//    [self.webView.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//        @strongify(self);
//        [self insertWithDatas:[TSVPublishManager sharedManager].shortVideoTabPublishOrderedDataArray];
//        self.hasGotUploadingList = YES;
//    } forMethodName:@"TTShortVideoCellGetUploadingList"];
    
    [self.webView.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *groupID = [result tt_stringValueForKey:@"group_id"];
        if (!isEmptyString(groupID)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTSVShortVideoDeleteNotification object:nil userInfo:@{kTSVShortVideoDeleteUserInfoKeyGroupID : groupID}];
        }
    } forMethodName:@"TTShortVideoCellNotifyDeleted"];
}

- (void)setupBackButton
{
    self.backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    self.backButton.imageName = @"white_lefterbackicon_titlebar";
    [self.backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
}

- (void)backButtonClicked:(id)sender
{
    [self dismissSelf];
}

#pragma mark - insert/update to web
- (BOOL)isTaskValid:(id <TSVShortVideoPostTaskProtocol>)task
{
    if (isEmptyString(task.concernID)) {
        return NO;
    }
    if (![task.challengeGroupID isEqualToString:self.challengeGroupID]) {
        return NO;
    }
    return YES;
}

///// 插入硬盘草稿中和内存中的任务
//- (void)insertWithDatas:(NSArray <ExploreOrderedData *> *)datas
//{
//    NSMutableArray *array = [NSMutableArray array];
//    for (ExploreOrderedData *data in datas) {
//        TSVPublishStatusOriginalData *statusData = data.tsvPublishStatusOriginalData;
//        if (statusData && [statusData.challengeGroupID isEqualToString:self.challengeGroupID] && statusData.status != TTForumPostThreadTaskStatusSucceed) {
//            NSDictionary *dict = [statusData dictForJSBridge];
//            NSString *fakeID = [NSString stringWithFormat:@"%lld", statusData.fakeID];
//            if (dict && ![self.fakeIDArray containsObject:fakeID]) {
//                [array addObject:dict];
//                [self.fakeIDArray addObject:fakeID];
//            }
//        }
//    }
//    if (array.count > 0) {
//        [self.webView.ssWebView ttr_fireEvent:@"TTShortVideoCellInsert" data:@{
//                                                                               @"data": array
//                                                                               }];
//    }
//}

//// 发送过程中更新状态
//- (void)receiveTaskUpdateNotification:(NSNotification *)notification
//{
//    if (self.hasGotUploadingList) {
//        /// 草稿加载完成后，才能插入/更新
//        id<TSVShortVideoPostTaskProtocol> task = notification.object;
//        NSDictionary *userInfo = notification.userInfo;
//        [self insertOrUpdateWithTask:task userInfo:userInfo];
//    }
//}

////删除发送失败的帖子
//- (void)deleteFakeThreadNotification:(NSNotification *)notification
//{
//    NSString *fakeID = [notification.userInfo tt_stringValueForKey:TTPostTaskNotificationUserInfoKeyFakeID];
//    NSString *concernID = [notification.userInfo tt_stringValueForKey:TTPostTaskNotificationUserInfoKeyConcernID];
//    if ([self.fakeIDArray containsObject:fakeID]) {
//        [self.fakeIDArray removeObject:fakeID];
//        NSDictionary *params = @{
//                                 @"id": fakeID?: @"",
//                                 @"concern_id": concernID,
//                                 @"status": @"deleted",
//                                 };
//        [self.webView.ssWebView ttr_fireEvent:@"TTShortVideoCellUpdate" data:@{
//                                                                               @"data": [params copy]
//                                                                               }];
//    }
//}

- (void)insertOrUpdateWithTask:(id<TSVShortVideoPostTaskProtocol>)task userInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSDictionary *dict = [self generalDictWithTask:task userInfo:userInfo];
    NSString *fakeID = [NSString stringWithFormat:@"%lld",task.fakeID];
    if (dict) {
        [params addEntriesFromDictionary:dict];
        if (![self.fakeIDArray containsObject:fakeID]) {
            //没有的话，插入到第一个
            [self.fakeIDArray addObject:fakeID];
            [self.webView.ssWebView ttr_fireEvent:@"TTShortVideoCellInsert" data:@{
                                                                                   @"data": @[[params copy]]
                                                                                   }];
        } else {
            [self.webView.ssWebView ttr_fireEvent:@"TTShortVideoCellUpdate" data:@{
                                                                                   @"data": [params copy]
                                                                                   }];
        }
    }
}

- (NSDictionary *)generalDictWithTask:(id<TSVShortVideoPostTaskProtocol>)task userInfo:(NSDictionary *)userInfo
{
    if (!task || ![self isTaskValid:task]) {
        return nil;
    }
    
    //只支持插入小视频
    if (![task isShortVideo]) {
        return nil;
    }
    
    NSString *fakeID = [NSString stringWithFormat:@"%lld",task.fakeID];
    NSString *progress = [NSString stringWithFormat:@"%d%%", (int)(task.uploadProgress * 100.0)];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:fakeID forKey:@"id"];
    [dict setValue:task.concernID forKey:@"concern_id"];
    [dict setValue:progress forKey:@"progress"];
    if (task.status == TTForumPostThreadTaskStatusPosting) {
        //上传中
        [dict setValue:@"uploading" forKey:@"status"];
    } else if (task.status == TTForumPostThreadTaskStatusFailed) {
        //失败
        [dict setValue:@"failed" forKey:@"status"];
    } else {
        //成功
        [dict setValue:@"success" forKey:@"status"];
        [dict setValue:userInfo forKey:@"data"];
        [dict setValue:task.pkStatus forKey:@"pk_status"];
    }
    if (![self.fakeIDArray containsObject:fakeID]) {
        UIImage *image = task.shortVideoCoverImage;
        NSData *imageData = UIImagePNGRepresentation(image);
        [dict setValue:[imageData base64EncodedStringWithOptions:0] forKey:@"image"];
    }
    return [dict copy];
}

- (void)didDigUpdate:(NSString *)groupID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:groupID forKey:@"id"];
    [self.webView.ssWebView ttr_fireEvent:@"updateDiggEvent" data:[dict copy]];
}

- (void)didCancelDiggUpdate:(NSString *)groupID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:groupID forKey:@"id"];
    [self.webView.ssWebView ttr_fireEvent:@"deleteDiggEvent" data:[dict copy]];
}

- (void)didDeleteUpdate:(NSString *)groupID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:groupID forKey:@"id"];
    [self.webView.ssWebView ttr_fireEvent:@"updateDeleteEvent" data:[dict copy]];
}

@end
