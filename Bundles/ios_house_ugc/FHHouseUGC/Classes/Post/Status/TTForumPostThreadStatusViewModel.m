//
//  TTForumPostThreadStatusViewModel.m
//  Article
//
//  Created by 徐霜晴 on 16/10/9.
//
//

#import "TTForumPostThreadStatusViewModel.h"
#import "TTPostThreadCenter.h"
#import "TTPostThreadTask.h"
#import "TTUGCDefine.h"
#import "FRImageInfoModel.h"
#import "FRUploadImageModel.h"
#import "TTPostThreadDefine.h"
#import "TTIndicatorView.h"
#import "TTArticleCategoryManager.h"
#import "TTThemedAlertController.h"
#import <TTKitchen/TTKitchen.h>
#import "TTAccountAlertView.h"

#import "TTAccountBusiness.h"
#import "TTArticleTabBarController.h"//这个不OK
#import "TTForumPostThreadToPageViewModel.h"
#import "TTTabBarProvider.h"
//#import "TTPostVideoRedpackDelegate.h"
#import "TTTabBarProvider.h"
#import <TTUIWidget/TTBubbleView.h>
#import "TTExploreMainViewController.h"//这个不OK
#import "NewsBaseDelegate.h"//这个不OK，为啥还要依赖这个？？？
#import "ArticleMobileViewController.h"//这个不OK
#import "ExploreLogicSetting.h"//这个不OK
#import <TTPostBase/TTPostTaskCenter.h>
#import "TTStringHelper.h"
#import "TTArticleCategoryManager.h"
#import "ToastManager.h"
#import "FHEnvContext.h"
#import "FHPostUGCProgressView.h"
#import "FHMessageNotificationManager.h"
#import "FHMessageNotificationTipsManager.h"

@interface TTPostThreadTaskStatusModel ()

@property (nonatomic, strong) NSMutableArray <TTPostThreadTaskProgressBlock> * progressBlocks;

@end

@implementation TTPostThreadTaskStatusModel

- (instancetype)initWithPostThreadTask:(TTPostTask *)task {
    self = [super init];
    if (self) {
        self.title = task.title;
        self.titleRichSpan = task.titleRichSpan;
        if (isEmptyString(self.title)) {
            self.title = task.content;
            self.titleRichSpan = task.contentRichSpans;
        }
        self.status = task.status;
        self.uploadingProgress = task.uploadProgress;
        self.fakeThreadId = task.fakeThreadId;
        self.concernID = task.concernID;
        self.extraTrack = task.extraTrack;
        self.taskType = task.taskType;
        self.coverImage = [task coverImage];
        switch (task.taskType) {
            case TTPostTaskTypeVideo:
            {
                
                if (isEmptyString(self.title)) {
                    self.title = @"分享视频";
                    self.titleRichSpan = nil;
                }
            }
                break;
            case TTPostTaskTypeThread:
            {
                if (isEmptyString(self.title)) {
                    self.title = @"分享图片";
                    self.titleRichSpan = nil;
                }
            }
                break;
        }
        self.repostType = task.repostType;
        if ([[task.finishError domain] isEqualToString:kFRPostThreadErrorDomain] && ([task.finishError code] == TTPostThreadErrorCodeNoNetwork || [task.finishError code] == TTPostThreadErrorCodeUploadImgError || [task.finishError code] == TTPostThreadErrorCodeAccountChanged)) {
            //没有网络
            self.failureWordingType = TTForumPostThreadFailureWordingNetworkError;
        }
        else if ([[task.finishError domain] isEqualToString:NSURLErrorDomain] || [[task.finishError domain] isEqualToString:kTTNetworkErrorDomain]) {
            //没有网络
            self.failureWordingType = TTForumPostThreadFailureWordingNetworkError;
        }
        else {
            self.failureWordingType = TTForumPostThreadFailureWordingServiceError;
        }
    }
    return self;
}

- (void)addProgressBlock:(TTPostThreadTaskProgressBlock)progressBlock {
    if (self.progressBlocks == nil) {
        self.progressBlocks = [NSMutableArray array];
    }
    [self.progressBlocks addObject:progressBlock];
}

- (void)removeProgressBlock:(TTPostThreadTaskProgressBlock)progressBlock {
    if (!progressBlock) {
        return;
    }
    [self.progressBlocks removeObject:progressBlock];
}

