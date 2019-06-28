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

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView postType:(FHUGCPostType)postType {
    self = [super initWithController:viewController tableView:tableView postType:postType];
    self.threadID = 0;
    self.forumID = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
    return self;
}

// init(会走上面的方法)
- (nonnull instancetype)initWithThreadID:(int64_t)threadID forumID:(int64_t)forumID{
    self = [super init];
    if (self) {
        self.threadID = threadID;
        self.forumID = forumID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
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
            if (wSelf.items.count <= 0) {
                // 显示空页面
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        } else {
            [wSelf reloadData];
        }
    }];
}

// 处理数据
- (void)processWithData:(FHFeedUGCContentModel *)model socialGroup:(FHUGCScialGroupDataModel *)socialGroupModel {
    if (model && [model isKindOfClass:[FHFeedUGCContentModel class]]) {
        [self.items removeAllObjects];
        // 网络请求返回
        if (![socialGroupModel.hasFollow boolValue]) {
            // 未关注
            FHPostDetailHeaderModel *headerModel = [[FHPostDetailHeaderModel alloc] init];
            headerModel.socialGroupModel = socialGroupModel;
            self.social_group_id = socialGroupModel.socialGroupId;
            [self.items addObject:headerModel];
            self.detailHeaderModel = headerModel;
            [self.detailController headerInfoChanged];
            //
            FHUGCDetailGrayLineModel *grayLine = [[FHUGCDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
        }
        //
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeedUGCContent:model];
        if (cellModel.community.socialGroupId.length <= 0) {
            cellModel.community = self.detailData.community;
        }
        [self.items addObject:cellModel];
        
        // 更新点赞以及评论数
        if (cellModel) {
            self.detailController.comment_count = [cellModel.commentCount longLongValue];
            self.detailController.user_digg = [cellModel.userDigg integerValue];
            self.detailController.digg_count = [cellModel.diggCount longLongValue];
            [self.detailController refreshToolbarView];
            [self.detailController commentCountChanged];
        }
    }
}

#pragma mark - Public

- (void)requestV3InfoWithCompletion:(void(^)(NSError *error, uint64_t networkConsume))completion
{
    if (self.threadID) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:@(self.threadID) forKey:@"thread_id"];
        [param setValue:self.category forKey:@"category"];
        uint64_t startTime = [NSObject currentUnixTime];
        WeakSelf;
        NSString *host = [FHURLSettings baseURL];
//        host = @"http://10.224.14.218:6789";
        NSString *urlStr = [NSString stringWithFormat:@"%@/f100/ugc/thread",host];
        [TTUGCRequestManager requestForJSONWithURL:urlStr params:param method:@"GET" needCommonParams:YES callBackWithMonitor:^(NSError *error, id jsonObj, TTUGCRequestMonitorModel *monitorModel) {
            StrongSelf;
            uint64_t endTime = [NSObject currentUnixTime];
            uint64_t total = [NSObject machTimeToSecs:endTime - startTime] * 1000;
            if (!error) {
                NSDictionary *dataDict = [jsonObj isKindOfClass:[NSDictionary class]]? jsonObj: nil;
                if ([dataDict tt_longValueForKey:@"err_no"] == 0) {
                    NSString *dataStr = [dataDict tt_stringValueForKey:@"data"];
                    if (isEmptyString(dataStr)) {
                        //不该出现这种情况
                    } else {
                        NSError *jsonParseError;
                        NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                        if (jsonData) {
                            Class cls = [FHFeedUGCContentModel class];
                            FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                            if (model && jsonParseError == nil) {
                                // 继续解析小区头部
                                NSDictionary *social_group = [dataDict tt_dictionaryValueForKey:@"social_group"];
                                NSError *groupError = nil;
                                FHUGCScialGroupDataModel * groupData = [[FHUGCScialGroupDataModel alloc] initWithDictionary:social_group error:&groupError];
                                [self processWithData:model socialGroup:groupData];
                            }
                        }
                    }
                }
            }
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
