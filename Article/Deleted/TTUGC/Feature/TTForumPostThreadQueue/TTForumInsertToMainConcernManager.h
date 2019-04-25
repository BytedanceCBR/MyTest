//
//  TTForumInsertToMainConcernManager.h
//  Article
//
//  Created by 徐霜晴 on 16/11/2.
//
//

#import <Foundation/Foundation.h>

@interface TTForumInsertToMainConcernManager : NSObject<Singleton>

//- (NSArray *)getTheadsNeedInsertToMainConcern;
//- (void)clearThreadsNeedInsertToMainConcern;
//
//- (NSArray *)getTheadsNeedInsertToFollowConcern;
//- (void)clearThreadsNeedInsertToFollowConcern;
//
//- (NSArray *)getThreadsNeedInsertToWeitoutiao;
//- (void)clearThreadsNeedInsertToWeitoutiao;

- (NSArray *)getThreadsNeedInsertToPageWithConcernID:(NSString *)concernID;

- (void)clearThreadNeedsInsertToPageWithConcernID:(NSString *)concernID;

@end