- (NSArray <TTPostThreadTaskProgressBlock> *)getProgressBlocks {
    if (self.progressBlocks.count == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:self.progressBlocks];
}

@end

@interface TTForumPostThreadStatusViewModel ()
<
TTAccountMulticastProtocol
>

@property (nonatomic, strong, readwrite) NSMutableArray <TTPostThreadTaskStatusModel *> * mainTaskStatusModels;
@property (nonatomic, strong, readwrite) NSMutableArray <TTPostThreadTaskStatusModel *> * followTaskStatusModels;
@property (nonatomic, strong, readwrite) NSMutableArray <TTPostThreadTaskStatusModel *> * weitouTiaoTaskStatusModels;

//@property (nonatomic, strong) TTBubbleView *bubbleView;

@property (nonatomic, assign) BOOL isRetryAlertViewShown;
@property (nonatomic, copy)     NSString       *cityName;

@end

@implementation TTForumPostThreadStatusViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isEnterFollowPageFromPostNotification = NO;
        self.isEnterHomeTabFromPostNotification = NO;
        [self registerNotifications];
        [self loadStatusModelsWithCompletionBlock:^{
            if([FHPostUGCProgressView sharedInstance].refreshViewBlk) {
                [FHPostUGCProgressView sharedInstance].refreshViewBlk();
            }
        }];
        self.cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    }
    return self;
}

// 切换城市 清空失败的帖子数据
- (void)checkCityPostData {
    NSString *currentCityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    if (currentCityName.length > 0 && ![currentCityName isEqualToString:self.cityName] && self.followTaskStatusModels.count > 0) {
        // 删除本地数据
        [self.followTaskStatusModels enumerateObjectsUsingBlock:^(TTPostThreadTaskStatusModel * _Nonnull statusModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [[TTPostThreadCenter sharedInstance_tt] removeTaskForFakeThreadID:statusModel.fakeThreadId concernID:statusModel.concernID];
        }];
        [self.followTaskStatusModels removeAllObjects];
        // 刷新UI 数据
        [[FHPostUGCProgressView sharedInstance] updatePostData];
    }
    //切城市 消息系统
    if(currentCityName.length > 0 && ![currentCityName isEqualToString:self.cityName]){
        [[FHMessageNotificationTipsManager sharedManager] clearTipsModel];
        [[FHMessageNotificationManager sharedManager] startPeriodicalFetchUnreadMessageNumberWithChannel:nil];
    }
    if (currentCityName.length > 0) {
        self.cityName = currentCityName;
    }
}

- (void)dealloc {
    [self removeNotifications];
    [TTAccount removeMulticastDelegate:self];
}

#pragma mark - Initialize


- (BOOL)isTaskConcernIdValid:(NSString *)concernID{
    
    if (isEmptyString(concernID) || (![concernID isEqualToString:kTTMainConcernID] && (![concernID isEqualToString:KTTFollowPageConcernID]) && ![concernID isEqualToString:kTTWeitoutiaoConcernID])) {
        return NO;
    }
    return YES;
}

- (NSMutableArray<TTPostThreadTaskStatusModel *> *)loadStatusModelWithConcernId:(NSString *)concernId WithTasks:(NSArray<TTPostTask *> *)tasks{
    
    NSMutableArray<TTPostThreadTaskStatusModel *> *taskStatusModels = [[NSMutableArray alloc] initWithCapacity:tasks.count];
    
    [tasks enumerateObjectsUsingBlock:^(TTPostTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        task.isPosting = YES;
        if (!task.finishError) {
            //默认错误信息
            task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeNoNetwork userInfo:nil];
        }
        TTPostThreadTaskStatusModel *taskStatusModel = [[TTPostThreadTaskStatusModel alloc] initWithPostThreadTask:task];
        [taskStatusModels addObject:taskStatusModel];
    }];
    
    return taskStatusModels;
}

