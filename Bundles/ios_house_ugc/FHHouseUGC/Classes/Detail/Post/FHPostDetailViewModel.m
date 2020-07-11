//
//  FHPostDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHPostDetailViewModel.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"
#import "FHPostDetailCell.h"
#import "TTUGCRequestManager.h"
#import "NSObject+TTAdditions.h"
#import "TTRoute.h"
#import "FRCommonURLSetting.h"
#import "TTAlphaThemedButton.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "NSObject+FBKVOController.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "TTRoute.h"
#import "TTTAttributedLabel.h"
#import "TTImageView.h"
#import "JSONAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "Article.h"
#import "FHUGCDetailGrayLineCell.h"
#import "FHPostDetailHeaderCell.h"
#import "FHMainApi.h"
#import "FHBaseModelProtocol.h"
#import "FHFeedContentModel.h"
#import "FHUGCScialGroupModel.h"
#import "FHUGCConfig.h"
#import "FHUGCCellHelper.h"
#import "HMDTTMonitor.h"
#import "FHErrorHubManagerUtil.h"

@interface FHPostDetailViewModel ()

@property (nonatomic, copy , nullable) NSString *social_group_id;

@end

@implementation FHPostDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHPostDetailCell class] forCellReuseIdentifier:NSStringFromClass([FHPostDetailCell class])];
    [self.tableView registerClass:[FHUGCDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHUGCDetailGrayLineCell class])];
    [self.tableView registerClass:[FHPostDetailHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHPostDetailHeaderCell class])];
}

// cell class
- (Class)cellClassForEntity:(id)model {
    // 帖子头部
    if ([model isKindOfClass:[FHPostDetailHeaderModel class]]) {
        return [FHPostDetailHeaderCell class];
    }
    // 帖子详情cell
    if ([model isKindOfClass:[FHFeedUGCCellModel class]]) {
        return [FHPostDetailCell class];
    }
    // 分割线
    if ([model isKindOfClass:[FHUGCDetailGrayLineModel class]]) {
        return [FHUGCDetailGrayLineCell class];
    }
    return [FHUGCBaseCell class];
}

// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

-(instancetype)initWithController:(FHCommentBaseDetailViewController *)viewController tableView:(UITableView *)tableView postType:(FHUGCPostType)postType {
    self = [super initWithController:viewController tableView:tableView postType:postType];
    self.threadID = 0;
    self.forumID = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followListDataChanged:) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
    // 编辑成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadSuccessNotification" object:nil]; // 编辑发送成功
    return self;
}

// init(会走上面的方法)
- (nonnull instancetype)initWithThreadID:(int64_t)threadID forumID:(int64_t)forumID{
    self = [super init];
    if (self) {
        self.threadID = threadID;
        self.forumID = forumID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followListDataChanged:) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
        // 编辑成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEditNoti:) name:@"kTTForumPostEditedThreadSuccessNotification" object:nil]; // 编辑发送成功
    }
    return self;
}

