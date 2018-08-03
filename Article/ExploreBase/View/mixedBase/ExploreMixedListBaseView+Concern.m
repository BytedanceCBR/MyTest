//
//  ExploreMixedListBaseView+Concern.m
//  Article
//
//  Created by Chen Hong on 16/5/25.
//
//

#import "ExploreMixedListBaseView+Concern.h"
#import "ExploreMixedListBaseView+HeaderView.h"
#import "TTUGCDefine.h"
#import "UIScrollView+Refresh.h"
//#import "Thread.h"
//#import "TTForumInsertToMainConcernManager.h"
#import "TTArticleCategoryManager.h"
//#import "TTForumPostThreadStatusCell.h"
#import "TTArticleCellConst.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "Article.h"
#import "TSVShortVideoOriginalData.h"

@implementation ExploreMixedListBaseView (Concern)

// 发帖，仅处理关心主页中的发帖
- (void)postThreadSendingNotification:(NSNotification *)notification {
//    if ([self isUnSpecialConcernPage]) {
//        //非特殊的关心主页
//        return;
//    }
//    NSDictionary *dict = notification.userInfo;
//    NSString *concernID = [dict valueForKey:kTTForumPostThreadConcernID];
//    if (self.refer != 2 || isEmptyString(concernID) || ![concernID isEqualToString:self.concernID]) {
//        return;
//    }
//
//    int64_t threadID = [dict tt_longlongValueForKey:@"thread_id"];
//    if (threadID == 0) {
//        return;
//    }
//    __block BOOL isExist = NO;
//    [self.fetchListManager.items enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj thread].threadId.longLongValue == threadID) {
//            isExist = YES;
//            *stop = YES;
//        }
//    }];
//    if (isExist) {
//        return;
//    }
//
//    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
//    [muDict setValue:self.concernID forKey:@"concernID"];
//    if (isEmptyString(self.categoryID)) {
//        [muDict setValue:@"" forKey:@"categoryID"];
//    }else {
//        [muDict setValue:self.categoryID forKey:@"categoryID"];
//    }
//    [muDict setValue:@(self.listType) forKey:@"listType"];
//    [muDict setValue:@(self.listLocation) forKey:@"listLocation"];
//    NSInteger cellFlag =
//    ExploreOrderedDataCellFlagShowCommentCount
//    |ExploreOrderedDataCellFlagShowSource
//    |ExploreOrderedDataCellFlagShowDig
//    |ExploreOrderedDataCellFlagU11ShowPadding
//    |ExploreOrderedDataCellFlagU11ShowTimeItem
//    |ExploreOrderedDataCellFlagU11ShowFollowButton;
//    [muDict setValue:@(cellFlag) forKey:@"cell_flag"];
//    [muDict setValue:@(TTLayOutCellLayOutStyle9) forKey:@"cell_layout_style"];
//
//    // 将帖子插到第一条，如果第一条是webCell或置顶，则插到第二条
//    [self.fetchListManager insertObjectToTopFromDict:muDict listType:self.listType];
//
//    [self reloadListViewWithVideoPlaying];
//
//    //发帖后回到顶部
//    [self updateCustomTopOffset];
//
//    [self.listView setContentOffset:CGPointMake(0, self.listView.customTopOffset - self.listView.contentInset.top) animated:NO];
}

// 发帖失败，仅处理关心主页中的发帖失败
- (void)postThreadFailNotification:(NSNotification *)notification {
//    if ([self isUnSpecialConcernPage]) {
//        //非特殊的关心主页
//        return;
//    }
//    NSDictionary *dict = notification.userInfo;
//    NSString *concernID = [dict valueForKey:kTTForumPostThreadConcernID];
//    if (self.refer != 2 || isEmptyString(concernID) || ![concernID isEqualToString:self.concernID]) {
//        return;
//    }
//
//    int64_t threadID = [dict tt_longlongValueForKey:kTTForumPostThreadFakeThreadID];
//
//    if (threadID == 0) {
//        return;
//    }
//
//    NSString *uniqueID = [NSString stringWithFormat:@"%lld", threadID];
//
//    NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
//
//    [orderedDataArray enumerateObjectsUsingBlock:^(ExploreOrderedData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.thread.isPosting = @(NO);
//        [obj.thread save];
//    }];
}