- (void)loadStatusModelsWithCompletionBlock:(void (^)(void))completionBlock{
    
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<TTPostTask *> *mainTasks = [TTPostTask fetchTasksFromDiskForConcernID:kTTMainConcernID];
        NSArray<TTPostTask *> *followTasks = [TTPostTask fetchTasksFromDiskForConcernID:KTTFollowPageConcernID];
        NSArray<TTPostTask *> *weitoutiaoTasks = [TTPostTask fetchTasksFromDiskForConcernID:kTTWeitoutiaoConcernID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;
            self.mainTaskStatusModels = [self loadStatusModelWithConcernId:kTTMainConcernID WithTasks:mainTasks];
            self.followTaskStatusModels = [self loadStatusModelWithConcernId:KTTFollowPageConcernID WithTasks:followTasks];
            self.weitouTiaoTaskStatusModels = [self loadStatusModelWithConcernId:kTTWeitoutiaoConcernID WithTasks:weitoutiaoTasks];
            
            
            if (completionBlock) {
                completionBlock();
            }
        });
    });
}

- (NSMutableArray<TTPostThreadTaskStatusModel *> *)loadLoginStatusModelWithConcernId:(NSString *)concernId WithTasks:(NSArray<TTPostTask *> *)tasks{
    
    NSMutableArray<TTPostThreadTaskStatusModel *> *taskStatusModels = [[NSMutableArray alloc] initWithCapacity:tasks.count];
    WeakSelf;
    [tasks enumerateObjectsUsingBlock:^(TTPostTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TTPostTask *resultTask = [[TTPostTaskCenter sharedInstance] asyncGetMemoryTaskWithID:task.taskID concernID:task.concernID];
        
        if (!resultTask) {
            task.isPosting = YES;
            if (!task.finishError) {
                //默认错误信息
                task.finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeNoNetwork userInfo:nil];
            }
            TTPostThreadTaskStatusModel *taskStatusModel = [[TTPostThreadTaskStatusModel alloc] initWithPostThreadTask:task];
            [taskStatusModels addObject:taskStatusModel];
        }
    }];
    
    return taskStatusModels;
}

- (void)loadLoginStatusModelsWithCompletionBlock:(void (^)(void))completionBlock {
    
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<TTPostTask *> *mainTasks = [TTPostTask fetchTasksFromDiskForConcernID:kTTMainConcernID];
        NSArray<TTPostTask *> *followTasks = [TTPostTask fetchTasksFromDiskForConcernID:KTTFollowPageConcernID];
        NSArray<TTPostTask *> *weitoutiaoTasks = [TTPostTask fetchTasksFromDiskForConcernID:kTTWeitoutiaoConcernID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;
            [self.mainTaskStatusModels addObjectsFromArray:[self loadLoginStatusModelWithConcernId:kTTMainConcernID WithTasks:mainTasks]];
            [self.followTaskStatusModels addObjectsFromArray:[self loadLoginStatusModelWithConcernId:KTTFollowPageConcernID WithTasks:followTasks]];
            [self.weitouTiaoTaskStatusModels addObjectsFromArray:[self loadLoginStatusModelWithConcernId:kTTWeitoutiaoConcernID WithTasks:weitoutiaoTasks]];
            
            if (completionBlock) {
                completionBlock();
            }
        });
    });
}

- (NSMutableArray *)modelsArrayWithConcernID:(NSString *)concernID{
    
    if (![self isTaskConcernIdValid:concernID]) {
        return nil;
    }
    
    if ([concernID isEqualToString:kTTMainConcernID]) {
        return self.mainTaskStatusModels;
    }
    else if ([concernID isEqualToString:KTTFollowPageConcernID]){
        return self.followTaskStatusModels;
    }
    else if ([concernID isEqualToString:kTTWeitoutiaoConcernID]){
        return self.weitouTiaoTaskStatusModels;
    }
    
    return nil;
}

- (NSString *)modelNamesArrayWithConcernID:(NSString *)concernID{
    
    if (![self isTaskConcernIdValid:concernID]) {
        return nil;
    }
    
    if ([concernID isEqualToString:kTTMainConcernID]) {
        return @"mainTaskStatusModels";
    }
    else if ([concernID isEqualToString:KTTFollowPageConcernID]){
        return @"followTaskStatusModels";
    }
    else if ([concernID isEqualToString:kTTWeitoutiaoConcernID]){
        return @"weitouTiaoTaskStatusModels";
    }
    
    return nil;
}


