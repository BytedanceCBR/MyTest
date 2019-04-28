//
//  TTVPGCAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"

@interface TTVPGCActionEntity : TTVMoreActionEntity
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *categoryId;
@property(nonatomic, strong) NSNumber *aggrType;
@property (nonatomic, assign) NSInteger refer;
@property (nonatomic, assign) BOOL isSubscribe;

@end

@interface TTVPGCAction : TTVMoreAction
@property (nonatomic ,strong)TTVPGCActionEntity *entity;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@end