// init(会走上面的方法)
- (instancetype)init {
    self = [self initWithThreadID:0 forumID:0];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 关注列表改变
- (void)followListDataChanged:(NSNotification *)notification {
    if (notification) {
        NSString *currentGroupId = self.social_group_id;
        if (currentGroupId.length > 0 && self.detailHeaderModel) {
            FHUGCScialGroupDataModel *groupData = [[FHUGCConfig sharedInstance] socialGroupData:currentGroupId];
            if (groupData) {
                FHUGCScialGroupDataModel *currentGroupData = self.detailHeaderModel.socialGroupModel;
                if (![currentGroupData.hasFollow isEqualToString:groupData.hasFollow]) {
                    currentGroupData.hasFollow = groupData.hasFollow;
                    currentGroupData.countText = groupData.countText;
                    [self.detailController headerInfoChanged];
                    [self reloadData];
                }
            }
        }
    }
}

// 编辑发送成功 - 更新数据
- (void)postEditNoti:(NSNotification *)noti {
    if (noti && noti.userInfo) {
        NSDictionary *userInfo = noti.userInfo;
        NSString *groupId = userInfo[@"group_id"];
        if (groupId.length > 0) {
            __block NSUInteger index = -1;
            __block BOOL showCommunity = NO;
            [self.items enumerateObjectsUsingBlock:^(id  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([cellModel isKindOfClass:[FHFeedUGCCellModel class]]) {
                    if ([((FHFeedUGCCellModel *)cellModel).groupId isEqualToString:groupId]) {
                        index = idx;
                        showCommunity = ((FHFeedUGCCellModel *)cellModel).showCommunity;
                    }
                }
            }];
            // 找到 要更新的数据
            if (index >= 0 && index < self.items.count) {
                NSString *thread_cell = userInfo[@"thread_cell"];
                if (thread_cell && [thread_cell isKindOfClass:[NSString class]]) {
                    NSError *jsonParseError;
                    NSData *jsonData = [thread_cell dataUsingEncoding:NSUTF8StringEncoding];
                    if (jsonData) {
                        FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                        // 网络请求返回
                        model.isFromDetail = YES;
                        if (self.shareInfo == nil && model.shareInfo) {
                            self.shareInfo = model.shareInfo;
                        }
                        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeedUGCContent:model];
                        cellModel.isFromDetail = YES;
                        cellModel.feedVC = self.detailData.feedVC;
                        cellModel.isStick = self.detailData.isStick;
                        cellModel.stickStyle = self.detailData.stickStyle;
                        cellModel.contentDecoration = nil;
                        if (cellModel.community.socialGroupId.length <= 0) {
                            cellModel.community = self.detailData.community;
                        }
                        cellModel.showCommunity = showCommunity;
                        cellModel.tracerDic = [self.detailController.tracerDict copy];
                        if (cellModel) {
                            self.items[index] = cellModel;
                        }
                        // 异步一下 以及重新布局
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.detailController remove_comment_vc];
                            [self.tableView reloadData];
                            [self.detailController re_add_comment_vc];
                            self.tableView.hidden = NO;
                            [self.detailController show_comment_view];
                        });
                        // 页面布局问题修复
                        __weak typeof(self) weakSelf = self;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf.detailController refresh_page_view];
                        });
                    }
                }
            }
        }
    }
}

// 关注状态改变
- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
        NSDictionary *userInfo = notification.userInfo;
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *groupId = notification.userInfo[@"social_group_id"];
        NSString *currentGroupId = self.social_group_id;
        if(groupId.length > 0 && currentGroupId.length > 0) {
            if (self.detailHeaderModel) {
                // 有头部信息
                if ([groupId isEqualToString:currentGroupId]) {
                    // 替换关注人数 AA关注BB热帖 替换：AA
                    [[FHUGCConfig sharedInstance] updateScialGroupDataModel:self.detailHeaderModel.socialGroupModel byFollowed:followed];
                    [self.detailController headerInfoChanged];
                    [self reloadData];
                }
            }
        }
    }
}

