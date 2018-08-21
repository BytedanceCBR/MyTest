//
//  SSCommentManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-2.
//
//

#import "SSCommentManager.h"
#import "NSDictionary+TTAdditions.h"
#import "ArticleMomentModel.h"
#import "TTForumModel.h"
#import "SSUserModel.h"
#import "TTBlockManager.h"
#import "TTCommentViewModel.h"
#import "TTCommentReplyModel.h"
#import "TTDeviceHelper.h"
#import "TTNetworkManager.h"

@interface SSCommentManagerObject()
@property(nonatomic, assign)BOOL requestRaiseError; //获取远端发生了错误
@property(nonatomic, assign)BOOL needLoadingUpdate;
@property(nonatomic, assign)BOOL needLoadingMore;
@property(nonatomic, strong)NSMutableArray * commentModels;
@property(nonatomic, strong)NSMutableArray * lastAppendCommentModels;//最近一次获取的Models
@property(nonatomic, strong)NSMutableSet * uniqueIDSet;
@end

@implementation SSCommentManagerObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self resetDatas];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserHandler:) name:kHasBlockedUnblockedUserNotification object:nil];
    }
    return self;
}

/**
 *  删除Model
 *
 *  @param model 评论model
 *
 *  @return 删除成功返回YES， 不成功或者没有找到返回NO
 */
- (BOOL)deleteModel:(SSCommentModel *)model
{
    if ([_uniqueIDSet containsObject:model.commentID]) {
        [self.uniqueIDSet removeObject:model.commentID];
        SSCommentModel * needDelModel = nil;
        for (SSCommentModel * m in _commentModels) {
            if ([m.commentID longLongValue]== [model.commentID longLongValue]) {
                needDelModel = m;
                break;
            }
        }
        if (needDelModel) {
            [self.commentModels removeObject:needDelModel];
            return YES;
        }
    }
    return NO;
}

- (void)insertCommentModelToTop:(SSCommentModel *)model
{
    if (![model isAvailable]) {
        return;
    }
    
    if (!_uniqueIDSet) {
        self.uniqueIDSet = [NSMutableSet setWithCapacity:100];
    }
    
    if (!_commentModels) {
        self.commentModels = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    if (![_uniqueIDSet containsObject:model.commentID]) {
        [self.uniqueIDSet addObject:model.commentID];
        [self.commentModels insertObject:model atIndex:0];
    }
}

- (void)appendCommentModels:(NSArray *)models
{
    if (!_commentModels) {
        self.commentModels = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    if (!_lastAppendCommentModels) {
        self.lastAppendCommentModels = [[NSMutableArray alloc] initWithCapacity:100];
    }
    [_lastAppendCommentModels removeAllObjects];
    
    if ([models count] == 0) {
        return;
    }
    
    if (!_uniqueIDSet) {
        self.uniqueIDSet = [NSMutableSet setWithCapacity:100];
    }
    
    //去重
    for (id model in models) {
        if ([model isKindOfClass:[SSCommentModel class]]) {
            SSCommentModel *commentModel = (SSCommentModel *)model;
            if (![commentModel isAvailable]) {
                continue;
            }
            if (![_uniqueIDSet containsObject:commentModel.commentID]) {
                [self.uniqueIDSet addObject:commentModel.commentID];
                [self.commentModels addObject:commentModel];
                [_lastAppendCommentModels addObject:commentModel];
            }
        }
        else if ([model isKindOfClass:[ArticleMomentModel class]]) {
            ArticleMomentModel *momentModel = (ArticleMomentModel *)model;
            if (![_uniqueIDSet containsObject:momentModel.ID]) {
                [self.uniqueIDSet addObject:momentModel.ID];
                [self.commentModels addObject:model];
                [_lastAppendCommentModels addObject:model];
            }
        }
        else if ([model isKindOfClass:[NSDictionary class]]) {
            NSDictionary *info = (NSDictionary *)model;
            if (info.allKeys.count) {
                NSDictionary *adInfo = [info objectForKey:[[info allKeys] firstObject]];
                NSString *aID = [NSString stringWithFormat:@"%@", adInfo[@"id"]];
                NSString *adID = [NSString stringWithFormat:@"%@", adInfo[@"ad_id"]];
                NSString *uniqueID = aID;
                if (isEmptyString(uniqueID)) {
                    uniqueID = adID;
                }
                if (!isEmptyString(uniqueID) && ![_uniqueIDSet containsObject:uniqueID]) {
                    [self.uniqueIDSet addObject:uniqueID];
                    [self.commentModels addObject:model];
                    [_lastAppendCommentModels addObject:model];
                }
            }
        }
    }
}

- (void)resetDatas
{
    self.offset = @0;
    self.requestRaiseError = NO;
    self.needLoadingUpdate = YES;
    self.needLoadingMore = NO;
    [self.lastAppendCommentModels removeAllObjects];
    [self.uniqueIDSet removeAllObjects];
    [self.commentModels removeAllObjects];
}

- (NSMutableArray *)queryCommentModels
{
    return _commentModels;
}

- (void)blockUnblockUserHandler:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    
    [self.commentModels enumerateObjectsUsingBlock:^(SSCommentModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model isKindOfClass:[SSCommentModel class]]) {
            if ([userID isEqualToString:[NSString stringWithFormat:@"%@", model.userID]]) {
                model.isBlocking = [[userInfo valueForKey:kIsBlockingKey] boolValue];
            }
        }
    }];
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define SSCommentManagerCommentTemplateContentKey @"SSCommentManagerCommentTemplateContentKey"
#define SSCommentManagerCommentTemplateVersionKey @"SSCommentManagerCommentTemplateVersionKey"

