//
//  TTVDiggAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"

@interface TTVDiggActionEntity : TTVMoreActionEntity
@property (nonatomic, strong) NSNumber *buryCount;
@property (nonatomic, strong) NSNumber *diggCount;
@property (nonatomic, strong) NSNumber *userDigg;
@property (nonatomic, strong) NSNumber *userBury;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *categoryId;
@property(nonatomic, strong) NSNumber *aggrType;
@property(nonatomic, copy) NSString *adId;
@end

@class TTVBuryAction;
@interface TTVDiggAction : TTVMoreAction
@property (nonatomic, strong)TTVDiggActionEntity *entity;
@property (nonatomic, weak) TTVBuryAction *buryAction;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@property (nonatomic, copy) void(^diggActionDone)(BOOL digg);
@end