// 发帖成功，同时处理关心主页和微头条/视频发送成功
- (void)postThreadSuccessNotification:(NSNotification *)notification {
//    if ([self isUnSpecialConcernPage]) {
//        //非特殊的关心主页
//        return;
//    }
//    NSDictionary *dict = notification.userInfo;
//    NSString *concernID = [dict valueForKey:kTTForumPostThreadConcernID];
//
//    if (isEmptyString(concernID) || ![concernID isEqualToString:self.concernID]) {
//        return;
//    }
//
//    if (self.refer == 1) {
//        //频道
//        if ((![self.concernID isEqualToString:kTTMainConcernID] && ![self.concernID isEqualToString:KTTFollowPageConcernID] && (![self.concernID isEqualToString:kTTWeitoutiaoConcernID] || self.listLocation != ExploreOrderedDataListLocationWeitoutiao))) {
//            return;
//        }
//    }
//
//    if (self.refer == 2) {
//        // 删除之前的fake帖子，插入发送成功的帖子，只有在关心主页需要删除之前的fake帖子
//        int64_t threadID = [dict tt_longlongValueForKey:kTTForumPostThreadFakeThreadID];
//        if (threadID != 0) {
//            NSMutableArray * orderedDataArray = [NSMutableArray array];
//            [self.fetchListManager.items enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (obj.originalData.uniqueID == threadID) {
//                    [orderedDataArray addObject:obj];
//                }
//            }];
//            // 删除列表数据源中的models
//            [orderedDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self.fetchListManager removeItemIfExist:obj];
//            }];
//
//            // 删除数据库中的models
//            NSString *uniqueID = [NSString stringWithFormat:@"%lld", threadID];
//            [ExploreOrderedData removeEntities:[ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}]];
//        }
//    }
//
//    // 如果服务端打包失败，返回 thread 字段为空，仍然提示成功
//    int64_t threadID = [dict tt_longlongValueForKey:@"thread_id"];
//    int64_t uniqueID = [dict tt_longlongValueForKey:@"uniqueID"];
//    if (threadID == 0 && uniqueID == 0) {
//        [self tt_endUpdataData:NO error:nil];
//        return;
//    }
//
//    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
//    [muDict setValue:self.concernID forKey:@"concernID"];
//    if (isEmptyString(self.categoryID)) {
//        [muDict setValue:@"" forKey:@"categoryID"];
//    }else {
//        [muDict setValue:self.categoryID forKey:@"categoryID"];
//    }
//
//    [muDict setValue:@(self.listType) forKey:@"listType"];
//    [muDict setValue:@(self.listLocation) forKey:@"listLocation"];
//    [muDict setValue:@([[muDict tt_stringValueForKey:@"item_id"] longLongValue]) forKey:@"itemID"];
//
//
//    // 将帖子插到第一条，如果第一条是webCell或置顶，则插到第二条
//    ExploreOrderedData * orderData = [self.fetchListManager insertObjectToTopFromDict:muDict listType:ExploreOrderedDataListTypeCategory];
//
//    //如果是转发／转发并评论／转发并回复
//    if (1 == self.refer && ((orderData.thread && orderData.thread.repostOriginType != TTThreadRepostOriginTypeNone) || orderData.commentRepostModel)) {
//        //发送成功的是转发帖子，下面逻辑是保证转发时候，列表依然停留在原来的位置
//        __block NSInteger ridx = -1;
//        [self.fetchListManager.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (obj && [obj isKindOfClass:[ExploreOrderedData class]]) {
//
//                if (obj == orderData) {
//                    ridx = idx;
//                    *stop = YES;
//                }
//            }
//        }];
//        if (ridx >= 0) {
//            CGPoint contentOffset = self.listView.contentOffset;
//            NSIndexPath * rIndexPath = [NSIndexPath indexPathForRow:ridx inSection:ExploreMixedListBaseViewSectionExploreCells];
//            //增加新插入帖子的高度
//            contentOffset.y += [self.listView.delegate tableView:self.listView heightForRowAtIndexPath:rIndexPath];
//            //增加插入帖子的时候增加的padding
//            contentOffset.y += kUFSeprateViewHeight();
//            //减少posting cell的高度
//            [self reloadListViewWithVideoPlaying];
//            [self.listView setContentOffset:contentOffset];
//        }else {
//            [self reloadListViewWithVideoPlaying];
//        }
//    }else {
//        [self reloadListViewWithVideoPlaying];
//    }
//    [self tt_endUpdataData:NO error:nil];
}

