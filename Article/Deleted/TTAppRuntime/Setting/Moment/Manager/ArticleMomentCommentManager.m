//
//  ArticleMomentCommentManager.m
//  Article
//
//  Created by Dianwei on 14-5-23.
//
//

#import "ArticleMomentCommentManager.h"
#import "ArticleMomentDetailView.h"
#import "ArticleURLSetting.h"
#import "ArticleMomentCommentModel.h"
#import "ArticleMomentModel.h"
#import "ArticleMomentManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNetworkManager.h"

@interface ArticleMomentCommentManager()
@property(nonatomic, retain)NSMutableOrderedSet *commentSet;
@property(nonatomic, retain)NSMutableOrderedSet *hotCommentSet; //热门评论
@property (nonatomic, strong) NSMutableOrderedSet *commentLayoutSet;
@property (nonatomic, strong) NSMutableOrderedSet *hotCommentLayoutSet;

@property(nonatomic, assign)int currentOffset;
@property(nonatomic, assign)BOOL hasMore;
@property(nonatomic, assign, readwrite,getter = isLoading)BOOL loading;
@property(nonatomic, assign) BOOL isNewComment;
@property(nonatomic, assign) BOOL isFromComment;
@end

@implementation ArticleMomentCommentManager

- (void)dealloc
{
    self.commentSet = nil;
    self.hotCommentSet = nil;
    self.commentLayoutSet = nil;
    self.hotCommentLayoutSet = nil;
    self.momentID = nil;
}

- (id)initWithMomentID:(NSString*)momentID isNewComment:(BOOL)isNewComment {
    return [self initWithMomentID:momentID isNewComment:isNewComment isFromeComment:NO];
}

- (id)initWithMomentID:(NSString*)momentID isNewComment:(BOOL)isNewComment isFromeComment:(BOOL)isFromeComment
{
    self = [super init];
    if(self)
    {
        self.momentID = momentID;
        self.commentSet = [[NSMutableOrderedSet alloc] init];
        self.hotCommentSet = [[NSMutableOrderedSet alloc] init];
        self.commentLayoutSet = [NSMutableOrderedSet new];
        self.hotCommentLayoutSet = [NSMutableOrderedSet new];
        self.isNewComment = isNewComment;
        self.isFromComment = isFromeComment;
        _hasMore = YES;
    }
    
    return self;
}

