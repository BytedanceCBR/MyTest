//
//  ArticleMomentDiggManager.h
//  Article
//
//  Created by Dianwei on 14-5-27.
//
//

#import <Foundation/Foundation.h>

@interface ArticleMomentDiggManager : NSObject
@property(nonatomic, strong)NSString *ID;  //评论详情和动态详情要拆分. 暂时先收敛到这里, 后面拆分 @zengruihuan
+ (void)startDiggMoment:(NSString*)momentID finishBlock:(void(^)(int newCount, NSError *error))finishBlock;
+ (void)undoDiggMoment:(NSString *)momentID finishBlock:(void(^)(NSError *error))finishBlock;
- (instancetype)initWithMomentID:(NSString*)momentID;
- (instancetype)initWithCommentID:(NSString*)commentID;
/**
 获取动态的用户列表
 */
- (void)startGetDiggedUsersWithOffset:(int)offset count:(int)count finishBlock:(void(^)(NSArray *users, NSInteger totalCount, NSInteger anonymousCount, BOOL hasMore, NSError *error))finishBlock;


- (void)insertDiggUsers:(NSArray*)users atFirst:(BOOL)isFirst;
@property(nonatomic, assign, readonly, getter = isLoading)BOOL loading;
@property(nonatomic, retain, readonly)NSArray *diggUsers;
@property(nonatomic, assign)NSInteger anonymousCount;
@end