#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSendingNotification:) name:kTTForumPostingThreadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeThreadSendingNotification:) name:kTTForumResumeThreadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadFailNotification:) name:kTTForumPostThreadFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccessNotification:) name:kTTForumPostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFakeThreadNotification:) name:kTTForumDeleteFakeThreadNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadActionFinshNotification:) name:kTTForumPostingThreadActionFinishNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryHasChangeNotification:) name:kAritlceCategoryGotFinishedNotification object:nil];
    
    
    [TTAccount addMulticastDelegate:self];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//开始进入发送队列
- (void)postThreadSendingNotification:(NSNotification *)notification{
    
    TTPostTask *task = notification.object;
    if (!task || ![self isTaskConcernIdValid:task.concernID]) {
        return;
    }
    
    NSMutableArray *modelsArray = [self modelsArrayWithConcernID:task.concernID];
    NSString *modelName = [self modelNamesArrayWithConcernID:task.concernID];
    
    
    __block NSInteger index = NSNotFound;
    [modelsArray enumerateObjectsUsingBlock:^(TTPostThreadTaskStatusModel * _Nonnull statusModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (statusModel.fakeThreadId == task.fakeThreadId) {
            index = idx;
            *stop = YES;
        }
    }];
    
    TTPostThreadTaskStatusModel *statusModel = [[TTPostThreadTaskStatusModel alloc] initWithPostThreadTask:task];
    
    if (!isEmptyString(modelName) && statusModel) {
        NSMutableArray *arr = [self mutableArrayValueForKey:modelName];
        if (arr) {
            if (index == NSNotFound) {
                [[self mutableArrayValueForKey:modelName] addObject:statusModel];
            }
            else {
                [[self mutableArrayValueForKey:modelName] setObject:statusModel atIndexedSubscript:index];
            }
        }
    }
    
    if (self.statusChangeBlk) {
        self.statusChangeBlk();
    }
}


//正式开始发送
- (void)resumeThreadSendingNotification:(NSNotification *)notification{
    
    TTPostThreadTask *task = notification.object;
    if (!task || ![self isTaskConcernIdValid:task.concernID]) {
        return;
    }
    
    NSMutableArray *modelsArray = [self modelsArrayWithConcernID:task.concernID];
    
    [modelsArray enumerateObjectsUsingBlock:^(TTPostThreadTaskStatusModel * _Nonnull statusModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (statusModel.fakeThreadId == task.fakeThreadId) {
            task.progressBlock = ^(CGFloat progress) {
                statusModel.uploadingProgress = progress;
                [[statusModel getProgressBlocks] enumerateObjectsUsingBlock:^(TTPostThreadTaskProgressBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj(progress);
                }];
            };
        }
    }];
    
    if (self.statusChangeBlk) {
        self.statusChangeBlk();
    }
}

// 发帖失败
- (void)postThreadFailNotification:(NSNotification *)notification {
    
    TTPostTask *task = notification.object;
    if (!task || ![self isTaskConcernIdValid:task.concernID]) {
        return;
    }
    
    NSMutableArray *modelsArray = [self modelsArrayWithConcernID:task.concernID];
    NSString *modelName = [self modelNamesArrayWithConcernID:task.concernID];
    
    __block NSInteger index = NSNotFound;
    
    [modelsArray enumerateObjectsUsingBlock:^(TTPostThreadTaskStatusModel * _Nonnull statusModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (statusModel.fakeThreadId == task.fakeThreadId) {
            index = idx;
            *stop = YES;
        }
    }];
    
    TTPostThreadTaskStatusModel *statusModel = [[TTPostThreadTaskStatusModel alloc] initWithPostThreadTask:task];
    
    if (isEmptyString(modelName) || statusModel == nil) {
        return;
    }
    
    NSMutableArray *arr = [self mutableArrayValueForKey:modelName];
    if (arr == nil) {
        return;
    }
    
    if (index == NSNotFound) {
        [[self mutableArrayValueForKey:modelName] addObject:statusModel];
    }
    else {
        [[self mutableArrayValueForKey:modelName] setObject:statusModel atIndexedSubscript:index];
    }
    
    ArticleMobilePiplineCompletion sendLogic = ^(ArticleLoginState state) {
        
        if (task && task.taskType == TTPostTaskTypeVideo) {

        }
        else if (task && task.taskType == TTPostTaskTypeThread) {
            [[TTPostThreadCenter sharedInstance_tt] resentThreadForFakeThreadID:task.fakeThreadId concernID:task.concernID];
        }
    };
   
    if (self.statusChangeBlk) {
        self.statusChangeBlk();
    }
}