// 删除发送失败的帖子，仅处理关心主页中删除发送失败的帖子
- (void)deleteFakeThreadNotification:(NSNotification *)notification {
    if ([self isUnSpecialConcernPage]) {
        //非特殊的关心主页
        return;
    }
    NSDictionary *dic = notification.userInfo;
    NSString *concernID = [dic valueForKey:kTTForumPostThreadConcernID];
    if (self.refer != 2 || isEmptyString(concernID) || ![concernID isEqualToString:self.concernID]) {
        return;
    }
    
    int64_t threadID = [dic tt_longlongValueForKey:kTTForumPostThreadFakeThreadID];
    if (threadID != 0) {
        NSMutableArray *orderedDataArray = [NSMutableArray array];
        [self.fetchListManager.items enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.originalData.uniqueID == threadID) {
                [orderedDataArray addObject:obj];
            }
        }];
        // 删除列表数据源中的models
        [orderedDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.fetchListManager removeItemIfExist:obj];
        }];
        
        // 删除数据库中的models
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", threadID];
        [ExploreOrderedData removeEntities:[ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}]];
        
        [self reloadListViewWithVideoPlaying];
    }
}

//删除帖子，同时处理关心主页和微头条的帖子
- (void)deleteThreadNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    int64_t threadID = [dic tt_longlongValueForKey:kTTForumThreadID];
    if (threadID != 0) {
        NSMutableArray * orderedDataArray = [NSMutableArray array];
        [self.fetchListManager.items enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.originalData.uniqueID == threadID) {
                [orderedDataArray addObject:obj];
            }
        }];
        // 删除列表数据源中的models
        [orderedDataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.fetchListManager removeItemIfExist:obj];
        }];

        [self reloadListViewWithVideoPlaying];
        [self tt_endUpdataData:NO error:nil];
    }
}

- (void)deleteCommentRepostNotification:(NSNotification *)notification {
    
    NSDictionary *dic = notification.userInfo;
    int64_t commentRepostID = [dic tt_longlongValueForKey:@"id"];
    if (commentRepostID != 0) {
        NSMutableArray * orderedDataArray = [NSMutableArray array];
        [self.fetchListManager.items enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.originalData.uniqueID == commentRepostID) {
                [orderedDataArray addObject:obj];
            }
        }];
        // 删除列表数据源中的models
        [orderedDataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.fetchListManager removeItemIfExist:obj];
        }];
        
        [self reloadListViewWithVideoPlaying];
        [self tt_endUpdataData:NO error:nil];
    }
}

//删除视频
- (void)deleteVideoNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    int64_t groupID = [dic tt_longlongValueForKey:@"uniqueID"];
    if (groupID != 0) {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", groupID];
        
        NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
        NSArray *articlesArray = [Article objectsWithQuery:@{@"uniqueID": uniqueID}];
        [articlesArray enumerateObjectsUsingBlock:^(Article *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[Article class]] && obj.articleDeleted.boolValue == NO) {
                obj.articleDeleted = @(YES);
            }
        }];
        // 删除列表数据源中的models
        [orderedDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.fetchListManager removeItemIfExist:obj];
        }];
        [self reloadListViewWithVideoPlaying];
        [self tt_endUpdataData:NO error:nil];
    }
}

- (void)deleteShortVideoNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    int64_t groupID = [dic tt_longlongValueForKey:kTSVShortVideoDeleteUserInfoKeyGroupID];
    if (groupID != 0) {
        NSString *uniqueID = [dic tt_stringValueForKey:kTSVShortVideoDeleteUserInfoKeyGroupID];
        
        NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
        NSArray *articlesArray = [Article objectsWithQuery:@{@"uniqueID": uniqueID}];
        [articlesArray enumerateObjectsUsingBlock:^(Article *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[Article class]] && obj.articleDeleted.boolValue == NO) {
                obj.articleDeleted = @(YES);
            }
        }];
        // 删除列表数据源中的models
        [orderedDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.fetchListManager removeItemIfExist:obj];
        }];
        [self reloadListViewWithVideoPlaying];
        [self tt_endUpdataData:NO error:nil];
    }
}