- (void)startLoadMoreCommentWithCount:(int) count width:(CGFloat)width finishBlock:(void(^)(NSArray *result, NSArray *hotComments, BOOL hasMore, int totalCount, NSError *error))finishBlock
{
    if(isEmptyString(_momentID))
    {
        SSLog(@"momentID must not be empty");
    }
    
    NSMutableDictionary *getParam = [NSMutableDictionary dictionaryWithCapacity:3];
    [getParam setValue:_momentID forKey:@"id"];
    [getParam setValue:@(count) forKey:@"count"];
    [getParam setValue:@(_currentOffset) forKey:@"offset"];
    
    int offset = _currentOffset;
    NSString *url = nil;
    if (_isNewComment) {
        if (_isFromComment) {
            url = [ArticleURLSetting replyedCommentListURLString];
        } else {
            url = [ArticleURLSetting momentCommentURLStringV4];
        }
    } else {
        url = [ArticleURLSetting momentCommentURLString];
    }
    __weak typeof(self) weakSelf = self;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int totalCount = 0;
            NSMutableArray *comments = nil;
            if(!error)
            {
                NSDictionary * resultDict = jsonObj;
                NSDictionary * data = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
                
                
                weakSelf.hasMore = [data integerValueForKey:@"has_more" defaultValue:0] != 0 ? YES : NO;
                weakSelf.currentOffset = [data intValueForKey:@"offset" defaultValue:0];
                
                totalCount = [data intValueForKey:@"total_count" defaultValue:0];
                
                NSArray * cmtData = [data arrayValueForKey:@"data" defaultValue:nil];
                NSArray *newComments = [ArticleMomentCommentModel commentsWithArray:cmtData];
                comments = [NSMutableArray arrayWithCapacity:cmtData.count];
                if (newComments.count) {
                    //删除掉本地数据
                    for (ArticleMomentCommentModel *comment in weakSelf.commentSet) {
                        if (comment.isLocal) {
                            [weakSelf.commentSet removeObject:comment];
                        }
                    }
                }
                for(ArticleMomentCommentModel *comment in newComments)
                {
                    if([weakSelf.commentSet containsObject:comment])
                    {
                        [weakSelf.commentSet replaceObjectAtIndex:[weakSelf.commentSet indexOfObject:comment] withObject:comment];
                    }
                    else
                    {
                        
                        comment.height = [ArticleMomentDetailViewCommentCell heightForCommentModel:comment cellWidth:width];
                        comment.descHeight = [ArticleMomentDetailViewCommentCell heightForDescLabel:comment width:width];
                        [weakSelf.commentSet addObject:comment];
                        [comments addObject:comment];
                    }
                }
                
                // 热门评论
                if (offset == 0) {
                    
                    NSArray * hotCommentsData = [data arrayValueForKey:@"hot_comments" defaultValue:nil];
                    NSArray *hotComments = [ArticleMomentCommentModel commentsWithArray:hotCommentsData];
                    for (ArticleMomentCommentModel *comment in hotComments) {
                        if ([weakSelf.hotCommentSet containsObject:comment]) {
                            [weakSelf.hotCommentSet replaceObjectAtIndex:[weakSelf.hotCommentSet indexOfObject:comment] withObject:comment];
                        } else {
                            
                            comment.height = [ArticleMomentDetailViewCommentCell heightForCommentModel:comment cellWidth:width];
                            comment.descHeight = [ArticleMomentDetailViewCommentCell heightForDescLabel:comment width:width];
                            [weakSelf.hotCommentSet addObject:comment];
                        }
                    }
                }
            }
            
            weakSelf.loading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(finishBlock)
                {     //如果offset=0 代表为第一次刷新评论
                    finishBlock(comments, !offset? [weakSelf hotComments]: nil, weakSelf.hasMore, totalCount, error);
                }
            });
        });
    }];
    
    _loading = YES;
}


+ (void)startPostCommentForComment:(NSString*)momentID
                         CommentID:(NSString*)commentID
                     commentUserID:(NSString*)commentUserID
                           content:(NSString*)content
                            source:(ArticleMomentSourceType)source
                         isForward:(BOOL)isForward
                   withFinishBlock:(void(^)(ArticleMomentCommentModel *model, NSError *error))finishBlock
{
    if(isEmptyString(momentID))
    {
        SSLog(@"momentID cannot be empty");
        return;
    }
    if (isEmptyString(content) && isForward) {
        content = NSLocalizedString(@"转发", nil);
    }
    NSMutableDictionary *postParam = [NSMutableDictionary dictionaryWithCapacity:4];
    [postParam setValue:momentID forKey:@"id"];
    [postParam setValue:content forKey:@"content"];
    /*
     * added 5.2:发布动态回复时不再转发到动态，当勾选时额外发一条评论（到ArticleCommentView中动态接口成功回调中处理），而评论后台会自动同步到用户动态
     */
    [postParam setValue:@(NO) forKey:@"forward"];
    if(!isEmptyString(commentID))
    {
        [postParam setValue:commentID forKey:@"reply_comment_id"];
    }
    
    if(!isEmptyString(commentUserID))
    {
        [postParam setValue:commentUserID forKey:@"reply_user_id"];
    }
    
    NSString *url = nil;
    if (source == ArticleMomentSourceTypeArticleDetail) {
        url = [ArticleURLSetting postReplyedCommentURLString];
    } else {
        url = [ArticleURLSetting momentPostCommentURLString];
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:postParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        ArticleMomentCommentModel *newComment = nil;
        if(!error)
        {
            NSDictionary * resultDict = jsonObj;
            NSDictionary * data = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
            NSDictionary *commentData = [data dictionaryValueForKey:@"comment" defalutValue:nil];
            newComment = [[ArticleMomentCommentModel alloc] initWithDictionary:commentData];
        }
        
        
        if(finishBlock)
        {
            finishBlock(newComment, error);
        }
    }];
}