// 发帖成功
- (void)postThreadSuccessNotification:(NSNotification *)notification {
    
    TTPostTask *task = notification.object;
    if (!task || ![self isTaskConcernIdValid:task.concernID]) {
        return;
    }
    
    NSMutableArray *modelsArray = [self modelsArrayWithConcernID:task.concernID];
    NSString *modelName = [self modelNamesArrayWithConcernID:task.concernID];
    
    __block NSInteger index = NSNotFound;
    [modelsArray enumerateObjectsUsingBlock:^(TTPostThreadTaskStatusModel * _Nonnull statusModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (statusModel.fakeThreadId == task.fakeThreadId) {
            index = idx;
            *stop = YES;
        }
    }];
    
    
    if (isEmptyString(modelName)) {
        return;
    }
    
    if (index != NSNotFound) {
        [[self mutableArrayValueForKey:modelName] removeObjectAtIndex:index];
    }
    
    if (task.repostType == TTThreadRepostTypeNone) {
        BOOL hasRedPacket = NO;
        if ([task shouldShowRedPacket]) {
            hasRedPacket = YES;
        }
        if (hasRedPacket) {
            //不弹发送成功的toast
        }
    }
    else {
        // [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[TTKitchen getString:kTTKUGCRepostWordingRepostSuccessToast] indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        [[ToastManager manager] showToast:@"发帖成功"];
    }
    
    if (self.statusChangeBlk) {
        self.statusChangeBlk();
    }
}