// startLoadData
- (void)startLoadData {
    __weak typeof(self) wSelf = self;
    [self requestV3InfoWithCompletion:^(NSError *error, uint64_t networkConsume) {
        [wSelf.detailController endLoading];
        if (error) {
            if (error.code == -10001) {
                // 被删除，空页面已经展示了
                wSelf.weakShareButton.hidden = YES;
            } else if (wSelf.items.count <= 0) {
                // 显示空页面
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        } else {
            [wSelf.detailController.emptyView hideEmptyView];
            [wSelf reloadData];
            [wSelf.detailController re_add_comment_vc];
            wSelf.tableView.hidden = NO;
            [wSelf.detailController show_comment_view];
        }
    }];
}

// 处理数据
- (void)processWithData:(FHFeedUGCContentModel *)model socialGroup:(FHUGCScialGroupDataModel *)socialGroupModel {
    if (model && [model isKindOfClass:[FHFeedUGCContentModel class]]) {
        [self.items removeAllObjects];
        // 网络请求返回
        model.isFromDetail = YES;
        if (self.shareInfo == nil && model.shareInfo) {
            self.shareInfo = model.shareInfo;
        }
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeedUGCContent:model];
        cellModel.isFromDetail = YES;
        cellModel.feedVC = self.detailData.feedVC;
        cellModel.isStick = self.detailData.isStick;
        cellModel.stickStyle = self.detailData.stickStyle;
        cellModel.contentDecoration = nil;
        if (cellModel.community.socialGroupId.length <= 0) {
            cellModel.community = self.detailData.community;
        }
        cellModel.tracerDic = [self.detailController.tracerDict copy];
        if (socialGroupModel && ![socialGroupModel.hasFollow boolValue] && ![socialGroupModel.showStatus isEqualToString:@"1"]) {
            // 未关注
            FHPostDetailHeaderModel *headerModel = [[FHPostDetailHeaderModel alloc] init];
            headerModel.socialGroupModel = socialGroupModel;
            headerModel.tracerDict = self.detailController.tracerDict.mutableCopy;
            self.social_group_id = socialGroupModel.socialGroupId;
            [self.items addObject:headerModel];
            self.detailHeaderModel = headerModel;
            [self.detailController headerInfoChanged];
            //
            FHUGCDetailGrayLineModel *grayLine = [[FHUGCDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            cellModel.showCommunity = NO;
        } else {
            if (cellModel.community && cellModel.community.name.length > 0 && cellModel.community.socialGroupId.length > 0 && ![cellModel.community.showStatus isEqualToString:@"1"]) {
                cellModel.showCommunity = YES;
            } else if (socialGroupModel && socialGroupModel.socialGroupId.length > 0 && socialGroupModel.socialGroupName.length > 0 && ![socialGroupModel.showStatus isEqualToString:@"1"]) {
                // 挽救一下 balabala
                cellModel.community = [[FHFeedUGCCellCommunityModel alloc] init];
                cellModel.community.name = socialGroupModel.socialGroupName;
                cellModel.community.socialGroupId = socialGroupModel.socialGroupId;
                cellModel.showCommunity = YES;
            } else {
                cellModel.showCommunity = NO;
            }
        }
        if (socialGroupModel) {
            // 更新圈子数据
            [[FHUGCConfig sharedInstance] updateSocialGroupDataWith:socialGroupModel];
            if (cellModel.community.socialGroupId.length <= 0) {
                // 赋值 圈子数据 删除的时候需要
                FHFeedUGCCellCommunityModel *communityModel = [[FHFeedUGCCellCommunityModel alloc] init];
                communityModel.url = socialGroupModel.announcementUrl;
                communityModel.socialGroupId = socialGroupModel.socialGroupId;
                communityModel.name = socialGroupModel.socialGroupName;
                cellModel.community = communityModel;
            }
        }
        // 更新点赞以及评论数
        if (cellModel) {
            [self.items addObject:cellModel];
            
            self.detailController.comment_count = [cellModel.commentCount longLongValue];
            self.detailController.user_digg = [cellModel.userDigg integerValue];
            self.detailController.digg_count = [cellModel.diggCount longLongValue];
            [self.detailController refreshToolbarView];
            [self.detailController commentCountChanged];
        }
        // 评论个数为0 直接调起键盘
        if (self.detailController.comment_count <= 0 && self.detailController.beginShowComment) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.detailController becomeFirstResponder_comment];
            });
        }
        
        // 页面布局问题修复
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf reloadData];
            [weakSelf.detailController refresh_page_view];
        });
    }
}

#pragma mark - Public