- (NSArray*)comments
{
    return [_commentSet array];
}

- (NSArray *)hotComments
{
    return [_hotCommentSet array];
}

- (NSArray *)commentLayouts {
    
    return [_commentLayoutSet array];
}

- (NSArray *)hotCommentLayouts {
    
    return [_hotCommentLayoutSet array];
}

- (void)refreshLayoutsWithWidth:(CGFloat)width {
    NSArray<TTCommentDetailReplyCommentModel *> *hotComments = [self hotComments];
    [self.hotCommentLayoutSet removeAllObjects];
    [self.hotCommentLayoutSet addObjectsFromArray:[TTCommentDetailCellLayout arrayOfLayoutsFromModels:hotComments containViewWidth:width]];
    
    NSArray<TTCommentDetailReplyCommentModel *> *comments = [self comments];
    [self.commentLayoutSet removeAllObjects];
    [self.commentLayoutSet addObjectsFromArray:[TTCommentDetailCellLayout arrayOfLayoutsFromModels:comments containViewWidth:width]];
}

- (ArticleMomentCommentModel *)commentModelForID:(NSString *)cID
{
    if ([cID longLongValue] == 0) {
        return nil;
    }
    for (ArticleMomentCommentModel * model in [self comments]) {
        if ([model.ID longLongValue] == [cID longLongValue]) {
            return model;
        }
    }
    
    for (ArticleMomentCommentModel * model in [self hotComments]) {
        if ([model.ID longLongValue] == [cID longLongValue]) {
            return model;
        }
    }
    return nil;
}

- (void)insertComment:(TTCommentDetailReplyCommentModel *)comment
{
    if([_commentSet containsObject:comment])
    {
        [_commentSet replaceObjectAtIndex:[_commentSet indexOfObject:comment] withObject:comment];
    }
    else
    {
        if ([_commentSet count] > 0) {
            [_commentSet insertObject:comment atIndex:0];
        }
        else {
            [_commentSet addObject:comment];
        }
    }
}

- (void)insertCommentLayout:(TTCommentDetailCellLayout *)layout {
    
    if([_commentLayoutSet containsObject:layout])
    {
        [_commentLayoutSet replaceObjectAtIndex:[_commentLayoutSet indexOfObject:layout] withObject:layout];
    }
    else
    {
        if ([_commentLayoutSet count] > 0) {
            [_commentLayoutSet insertObject:layout atIndex:0];
        }
        else {
            [_commentLayoutSet addObject:layout];
        }
    }
}

- (void)deleteComment:(TTCommentDetailReplyCommentModel *)comment
{
    if (comment) {
        [_commentSet removeObject:comment];
    }
}

- (void)deleteCommentLayout:(TTCommentDetailCellLayout *)layout {
    
    if (layout) {
        
        [_commentLayoutSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([layout.identifier isEqualToString:((TTCommentDetailCellLayout *)obj).identifier]) {
                
                [_commentLayoutSet removeObject:obj];
                
                *stop = YES;
            }
        }];
    }
}