@interface SSCommentManager()
@property(nonatomic, assign, readwrite)BOOL detailNoComment;//详情页不显示评论
@property(nonatomic, strong, readwrite)TTGroupModel *groupModel;
@property(nonatomic, strong, readwrite)Article *article;    //added 4.9, 主要用途是区分普通和组图详情页
@property(nonatomic, strong)NSDictionary * requestUserinfo;
@end

@implementation SSCommentManager

+ (NSString *)detailCommentTemplate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SSCommentManagerCommentTemplateContentKey];
}

+ (NSNumber *)versionForDetailCommentTemplate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SSCommentManagerCommentTemplateVersionKey];
}

+ (void)saveDetailCommentTemplate:(NSString *)templ version:(NSNumber *)ver
{
    if (isEmptyString(templ) || ver == nil) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:ver forKey:SSCommentManagerCommentTemplateVersionKey];
    [[NSUserDefaults standardUserDefaults] setObject:templ forKey:SSCommentManagerCommentTemplateContentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
    [self.commentManagerObjects removeAllObjects];
}

- (id)init
{
    self = [super init];
    if (self) {
        _changedFlag = @0;
        self.commentManagerObjects = [NSMutableDictionary dictionary];
        
        [self resetDatas];
    }
    return self;
}

#pragma mark -- public

- (void)cancelCurrentLoad
{
    self.loading = NO;
}

- (void)cancelCurrentLoadAndReset
{
    [self cancelCurrentLoad];
    [self resetDatas];
}

- (void)clearDataAndUI
{
    [self cancelCurrentLoadAndReset];
    self.changedFlag = kChangedFlagDone;
}

- (void)insertCommentDictToTop:(NSDictionary*)commentDict
{
    if (commentDict) {
        SSCommentModel * model = [[SSCommentModel alloc] initWithDictionary:commentDict groupModel:_groupModel];
        if (!isEmptyString(model.commentContent)) {
            [self insertCommentModelToTop:model];
        }
    }
}

- (void)removeCommentForModel:(SSCommentModel *)model
{
    if ([model.commentID longLongValue] == 0) {
        return;
    }
    
    [[self currentCommentManagerObject] deleteModel:model];
    
    _commentsCount--;
    
    if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManager:refreshCommentsCount:)]) {
        [_delegate articleInfoManager:self refreshCommentsCount:self.commentsCount];
    }
    
    self.changedFlag = kChangedFlagDone;
}