- (void)requestV3InfoWithCompletion:(void(^)(NSError *error, uint64_t networkConsume))completion
{
    if (self.threadID) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:@(self.threadID) forKey:@"thread_id"];
        [param setValue:self.category forKey:@"category"];
        if (self.lastPageSocialGroupId.length > 0) {
            [param setValue:self.lastPageSocialGroupId forKey:@"social_group_id"];
        }
        if(self.threadDetailSource.length > 0){
            param[@"thread_detail_source"] = self.threadDetailSource;
        }
        uint64_t startTime = [NSObject currentUnixTime];
        WeakSelf;
        NSString *host = [FHURLSettings baseURL];
        NSString *urlStr = [NSString stringWithFormat:@"%@/f100/ugc/thread",host];
        NSDate *startDate = [NSDate date];
        [TTUGCRequestManager requestForJSONWithURL:urlStr params:param method:@"GET" needCommonParams:YES callBackWithMonitor:^(NSError *error, id jsonObj, TTHttpResponse *response) {
            StrongSelf;
            NSDate *backDate = [NSDate date];
            uint64_t endTime = [NSObject currentUnixTime];
            uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
            NSDate *serDate = [NSDate date];
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            NSDictionary *exceptionDict = nil;
            NSInteger responseCode = -1;
            if (response.statusCode) {
                responseCode = response.statusCode;
            }
            NSError *jsonParseError;
            if (!error) {
                NSDictionary *dataDict = [jsonObj isKindOfClass:[NSDictionary class]]? jsonObj: nil;
                if ([dataDict tt_longValueForKey:@"err_no"] == 0) {
                    NSString *dataStr = [dataDict tt_stringValueForKey:@"data"];
                    if (isEmptyString(dataStr)) {
                        //不该出现这种情况
                        // 成功埋点 status = 0 成功（不上报） status = 1：data为空
                        NSMutableDictionary *metric = @{}.mutableCopy;
                        metric[@"post_id"] = @(self.threadID);
                        [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_post_detail_error" metric:metric category:@{@"status":@(1)} extra:nil];
                        
                        resultType = FHNetworkMonitorTypeBizFailed + 1;
                        code = 1;
                        errMsg = @"ugc_post_detail_error:empty";
                    } else {
                        
                        NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                        if (jsonData) {
                            Class cls = [FHFeedUGCContentModel class];
                            FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                            if (model.ugcStatus && [model.ugcStatus integerValue] == 0) {
                                // 说明被删除
                                error = [NSError errorWithDomain:NSURLErrorDomain code:-10001 userInfo:nil];
                                [self.detailController remove_comment_vc];
                                self.tableView.hidden = YES;
                                // 显示空页面
                                [self.detailController.emptyView showEmptyWithTip:@"该内容已被删除" errorImageName:kFHErrorMaskNoListDataImageName showRetry:NO];
                            } else {
                                if (model && jsonParseError == nil) {
                                    // 继续解析小区头部
                                    NSDictionary *social_group = [dataDict tt_dictionaryValueForKey:@"social_group"];
                                    NSError *groupError = nil;
                                    FHUGCScialGroupDataModel * groupData = [[FHUGCScialGroupDataModel alloc] initWithDictionary:social_group error:&groupError];
                                    [self processWithData:model socialGroup:groupData];
                                }
                            }
                        } else {
                            // 成功埋点 status = 0 成功（不上报） status = 2：转json失败
                            NSMutableDictionary *metric = @{}.mutableCopy;
                            metric[@"post_id"] = @(self.threadID);
                            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_post_detail_error" metric:metric category:@{@"status":@(2),@"response_code":@(responseCode)} extra:nil];
                            
                            resultType = FHNetworkMonitorTypeBizFailed + 2;
                            code = 2;
                            errMsg = @"ugc_post_detail_error:json error";
                        }
                    }
                }
            } else {
                code = error.code;
                resultType = FHNetworkMonitorTypeNetFailed;
            }
            
            // 序列化时间
            serDate = [NSDate date];
            // 帖子接口成功率
            [FHMainApi addRequestLog:@"/f100/ugc/thread" startDate:startDate backDate:backDate serializeDate:serDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict exceptionDict:exceptionDict responseCode:responseCode];
            FHErrorHubManagerUtil *errorHubUtil = [[FHErrorHubManagerUtil alloc]init];
             [errorHubUtil checkRequestResponseWithHost:urlStr requestParams:param responseStatus:response response:jsonObj analysisError:jsonParseError changeModelType:resultType errorHubType:1];
//            [[FHHouseErrorHubManager sharedInstance] checkRequestResponseWithHost:urlStr requestParams:param responseStatus:response response:jsonObj analysisError:jsonParseError changeModelType:resultType errorHubType:FHErrorHubTypeRequest];
            
            if (completion) {
                completion(error,total);
            }
        }];
    } else {
        [self.detailController endLoading];
        [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
}

@end
