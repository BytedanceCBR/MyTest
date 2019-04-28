//
//  TSVShortVideoDetailFetchManager.m
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import "TSVShortVideoDetailFetchManager.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager/TTNetworkManager.h"
#import "HTSVideoPlayJSONResponseSerializer.h"
#import "TSVShortVideoDecoupledFetchManager.h"
#import "TSVChannelDecoupledConfig.h"
#import <ReactiveObjC.h>

@interface TSVShortVideoDetailFetchManager ()

@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, assign) TSVShortVideoListLoadMoreType loadMoreType;
@property (nonatomic, copy) NSArray<TTShortVideoModel *> *awemedDetailItems;
@property (nonatomic, strong) TSVShortVideoDecoupledFetchManager *decoupledFetchManager;

@property (nonatomic, copy) NSString *activityForumID;
@property (nonatomic, copy) NSString *activityTopCursor;
@property (nonatomic, copy) NSString *activityCursor;
@property (nonatomic, copy) NSString *activitySeq;
@property (nonatomic, copy) NSString *activitySortType;

@end

@implementation TSVShortVideoDetailFetchManager

- (instancetype)initWithGroupID:(NSString *)groupID loadMoreType:(TSVShortVideoListLoadMoreType)loadMoreType
{
    return [self initWithGroupID:groupID loadMoreType:loadMoreType activityForumID:nil activityTopCursor:nil activityCursor:nil activitySeq:nil activitySortType:nil];
}

- (instancetype)initWithGroupID:(NSString *)groupID
                   loadMoreType:(TSVShortVideoListLoadMoreType)loadMoreType
                activityForumID:(NSString *)activityForumID
              activityTopCursor:(NSString *)activityTopCursor
                 activityCursor:(NSString *)activityCursor
                    activitySeq:(NSString *)activitySeq
               activitySortType:(NSString *)activitySortType
{
    self = [super init];
    if (self){
        _groupID = groupID;
        _loadMoreType = loadMoreType;
        if (_loadMoreType == TSVShortVideoListLoadMoreTypeNone) {
            self.hasMoreToLoad = NO;
        } else {
            self.hasMoreToLoad = YES;
        }
        _activityForumID = activityForumID;
        _activityTopCursor = activityTopCursor;
        _activityCursor = activityCursor;
        _activitySeq = activitySeq;
        _activitySortType = activitySortType;
    }
    return self;
}