- (void)insertCommentModelToTop:(SSCommentModel *)model
{
    SSCommentManagerObject * obj = [self currentCommentManagerObject];
    [obj insertCommentModelToTop:model];
    
    _commentsCount ++;
    
    if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManager:refreshCommentsCount:)]) {
        [_delegate articleInfoManager:self refreshCommentsCount:self.commentsCount];
    }
    
    self.changedFlag = kChangedFlagDone;
}

- (BOOL)requestRaiseError
{
    return [[self currentCommentManagerObject] requestRaiseError];
}

- (BOOL)needLoadingUpdateCommentModels
{
    if (![self shouldShowComments]) {
        return NO;
    }
    return [[self currentCommentManagerObject] needLoadingUpdate];
}


- (BOOL)needLoadingMoreCommentModels
{
    if (![self shouldShowComments]) {
        return NO;
    }
    return [[self currentCommentManagerObject] needLoadingMore];
}

- (NSMutableArray *)curCommentModels
{
    if (![self shouldShowComments]) {
        return nil;
    }
    return [[self currentCommentManagerObject] queryCommentModels];
}

/**
 *  当前评论列表的managerObject对象
 **/
- (SSCommentManagerObject *)currentCommentManagerObject
{
    return [_commentManagerObjects objectForKey:@(_curTabIndex)];
}

- (NSString *)currentCommentTabName
{
    return [self currentCommentManagerObject].tabName;
}

- (NSUInteger)numberOfRowsForCurCommentManagerObject
{
    return [[self currentCommentManagerObject].commentModels count];
}

- (Article *)curentArticle
{
    return self.article;
}

- (void)tryLoadCommentWithGroupModel:(TTGroupModel *)groupModel userInfo:(NSDictionary *)userInfo
{
    [self loadCommentWithGroupModel:groupModel userInfo:userInfo];
}

- (void)loadCommentWithGroupModel:(TTGroupModel *)groupModel userInfo:(NSDictionary *)userInfo
{
    if (groupModel.groupID == nil) {
        return;
    }
    if (_loading) {
        return;
    }
    self.groupModel = groupModel;
    self.loading = YES;
    self.requestUserinfo = userInfo;
    
    [self reloadCommentWithTagIndex:self.curTabIndex];
}

//- (void)tryLoadCommentWithArticle:(Article *)article userInfo:(NSDictionary *)userInfo
//{
//    [self loadCommentWithArticle:article userInfo:userInfo];
//}

//- (void)loadCommentWithArticle:(Article *)article userInfo:(NSDictionary *)userInfo
//{
//    self.article = article;
//    [self loadCommentWithGroupModel:article.groupModel userInfo:userInfo];
//}