+ (void)startDiggCommentWithCommentID:(NSString *)commentID
                      withFinishBlock:(void(^)(NSError *error))finishBlock
{
    NSMutableDictionary *getParam = [NSMutableDictionary dictionaryWithCapacity:4];
    if (!isEmptyString(commentID))
    {
        [getParam setValue:commentID forKey:@"comment_id"];
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentCommentDiggURLString] params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

// 新的二级评论列表 by lijun.thinker
- (void)fetchCommentDetailListWithCommentID:(NSString *)commentID count:(int)count width:(CGFloat)width finishBlock:(void(^)(NSArray *result, NSArray *hotComments, BOOL hasMore, NSInteger totalCount, NSError *error))finishBlock {
    
    if(isEmptyString(_momentID))
    {
        SSLog(@"momentID must not be empty");
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
    [param setValue:@([commentID longLongValue]) forKey:@"id"];
    [param setValue:@(count) forKey:@"count"];
    [param setValue:@(_currentOffset) forKey:@"offset"];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting replyedCommentListURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        

        NSDictionary *dataDict = [jsonObj isKindOfClass:[NSDictionary class]]? [jsonObj dictionaryValueForKey:@"data" defalutValue:nil]: nil;
        
        NSInteger totalCount = [dataDict tt_integerValueForKey:@"total_count"];
        self.hasMore = [dataDict integerValueForKey:@"has_more" defaultValue:0] != 0 ? YES : NO;
        self.currentOffset = [dataDict intValueForKey:@"offset" defaultValue:0];

        NSArray *hotComments = [dataDict arrayValueForKey:@"hot_comments" defaultValue:nil];
        NSArray *allComments = [dataDict arrayValueForKey:@"data" defaultValue:nil];
        
        NSArray<TTCommentDetailReplyCommentModel *> *hotCommentModels = [TTCommentDetailReplyCommentModel arrayOfModelsFromDictionaries:hotComments];
        
        NSArray<TTCommentDetailReplyCommentModel *> *allCommentModels = [TTCommentDetailReplyCommentModel arrayOfModelsFromDictionaries:allComments];
        
        NSArray<TTCommentDetailCellLayout *> *hotCommentLayouts = [TTCommentDetailCellLayout arrayOfLayoutsFromModels:hotCommentModels containViewWidth:width];
        
        NSArray<TTCommentDetailCellLayout *> *allCommentLayouts = [TTCommentDetailCellLayout arrayOfLayoutsFromModels:allCommentModels containViewWidth:width];
        
        /*
        if (allCommentModels.count) {
            //删除掉本地数据 
            for (TTCommentDetailReplyCommentModel *comment in self.commentSet) {
                if (comment.isLocal) {
                    [weakSelf.commentSet removeObject:comment];
                }
            }
        }*/
        for(TTCommentDetailReplyCommentModel *comment in allCommentModels)
        {
            if([self.commentSet containsObject:comment])
            {
                [self.commentSet replaceObjectAtIndex:[self.commentSet indexOfObject:comment] withObject:comment];
            }
            else
            {
                [self.commentSet addObject:comment];
            }
        }
        
        for(TTCommentDetailCellLayout *commentLayout in allCommentLayouts)
        {
            if([self.commentLayoutSet containsObject:commentLayout])
            {
                [self.commentLayoutSet replaceObjectAtIndex:[self.commentLayoutSet indexOfObject:commentLayout] withObject:commentLayout];
            }
            else
            {
                [self.commentLayoutSet addObject:commentLayout];
            }
        }

        // 热门评论
        for (TTCommentDetailReplyCommentModel *comment in hotCommentModels) {
            if ([self.hotCommentSet containsObject:comment]) {
                [self.hotCommentSet replaceObjectAtIndex:[self.hotCommentSet indexOfObject:comment] withObject:comment];
            } else {
                
                [self.hotCommentSet addObject:comment];
            }
        }
        
        for (TTCommentDetailCellLayout *commentLayout in hotCommentLayouts) {
            if ([self.hotCommentLayoutSet containsObject:commentLayout]) {
                [self.hotCommentLayoutSet replaceObjectAtIndex:[self.hotCommentLayoutSet indexOfObject:commentLayout] withObject:commentLayout];
            } else {
                
                [self.hotCommentLayoutSet addObject:commentLayout];
            }
        }
        
        self.loading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(finishBlock)
            {     //如果offset=0 代表为第一次刷新评论
                finishBlock(self.comments, self.hotComments, self.hasMore, totalCount, error);
            }
        });
    }];
}

// 二级评论点赞
- (void)handleReplyCommentDigWithCommentID:(NSString *)commentID replayID:(NSString *)replayID userDigg:(BOOL)userDigg finishBlock:(void (^)(NSError *))finishBlock {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:3];
    [param setValue:commentID forKey:@"id"];
    [param setValue:replayID forKey:@"reply_id"];
    [param setValue:userDigg? @"cancel_digg": @"digg" forKey:@"action"];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting replyedCommentDigURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        (!finishBlock) ?: finishBlock(error);
    }];
}

@end