////插入未被混排列表监听到的微头条/视频
//- (void)insertThreadsAndVideosToFeedIfNeededWithIsFromRemote:(BOOL)isFromRemote{
//
//    if (self.refer == 1 && ([self.concernID isEqualToString:kTTMainConcernID] || [self.concernID isEqualToString:KTTFollowPageConcernID] || ([self.concernID isEqualToString:kTTWeitoutiaoConcernID] && self.listLocation == ExploreOrderedDataListLocationWeitoutiao))) {
//
//        NSArray *threadsNeedInsert = nil;
//
//        threadsNeedInsert = [[TTForumInsertToMainConcernManager sharedInstance_tt] getThreadsNeedInsertToPageWithConcernID:self.concernID];
//
//        //推荐频道与微头条逻辑，读完接着删，关注频道暂时不删，要等到一次remote刷新之后再删
//        if ([self.concernID isEqualToString:kTTMainConcernID] || [self.concernID isEqualToString:kTTWeitoutiaoConcernID]) {
//            [[TTForumInsertToMainConcernManager sharedInstance_tt] clearThreadNeedsInsertToPageWithConcernID:self.concernID];
//        }
//
//        [threadsNeedInsert enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (![dict isKindOfClass:[NSDictionary class]]) {
//                return;
//            }
//
//
//            NSTimeInterval postThreadSucessTime = [dict tt_doubleValueForKey:kFRPostThreadSucessTime];
//            NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
//
//            BOOL isMoreThanMiniute = (curTime - postThreadSucessTime) > 60;
//            if (isMoreThanMiniute) {
//                [[TTForumInsertToMainConcernManager sharedInstance_tt] clearThreadNeedsInsertToPageWithConcernID:self.concernID];
//                return;
//            }
//
//            NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
//            [muDict setValue:self.concernID forKey:@"concernID"];
//            if (isEmptyString(self.categoryID)) {
//                [muDict setValue:@"" forKey:@"categoryID"];
//            }else {
//                [muDict setValue:self.categoryID forKey:@"categoryID"];
//            }
//
//            [muDict setValue:@(self.listType) forKey:@"listType"];
//            [muDict setValue:@(self.listLocation) forKey:@"listLocation"];
//            [muDict setValue:@([muDict tt_longlongValueForKey:@"item_id"]) forKey:@"itemID"];
//
//            NSString *uniqueID = [muDict tt_stringValueForKey:@"uniqueID"];
//
//            // 如果服务端打包失败，thread 字段为空，uniqueID == nil，此时清空待强插数据
//            if (isEmptyString(uniqueID)) {
//                [[TTForumInsertToMainConcernManager sharedInstance_tt] clearThreadNeedsInsertToPageWithConcernID:self.concernID];
//                return;
//            }
//
//            NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
//
//            //之前未被监听到
//            if ([orderedDataArray count] == 0) {
//
//                //对于添加至列表内存的逻辑（关注频道），此时无论是否自动刷新／手动刷新，还是从local中取数据，都要把数据添加至列表，内部加了去重逻辑
//                [self.fetchListManager insertObjectToTopFromDict:muDict listType:ExploreOrderedDataListTypeCategory];
//
//                //对于删除逻辑（关注频道），若是从local中取数据取的数据，则需要继续保存数据；否则只要遇到的是刷新逻辑（无论是自动刷新还是主动刷新），都要删除数据。这块需要注意测试缓存被删除的情况--------
//                if ([self.concernID isEqualToString:KTTFollowPageConcernID] && isFromRemote){
//                    [[TTForumInsertToMainConcernManager sharedInstance_tt] clearThreadNeedsInsertToPageWithConcernID:self.concernID];
//                }
//            }
//
//            //之前可能添加过
//            else {
//                __block BOOL hasValidOrderdData = NO;
//
//                //之前确实被添加过
//                [orderedDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([obj isKindOfClass:[ExploreOrderedData class]]) {
//                        ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
//                        if (orderedData.behotTime > 0) {
//                            hasValidOrderdData = YES;
//                        }
//                    }
//                }];
//
//
//                //如果是关注频道的话
//                if ([self.concernID isEqualToString:KTTFollowPageConcernID] && isFromRemote) {
//
//                    //对于添加至列表内存的逻辑：如果是关注频道，即使之前被添加过，也要在remote的时候再次添加一次（此时无论是不是hasmore == yes，都执行重新给他加一次，但是 如果此时fetchListManager.items里面已经有了数据的话，那就不给他加进去了，保持fetchListManager.items里面原有的数据，其实就是去重操作，保证fetchListManager.items里面有一条数据即可）
//                    hasValidOrderdData = NO;
//
//                    //对于删除逻辑，对于是本地读取的操作，需要继续保存数据，否则只要经过了一次fromRemote），都要把数据库里的数据删除掉
//                    [[TTForumInsertToMainConcernManager sharedInstance_tt] clearThreadNeedsInsertToPageWithConcernID:self.concernID];
//                }
//
//                if (!hasValidOrderdData) {
////                    [orderedDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////                        [self.fetchListManager removeItemIfExist:obj];
////                    }];
//
//                    //内部加了去重逻辑，保证在插入的过程中，如果列表中已经有了这条数据了，就不给他插入，也不给他置顶了
//                    [self.fetchListManager insertObjectToTopFromDict:muDict listType:ExploreOrderedDataListTypeCategory];
//                }
//            }
//        }];
//    }
//}

- (BOOL)isUnSpecialConcernPage {
    return self.refer == 2 && !self.specialConcernPage;
}

@end