- (void)reloadCommentWithTagIndex:(NSInteger)tagIndex
{
    NSMutableDictionary * getParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [getParam setValue:@(tagIndex) forKey:@"tab_index"];
    [getParam setValue:@([_groupModel.groupID longLongValue]) forKey:@"group_id"];
    int64_t itemID = !isEmptyString(_groupModel.itemID) ? [_groupModel.itemID longLongValue] : 0;
    [getParam setValue:@(itemID) forKey:@"item_id"];
    [getParam setValue:@(_groupModel.aggrType) forKey:@"aggr_type"];
    int tplVersion = [[SSCommentManager versionForDetailCommentTemplate] intValue];
    if (tplVersion > 0) {
        [getParam setValue:@(tplVersion) forKey:@"tpl_version"];
    }
    
    if ([_requestUserinfo.allKeys containsObject:kCommentManagerFirstLoadConditionTopCommentIDKey]) {
        [getParam setValue:[_requestUserinfo objectForKey:kCommentManagerFirstLoadConditionTopCommentIDKey] forKey:@"top_comment_id"];
    }
    
    if ([_requestUserinfo.allKeys containsObject:@"zzids"]) {
        [getParam setValue:[_requestUserinfo objectForKey:@"zzids"] forKey:@"zzids"];
    }
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting tabCommentURLString] params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        
        if (error) {
            self.changedFlag = kChangedFlagFailed;
        }
        else {
            [self resetCurrentTabData];
            
            NSDictionary *results = jsonObj;
            //更新评论数量
            self.commentsCount = [results intValueForKey:@"total_number"
                                            defaultValue:0];
            if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManager:refreshCommentsCount:)]) {
                [_delegate articleInfoManager:self refreshCommentsCount:self.commentsCount];
            }
            
            if ([results.allKeys containsObject:@"show_add_forum"]) {
                self.shouldShowAddForum = [results[@"show_add_forum"] boolValue];
                if (_delegate && [_delegate respondsToSelector:@selector(articleInfoManager:shouldShowAddForum:)]) {
                    [_delegate articleInfoManager:self shouldShowAddForum:self.shouldShowAddForum];
                }
            }
            
            //评论tabInfo
            NSDictionary *tabInfo = [results dictionaryValueForKey:@"tab_info" defalutValue:nil];
            self.curTabIndex = [tabInfo[@"current_tab_index"] integerValue];
            self.commentTabs = [tabInfo arrayValueForKey:@"tabs" defaultValue:nil];
            NSString *currentTabName = _commentTabs[self.curTabIndex];
            
            //处理数据
            if (nil == [self currentCommentManagerObject]) {
                SSCommentManagerObject *managerObject = [[SSCommentManagerObject alloc] init];
                managerObject.tabName = currentTabName;
                managerObject.hasReload = YES;
                [self setCommentObject:managerObject fromCommentDatas:results];
                [self.commentManagerObjects setObject:managerObject forKey:@(_curTabIndex)];
            }
            else {
                [self setCommentObject:[self currentCommentManagerObject] fromCommentDatas:results];
            }
            
            self.bannComment = [[results objectForKey:@"ban_comment"] boolValue];
            
            if (results[@"go_topic_detail"]) {
                self.goTopicDetail = [results[@"go_topic_detail"] boolValue];
            }
            
            self.detailNoComment = [[results objectForKey:@"detail_no_comment"] boolValue];
            
            self.changedFlag = kChangedFlagDoneForFirstLoad;
        }
        
        self.loading = NO;
    }];
    
}

- (void)loadMore
{
    if (_loading) {
        return;
    }
    
    if (![self needLoadingMoreCommentModels]) {
        return;
    }
    
    if (_groupModel.groupID == nil) {
        return;
    }
    
    self.loading = YES;

    NSMutableDictionary * loadMoreParam = [NSMutableDictionary dictionaryWithCapacity:10];
    int offset = [[self currentCommentManagerObject].offset intValue];
    [loadMoreParam setValue:@(_curTabIndex) forKey:@"tab_index"];
    [loadMoreParam setValue:@(offset) forKey:@"offset"];
    [loadMoreParam setValue:@(kLoadMoreFetchCount) forKey:@"count"];
    [loadMoreParam setValue:@([_groupModel.groupID longLongValue]) forKey:@"group_id"];
    int64_t itemID = !isEmptyString(_groupModel.itemID) ? [_groupModel.itemID longLongValue] : 0;
    [loadMoreParam setValue:@(itemID) forKey:@"item_id"];
    [loadMoreParam setValue:@(_groupModel.aggrType) forKey:@"aggr_type"];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting tabCommentURLString] params:loadMoreParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        
        self.loading = NO;
        SSCommentManagerObject * obj = [self currentCommentManagerObject];
        if (error) {
            obj.requestRaiseError = YES;
            self.changedFlag = kChangedFlagFailed;
        }
        else {
            obj.requestRaiseError = NO;
            
            [self parseLoadMoreResult:jsonObj commentObject:obj];
        }
        self.loading = NO;
    }];
    
    // 统计 - 详情页detail，评论加载更多发送comment_loadmore
    NSString *tag = [_article isImageSubject]?@"slide_detail":@"detail";
    wrapperTrackEvent(tag, @"comment_loadmore");
}

- (void)forceCurrentObjectShouldLoadMore
{
    self.currentCommentManagerObject.needLoadingMore = YES;
}

#pragma mark -- target

