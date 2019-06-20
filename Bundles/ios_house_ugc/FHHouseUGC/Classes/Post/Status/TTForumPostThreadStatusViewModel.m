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

#import <TTAccountBusiness.h>
#import "TTArticleTabBarController.h"//这个不OK
#import "TTForumPostThreadToPageViewModel.h"
#import "TTTabBarProvider.h"
//#import "TTPostVideoRedpackDelegate.h"
#import "TTTabBarProvider.h"
#import "TTBubbleView.h"
#import "TTExploreMainViewController.h"//这个不OK
#import "NewsBaseDelegate.h"//这个不OK，为啥还要依赖这个？？？
#import "ArticleMobileViewController.h"//这个不OK
#import "ExploreLogicSetting.h"//这个不OK
#import <TTPostBase/TTPostTaskCenter.h>
#import "TTStringHelper.h"
#import "TTArticleCategoryManager.h"

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

@end

@implementation TTForumPostThreadStatusViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isEnterFollowPageFromPostNotification = NO;
        self.isEnterHomeTabFromPostNotification = NO;
        [self registerNotifications];
        [self loadStatusModelsWithCompletionBlock:nil];
        
    }
    return self;
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
    
    if (!isEmptyString(modelName)) {
        if (index == NSNotFound) {
            [[self mutableArrayValueForKey:modelName] addObject:statusModel];
        }
        else {
            [[self mutableArrayValueForKey:modelName] setObject:statusModel atIndexedSubscript:index];
        }
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
    
    if (isEmptyString(modelName)) {
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
   
    //对于登录状态过期的处理
    if ([task.finishError code] == TTPostThreadErrorCodeLoginStateValid) {
        
        NSString *source = nil;
        if (task.taskType == TTPostTaskTypeVideo) {
            source = @"post_topic";
        }
        else {
            source = @"post_video";
        }
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost
                                          source:source
                                     inSuperView:[TTUIResponderHelper topmostViewController].view
                                      completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                          
                                          if (type == TTAccountAlertCompletionEventTypeDone) {
                                              sendLogic(ArticleLoginStatePlatformLogin);
                                          }
                                          else if (type == TTAccountAlertCompletionEventTypeTip) {
                                              
                                              [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topmostViewController]
                                                                                   type:TTAccountLoginDialogTitleTypeDefault
                                                                                 source:source
                                                                             completion:nil];
                                          }
                                          
                                      }];
        
        NSString * text = [task.finishError.userInfo tt_stringValueForKey:@"description"];
        if (isEmptyString(text)) {
            text = NSLocalizedString(@"登录失效，请重新登录", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    else if (task.repostType == TTThreadRepostTypeNone) {
        NSString * text = [task.finishError.userInfo tt_stringValueForKey:@"description"];
        if (isEmptyString(text)) {
            text = NSLocalizedString(@"发布失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    else {
        NSDictionary *err_alert = [task.finishError.userInfo tt_dictionaryValueForKey:@"err_alert"];
        NSString *error_title = [err_alert tt_stringValueForKey:@"err_title"];
        NSString *error_tips = [err_alert tt_stringValueForKey:@"err_content"];
        NSString *error_schema = [err_alert tt_stringValueForKey:@"err_schema"];
        if (!isEmptyString(error_schema) && !isEmptyString(error_tips)) {
            
            TTAccountAlertView *alert = [[TTAccountAlertView alloc] initWithTitle:error_tips message:nil cancelBtnTitle:@"取消" confirmBtnTitle:error_title?:@"查看详情" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    if (!isEmptyString(error_schema)) {
                        NSURL *openURL = [TTStringHelper URLWithURLString:error_schema];
                        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
                            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
                        }
                        else {
                            NSString *linkStr = openURL.absoluteString;
                            if (!isEmptyString(linkStr)) {
                                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"]
                                                                          userInfo:TTRouteUserInfoWithDict(@{@"url":linkStr})];
                            }
                        }
                    }
                }
            }];
            
            [alert showInView:[TTUIResponderHelper topmostView]];
        }
        else {
            if (!self.isRetryAlertViewShown) {
                NSString * title = NSLocalizedString(@"发送失败，是否重新发送", nil);
                if (TTPostTaskTypeThread == task.taskType && TTThreadRepostTypeNone != task.repostType) {
                    //发帖任务 并且是 转发帖子任务
                    if (!isEmptyString([task.finishError.userInfo tt_stringValueForKey:@"description"])) {
                        title = [task.finishError.userInfo tt_stringValueForKey:@"description"];
                    }
                }
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    self.isRetryAlertViewShown = NO;
                }];
                [alert addActionWithTitle:NSLocalizedString(@"重试", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    [[TTPostThreadCenter sharedInstance_tt] resentThreadForFakeThreadID:task.fakeThreadId concernID:task.concernID];
                    self.isRetryAlertViewShown = NO;
                }];
                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                self.isRetryAlertViewShown = YES;
            }
        }
        
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
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[TTKitchen getString:kTTKUGCRepostWordingRepostSuccessToast] indicatorImage:nil autoDismiss:YES dismissHandler:nil];
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


    // add by zyk
    NSInteger followCategoryIndex = -1;//[[TTArticleCategoryManager sharedManager] indexOfCategoryInSubScribedCategories:kTTFollowCategoryID];
    //不在已订阅频道时，进行关注频道的生成并强制插入
    if (followCategoryIndex == NSNotFound && [TTKitchen getBOOL:kTTKUGCPostThreadRevalFollowChannel]) {
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

    if (followCategoryIndex == NSNotFound && [TTKitchen getBOOL:kTTKUGCPostThreadRevalFollowChannel]) {
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
    if ([TTKitchen getBOOL:kTTKUGCPostThreadRevalFollowChannel]) {

//        if (self.bubbleView) {
//            //关注频道是否在左侧固定频道
//            BOOL followCategoryExistInLeft = YES;//[[TTArticleCategoryManager sharedManager] isCategoryInFrontOfMainArticleCategoryInSubScribedCategories:kTTFollowCategoryID];
//
//            if (followCategoryExistInLeft) {
//                CGPoint tipsAnchorPoint = [self bubbleViewAnchorPoint];
//
//                [self.bubbleView changeAnchorPoint:tipsAnchorPoint];
//            }
//            else {
//                WeakSelf;
//                [self.bubbleView hideTipWithAnimation:NO forceHide:YES completionHandle:^{
//                    StrongSelf;
//                    self.bubbleView = nil;
//                }];
//
//            }
//
//        }
    }
}

//- (CGPoint)bubbleViewAnchorPoint {

//    TTExploreMainViewController *mainListView = [(NewsBaseDelegate *)[[UIApplication sharedApplication] delegate] exploreMainViewController];
//
//    TTCategorySelectorManager *selectorManager = mainListView.selectorManager;
//
//    UIView * followCategoryButton = [selectorManager categorySelectorButtonByCategoryId:kTTFollowCategoryID];
//
//    CGPoint tipsAnchorPoint = CGPointMake(followCategoryButton.superview.origin.x + CGRectGetWidth(followCategoryButton.frame)/2.f, CGRectGetMaxY(followCategoryButton.frame));
//
//    CGPoint tipsAnchorPointInMainListView = [mainListView.view convertPoint:tipsAnchorPoint fromView:selectorManager.selectorView];
//    return tipsAnchorPointInMainListView;
//}


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
    if ([TTAccountManager isLogin]) {
        // 若切换为登录状态，则优先以内存task状态为准（此处只考虑未登录-已登陆状态切换）
        [self loadLoginStatusModelsWithCompletionBlock:nil];
    } else {
        self.mainTaskStatusModels = [[NSMutableArray alloc] init];
        self.followTaskStatusModels = [[NSMutableArray alloc] init];
        self.weitouTiaoTaskStatusModels = [[NSMutableArray alloc] init];
        // 若切换为未登录状态，则优先以持久化task状态为准
        [self loadStatusModelsWithCompletionBlock:nil];
    }
    
}

@end

