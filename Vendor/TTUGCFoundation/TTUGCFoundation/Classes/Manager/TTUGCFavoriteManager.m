//
//  TTUGCFavoriteManager.m
//  TTUGCFoundation
//
//  Created by SongChai on 2018/2/8.
//

#import "TTUGCFavoriteManager.h"
#import "DetailActionRequestManager.h"
#import "Thread.h"

@implementation TTUGCFavoriteManager

+ (void)favoriteForThread:(Thread *)thread finishBlock:(void (^)(NSError *))finishBlock {
    if (thread.userRepined){
        return;
    }
    
    thread.userRepined = YES;
    [thread save];
    
    [self sendActionForThread:thread actionType:DetailActionTypeFavourite finishBlock:finishBlock];
}

+ (void)unfavoriteForThread:(Thread *)thread finishBlock:(void (^)(NSError *))finishBlock {
    if (!thread.userRepined){
        return;
    }
    
    thread.userRepined = NO;
    [thread save];
    
    [self sendActionForThread:thread actionType:DetailActionTypeUnFavourite finishBlock:finishBlock];
}

+ (void)sendActionForThread:(Thread *)thread  actionType:(DetailActionRequestType)type finishBlock:(void(^)(NSError *))finishBlock{
    
    if (thread == nil || thread.threadId.longLongValue == 0) {
        return;
    }
    
    DetailActionRequestManager *actionManager = [[DetailActionRequestManager alloc] init];
    actionManager.finishBlock = ^(id userInfo, NSError *error) {
        if (finishBlock) {
            finishBlock(error);
        }
    };
    
    TTGroupModel *groupModel = nil;
    groupModel = [[TTGroupModel alloc] initWithGroupID:thread.threadId];
    
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    context.extraDict = @{@"target_type":@(1)};
    [actionManager setContext:context];
    
    [actionManager startItemActionByType:type];
}

@end