- (void)parseLoadMoreResult:(NSDictionary *)result commentObject:(SSCommentManagerObject *)object
{
    NSDictionary *resultDic = result;
    object.needLoadingUpdate = NO;
    object.needLoadingMore = [[resultDic objectForKey:@"has_more"] boolValue];
    
    NSArray * datas = [resultDic arrayValueForKey:@"data"
                                     defaultValue:nil];
    NSArray * commentModels = [self commentDictsToCommentModels:datas];
    if (resultDic[@"go_topic_detail"]) {
        self.goTopicDetail = [resultDic[@"go_topic_detail"] boolValue];
    }
    [object appendCommentModels:commentModels];
    self.changedFlag = kChangedFlagDoneForLoadMore;
    object.offset = @([object.offset intValue] + kLoadMoreOffsetCount);
}

- (void)setCommentObject:(SSCommentManagerObject *)managerObject fromCommentDatas:(NSDictionary *)commentDatas
{
    managerObject.needLoadingUpdate = NO;
    managerObject.needLoadingMore = [[commentDatas objectForKey:@"has_more"] boolValue];
    
    NSArray * dataDics = [commentDatas objectForKey:@"data"];
    NSArray * tmpSonCommentModels = [self commentDictsToCommentModels:dataDics];
    
    NSMutableArray * sonCommentModels = [NSMutableArray arrayWithCapacity:20];
    if ([tmpSonCommentModels count] > 0) {
        [sonCommentModels addObjectsFromArray:tmpSonCommentModels];
    }
    
    [managerObject appendCommentModels:sonCommentModels];
    
    managerObject.offset = @([[commentDatas objectForKey:@"offset"] intValue]);
    if ([managerObject.offset intValue] == 0) {
        managerObject.offset = @([dataDics count]);
    }
}

#pragma mark -- private util

- (NSArray *)commentDictsToCommentModels:(NSArray *)dataDics
{
    NSMutableArray * dataModels = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary * dict in dataDics) {
        //评论
        SSCommentModel * model = [[SSCommentModel alloc] initWithDictionary:dict[@"comment"] groupModel:_groupModel];
        if (model != nil) {
            [dataModels addObject:model];
        }
    }
    return dataModels;
}

- (ArticleMomentModel *)momentModelWithTabCommentDict:(NSDictionary *)dict
{
    ArticleMomentModel *model = [[ArticleMomentModel alloc] init];
    SSUserModel *user = [[SSUserModel alloc] init];
    user.name = dict[@"user_name"];
    user.avatarURLString = dict[@"avatar_image_url"];
    NSMutableDictionary *forumDict = [NSMutableDictionary dictionary];
    NSDictionary *forumLinkDict = [dict objectForKey:@"forum_link"];
    [forumDict setValue:[forumLinkDict objectForKey:@"forum_id"] forKey:@"forum_id"];
    [forumDict setValue:[forumLinkDict objectForKey:@"text"] forKey:@"forum_show_name"];
    [forumDict setValue:[forumLinkDict objectForKey:@"url"] forKey:@"url"];
    model.user = user;
    model.content = dict[@"content"];
    model.thumbImgeDicts = dict[@"image_list"];
    model.ID = dict[@"id"];
    model.momentURL = [(NSDictionary *)dict[@"content_link"] objectForKey:@"url"];
    model.talkItem = forumDict;
    model.itemType = MomentItemTypeForum;
    return model;
}

- (void)resetDatas
{
    _forceShowComment = NO;
    _bannComment = NO;
    _goTopicDetail = NO;
    _commentsCount = 0;
    _detailNoComment = NO;
    
    [self.commentManagerObjects enumerateKeysAndObjectsUsingBlock:^(id key, SSCommentManagerObject *obj, BOOL *stop) {
        [obj resetDatas];
    }];
}

- (void)resetCurrentTabData
{
    _forceShowComment = NO;
    _bannComment = NO;
    _goTopicDetail = NO;
    _commentsCount = 0;
    _detailNoComment = NO;
    [[self currentCommentManagerObject] resetDatas];
}

- (BOOL)shouldShowComments
{
    if (_detailNoComment && !_forceShowComment) {
        return NO;
    }
    return YES;
}

@end
