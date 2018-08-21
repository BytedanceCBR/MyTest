//
//  TTFoldCommentControllerViewModel.m
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import "TTFoldCommentControllerViewModel.h"
#import "TTCommentDataManager.h"
#import "TTCommentModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTBaseLib/TTBaseMacro.h>


@interface TTFoldCommentControllerViewModel ()
@property (nonatomic, strong) TTCommentDataManager *commentManager;
@property (nonatomic, strong) NSMutableArray<id<TTCommentModelProtocol>> *p_commentModels;
@property (nonatomic, strong) NSMutableArray<TTFoldCommentCellLayout *> *p_layouts;
@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, assign) NSInteger aggrType;
@property (nonatomic, strong) NSString *zzids;
@property (nonatomic, strong) NSString *forumID;

@property (nonatomic, assign) BOOL hasSendHeaderShowTracker;
@end

@implementation TTFoldCommentControllerViewModel

- (instancetype)initWithGroupID:(NSString *)groupID groupType:(TTCommentsGroupType)groupType itemID:(NSString *)itemID forumID:(NSString *)forumID aggrType:(NSInteger)aggrType zzids:(NSString *)zzids {
    self = [super init];
    if (self) {
        _groupID = groupID;
        _itemID = itemID;
        _aggrType = aggrType;
        _zzids = zzids;
        _groupType = groupType;
        _forumID = forumID;

    }
    return self;
}

- (void)loadCommentWithCompletionHandler:(void (^)(NSError *, BOOL))completion {
    __weak __typeof(self) weakSelf = self;
    [self.commentManager startFetchCommentsWithGroupID:self.groupID itemID:self.itemID forumID:self.forumID aggreType:self.aggrType loadMoreOffset:self.offset loadMoreCount:TTCommentDefaultLoadMoreFetchCount msgID:nil options:TTCommentLoadOptionsFold finishBlock:^(NSDictionary * _Nonnull jsonObj, NSError * _Nullable error, BOOL isStickComment) {
        
        BOOL hasMore = [jsonObj tt_boolValueForKey:@"has_more"];
        
        NSArray<NSDictionary *> *commentModels = [jsonObj tt_arrayValueForKey:@"data"];
        
        for (NSDictionary *commentModelDic in commentModels) {
            if (SSIsEmptyDictionary(commentModelDic)) {
                continue;
            }
            
            TTCommentModel *commentModel = [[TTCommentModel alloc] initWithDictionary:[commentModelDic tt_dictionaryValueForKey:@"comment"] groupModel:nil];
            
            if (!commentModel) {
                NSAssert(NO, @"%s%d", __FUNCTION__, __LINE__);
                continue;
            }
            TTFoldCommentCellLayout *layout = [[TTFoldCommentCellLayout alloc] initWithCommentModel:commentModel cellWidth:self.cellWidth];
            
            [weakSelf.p_commentModels addObject:commentModel];
            [weakSelf.p_layouts addObject:layout];
        }
        weakSelf.offset += TTCommentDefaultLoadMoreOffsetCount;
        if (completion) {
            completion(error, hasMore);
        }
    }];
}

- (void)sendHeaderShowTrackerIfNeed {

    if (self.hasSendHeaderShowTracker) {
        return;
    }
    self.hasSendHeaderShowTracker = YES;
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.itemID forKey:@"item_id"];
    [extra setValue:self.forumID forKey:@"forum_id"];
    [extra setValue:@"fold_comment_page" forKey:@"position"];
    wrapperTrackEventWithCustomKeys(@"fold_comment_reason", @"show", self.groupID, nil, extra);
}

- (NSArray<id<TTCommentModelProtocol>> *)commentModels {
    return self.p_commentModels.copy;
}

- (NSArray<TTFoldCommentCellLayout *> *)layouts {
    return self.p_layouts.copy;
}

- (NSMutableArray<id<TTCommentModelProtocol>> *)p_commentModels {
    if (!_p_commentModels) {
        _p_commentModels = [[NSMutableArray alloc] init];
    }
    return _p_commentModels;
}

- (NSMutableArray<TTFoldCommentCellLayout *> *)p_layouts {
    if (!_p_layouts) {
        _p_layouts = [[NSMutableArray alloc] init];
    }
    return _p_layouts;
}

- (TTCommentDataManager *)commentManager {
    if (!_commentManager) {
        _commentManager = [[TTCommentDataManager alloc] init];
    }
    return _commentManager;
}
@end