//删除发送失败的帖子
- (void)deleteFakeThreadNotification:(NSNotification *)notification {
    
    NSString *concernID = [notification.userInfo valueForKey:kTTForumPostThreadConcernID];
    if (![self isTaskConcernIdValid:concernID]) {
        return;
    }
    
    NSMutableArray *modelsArray = [self modelsArrayWithConcernID:concernID];
    NSString *modelName = [self modelNamesArrayWithConcernID:concernID];
    
    int64_t threadID = [notification.userInfo tt_longlongValueForKey:kTTForumPostThreadFakeThreadID];
    
    __block NSInteger index = NSNotFound;
    [modelsArray enumerateObjectsUsingBlock:^(TTPostThreadTaskStatusModel * _Nonnull statusModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (statusModel.fakeThreadId == threadID) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (isEmptyString(modelName)) {
        return;
    }
    
    if (index != NSNotFound) {
        [[self mutableArrayValueForKey:modelName] removeObjectAtIndex:index];
    }
    
    if (self.statusChangeBlk) {
        self.statusChangeBlk();
    }
}


- (void)postThreadActionFinshNotification:(NSNotification *)notification{
    
    //发布器位于主发布器位置，此时肯定为发布帖子，排除了转发的情况
    TTPostUGCEnterFrom entrance = [notification.userInfo tt_intValueForKey:@"entrance"];
    NSString *cid = [notification.userInfo tt_stringValueForKey:@"cid"];
    BOOL isShortVideo = [notification.userInfo tt_boolValueForKey:@"is_short_video"];
    BOOL stayCurrentPageAfterPost = [notification.userInfo tt_boolValueForKey:@"stay_after_post"];
    NSString *categoryID = [notification.userInfo tt_stringValueForKey:@"category_id"];
    if ((entrance != TTPostUGCEnterFromCategory && entrance != TTPostUGCEnterFromSpringFestival && !isShortVideo) || isEmptyString(cid) || ![cid isEqualToString:KTTFollowPageConcernID]) {
        return;
    }

    NSInteger followCategoryIndex = -1;//[[TTArticleCategoryManager sharedManager] indexOfCategoryInSubScribedCategories:kTTFollowCategoryID];
    //不在已订阅频道时，进行关注频道的生成并强制插入
    if (followCategoryIndex == NSNotFound) {
        TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:kTTFollowCategoryID];
        if (!categoryModel) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:kTTFollowCategoryID forKey:@"category"];
            [dict setValue:KTTFollowPageConcernID forKey:@"concern_id"];
            [dict setValue:@"关注" forKey:@"name"];
            [dict setValue:@(4) forKey:@"type"];
            [dict setValue:@"" forKey:@"web_url"];
            [dict setValue:@(0) forKey:@"flags"];
            categoryModel = [TTArticleCategoryManager insertCategoryWithDictionary:dict];
        }

//        [[TTArticleCategoryManager sharedManager] insertCategoryToSubScribedCategories:categoryModel toOrderIndex:0];
        [[TTArticleCategoryManager sharedManager] save];

        //向后端同步订阅的频道数据
        [[TTArticleCategoryManager sharedManager] startGetCategory:YES];
    }
    BOOL needNavToUploadCategory = [notification.userInfo tt_boolValueForKey:@"need_navto_upload_category"];//小游戏录屏上传不需要进行切换至首页关注频道
    //tabbar此时不在首页频道时才进行切换，否则不切换（若切换会引发刷新）,
    if (![[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey] && !(isShortVideo && !needNavToUploadCategory) && !stayCurrentPageAfterPost) {
        
        //tabbar切换至首页频道
        self.isEnterHomeTabFromPostNotification = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil userInfo:@{@"tag":kTTTabHomeTabKey}];
        self.isEnterHomeTabFromPostNotification = NO;
    }
    
    //关注频道不是当前的首页选择频道时进行切换，否则不切换（若切换会引发刷新）
    if (![[TTArticleCategoryManager currentSelectedCategoryID] isEqualToString:kTTFollowCategoryID] && !stayCurrentPageAfterPost) {
        
        //获取关注频道
        TTCategory *followCategory = [TTArticleCategoryManager categoryModelByCategoryID:kTTFollowCategoryID];
        
        //切换关注频道
        if (followCategory) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:followCategory forKey:@"model"];
            
            self.isEnterFollowPageFromPostNotification = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryManagementViewCategorySelectedNotification object:self userInfo:userInfo];
        }
    }

    if (followCategoryIndex == NSNotFound) {
//        TTExploreMainViewController *mainListView = [(NewsBaseDelegate *)[[UIApplication sharedApplication] delegate] exploreMainViewController];
//
//        CGPoint tipsAnchorPointInMainListView = [self bubbleViewAnchorPoint];
//
//        self.bubbleView = [[TTBubbleView alloc] initWithAnchorPoint:tipsAnchorPointInMainListView imageName:nil tipText:@"在这里与好友互动" attributedText:nil arrowDirection:TTBubbleViewArrowUp lineHeight:0 viewType:0];
//
//        [mainListView.view addSubview:self.bubbleView];
//
//        WeakSelf;
//        [self.bubbleView showTipWithAnimation:YES
//                           automaticHide:YES
//                 animationCompleteHandle:nil
//                          autoHideHandle:^{
//                              StrongSelf;
//                              self.bubbleView = nil;
//                          } tapHandle:nil];
    }
    
}


- (void)receiveCategoryHasChangeNotification:(NSNotification*)notification
{
//    if ([TTKitchen getBOOL:kTTKUGCPostThreadRevalFollowChannel]) {
//
//    }
}

- (NSUInteger)selectIndexInTabbarController {
    UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
    if (!mainWindow || ![mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        return NSNotFound;
    }
    TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
    
    return tabBarController.selectedIndex;
}

#pragma mark - TTAccountMulticaastProtocol

//帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    //账号切换时需要重新加载账号下的草稿
    __weak typeof(self) weakSelf = self;
    if ([TTAccountManager isLogin]) {
        // 若切换为登录状态，则优先以内存task状态为准（此处只考虑未登录-已登陆状态切换）
        [self loadLoginStatusModelsWithCompletionBlock:^{
            if (weakSelf.statusChangeBlk) {
                weakSelf.statusChangeBlk();
            }
        }];
    } else {
        self.mainTaskStatusModels = [[NSMutableArray alloc] init];
        self.followTaskStatusModels = [[NSMutableArray alloc] init];
        self.weitouTiaoTaskStatusModels = [[NSMutableArray alloc] init];
        // 若切换为未登录状态，则优先以持久化task状态为准
//        [self loadStatusModelsWithCompletionBlock:^{
//
//        }];
        if (weakSelf.statusChangeBlk) {
            weakSelf.statusChangeBlk();
        }
    }
    
}

@end

