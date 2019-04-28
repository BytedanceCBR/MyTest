//
//  TTVBuryAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"
#import "TTVDiggAction.h"

@interface TTVBuryAction : TTVMoreAction
@property (nonatomic ,strong)TTVDiggActionEntity *entity;
@property (nonatomic, weak) TTVDiggAction *diggAction;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@property (nonatomic, copy) void(^buryActionDone)(BOOL bury);

@end