- (NSUInteger)numberOfShortVideoItems
{
    return [self.awemedDetailItems count];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index
{
    return [self itemAtIndex:index replaced:YES];
}

- (TTShortVideoModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
{
    NSParameterAssert(index < [self.awemedDetailItems count]);
    
    if (replaced && self.replacedModel && index == self.replacedIndex) {
        return self.replacedModel;
    } else if (index < [self.awemedDetailItems count]) {
        return [self.awemedDetailItems objectAtIndex:index];
    }
    return nil;
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    if ([self numberOfShortVideoItems] == 0 && !isEmptyString(self.groupID)) {
        NSString *urlStr = [ArticleURLSetting shortVideoInfoURL];
        NSDictionary *params = @{
                                 @"group_id" : self.groupID,
                                 };
        self.isLoadingRequest = YES;
        WeakSelf;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"POST" needCommonParams:YES requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
            StrongSelf;
            if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
                self.hasMoreToLoad = NO;
                self.isLoadingRequest = NO;
                if (finishBlock){
                    finishBlock(0,error);
                }
                return;
            }
            
            NSError *mappingError = nil;
            NSMutableDictionary *fixedDict = [NSMutableDictionary dictionary];
            [fixedDict setValue:jsonObj[@"data"] forKey:@"raw_data"];
            TTShortVideoModel *model = [[TTShortVideoModel alloc] initWithDictionary:fixedDict error:&mappingError];
            NSMutableArray *awemeDetailItems = [NSMutableArray array];
            if (model) {
                [awemeDetailItems addObject:model];
            }
            self.awemedDetailItems = awemeDetailItems;
            self.isLoadingRequest = NO;
            if (finishBlock){
                finishBlock(1,error);
            }
        }];
    } else if ([self numberOfShortVideoItems] > 0 && self.loadMoreType == TSVShortVideoListLoadMoreTypePersonalHome){
        NSString *urlStr = [ArticleURLSetting shortVideoLoadMoreURL];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TTShortVideoModel *model = [self.awemedDetailItems lastObject];
        [params setValue:model.groupID forKey:@"group_id"];
        [params setValue:@(model.createTime) forKey:@"start_cursor"];
        [params setValue:model.author.userID forKey:@"user_id"];
        self.isLoadingRequest = YES;
        WeakSelf;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"POST" needCommonParams:YES requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
            StrongSelf;
            if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
                self.hasMoreToLoad = NO;
                self.isLoadingRequest = NO;
                if (finishBlock){
                    finishBlock(0,error);
                }
                return;
            }
            self.hasMoreToLoad = [jsonObj tt_boolValueForKey:@"has_more"];
            NSArray *data = [jsonObj tt_arrayValueForKey:@"data"];
            NSError *mappingError = nil;
            NSArray *models = [TTShortVideoModel arrayOfModelsFromDictionaries:data error:&mappingError];
            if ([models count] > 0){
                NSMutableArray *mutItems = [NSMutableArray arrayWithArray:self.awemedDetailItems];
                [mutItems addObjectsFromArray:models];
                self.awemedDetailItems = mutItems;
            }
            self.isLoadingRequest = NO;
            if (finishBlock){
                finishBlock(models.count,error);
            }
        }];
    } else if ([self numberOfShortVideoItems] > 0 && self.loadMoreType == TSVShortVideoListLoadMoreTypeActivity) {
        NSString *urlStr = [ArticleURLSetting shortVideoActivityListLoadMoreURL];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if ([self.awemedDetailItems count] > 1) {
            TTShortVideoModel *model = [self.awemedDetailItems lastObject];
            self.activityTopCursor = model.topCursor;
            self.activityCursor = model.cursor;
        }
        if (isEmptyString(self.activityTopCursor)) {
            self.activityTopCursor = @"-1";
        }
        if (isEmptyString(self.activityCursor)) {
            self.activityCursor = @"-1";
        }
        // activityForumID activitySortType 每次请求不变
        [params setValue:self.activityForumID forKey:@"forum_id"];
        [params setValue:self.activitySortType forKey:@"sort_type"];
        [params setValue:self.activityTopCursor forKey:@"top_cursor"];
        [params setValue:self.activityCursor forKey:@"cursor"];
        [params setValue:self.activitySeq forKey:@"seq"];
        self.isLoadingRequest = YES;
        WeakSelf;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"GET" needCommonParams:YES requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
            StrongSelf;
            if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
                self.hasMoreToLoad = NO;
                self.isLoadingRequest = NO;
                if (finishBlock){
                    finishBlock(0,error);
                }
                return;
            }
            NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
            self.hasMoreToLoad = [data tt_boolValueForKey:@"has_more"];
            self.activitySeq = [data tt_stringValueForKey:@"seq"];
            NSArray *videoList = [data tt_arrayValueForKey:@"video_list"];
            NSError *mappingError = nil;
            NSArray *models = [TTShortVideoModel arrayOfModelsFromDictionaries:videoList error:&mappingError];
            if ([models count] > 0){
                NSMutableArray *mutItems = [NSMutableArray arrayWithArray:self.awemedDetailItems];
                [mutItems addObjectsFromArray:models];
                self.awemedDetailItems = mutItems;
            }
            self.isLoadingRequest = NO;
            if (finishBlock) {
                finishBlock(models.count,error);
            }
        }];
    } else if ([self numberOfShortVideoItems] > 0 && self.loadMoreType == TSVShortVideoListLoadMoreTypeWeiTouTiao) {
        if (!self.decoupledFetchManager) {
            NSArray *items;
            if (self.awemedDetailItems.count > 0) {
                items = @[self.awemedDetailItems[0]];
            }
            
            if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
                self.decoupledFetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:items
                                                                                     requestCategoryID:kTTUGCVideoCategoryID
                                                                                    trackingCategoryID:kTTUGCVideoCategoryID
                                                                                          listEntrance:@"more_shortvideo_guanzhu"];
            } else {
                self.decoupledFetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:items
                                                                                     requestCategoryID:[NSString stringWithFormat:@"%@_detail_draw", kTTUGCVideoCategoryID]
                                                                                    trackingCategoryID:kTTUGCVideoCategoryID
                                                                                          listEntrance:@"more_shortvideo_guanzhu"];
            }
        }
        
        self.isLoadingRequest = YES;
        @weakify(self);
        [self.decoupledFetchManager requestDataAutomatically:isAutomatically finishBlock:^(NSUInteger increaseCount, NSError *error) {
            @strongify(self);
            self.isLoadingRequest = NO;
            self.hasMoreToLoad = self.decoupledFetchManager.hasMoreToLoad;
            self.awemedDetailItems = self.decoupledFetchManager.detailItems;
            
            if (finishBlock) {
                finishBlock(increaseCount, error);
            }
        }];
    } else if ([self numberOfShortVideoItems] > 0 && self.loadMoreType == TSVShortVideoListLoadMoreTypePush) {
        if (!self.decoupledFetchManager) {
            NSArray *items;
            if (self.awemedDetailItems.count > 0) {
                items = @[self.awemedDetailItems[0]];
            }
            
            if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
                self.decoupledFetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:items
                                                                                     requestCategoryID:kTTUGCVideoCategoryID
                                                                                    trackingCategoryID:kTTUGCVideoCategoryID
                                                                                          listEntrance:@"more_shortvideo_push"];
            } else {
                self.decoupledFetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:items
                                                                                     requestCategoryID:[NSString stringWithFormat:@"%@_detail_draw", kTTUGCVideoCategoryID]
                                                                                    trackingCategoryID:kTTUGCVideoCategoryID
                                                                                          listEntrance:@"more_shortvideo_push"];
            }
        }
        
        self.isLoadingRequest = YES;
        @weakify(self);
        [self.decoupledFetchManager requestDataAutomatically:isAutomatically finishBlock:^(NSUInteger increaseCount, NSError *error) {
            @strongify(self);
            self.isLoadingRequest = NO;
            self.hasMoreToLoad = self.decoupledFetchManager.hasMoreToLoad;
            self.awemedDetailItems = self.decoupledFetchManager.detailItems;
            
            if (finishBlock) {
                finishBlock(increaseCount, error);
            }
        }];
    } else {
        self.hasMoreToLoad = NO;
        self.isLoadingRequest = NO;
        if (finishBlock) {
            finishBlock(0, nil);
        }
    }
}

- (TSVShortVideoListEntrance)entrance
{
    if (self.loadMoreType == TSVShortVideoListLoadMoreTypePersonalHome) {
        return TSVShortVideoListEntranceProfile;
    } else {
        return TSVShortVideoListEntranceOther;
    }
}

@end

