//
//  TTVFavoriteAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"


@interface TTVFavoriteActionEntity : TTVMoreActionEntity
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *adId;
@property(nonatomic, strong) NSNumber *aggrType;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, assign) BOOL userRepined;
@end

@interface TTVFavoriteAction : TTVMoreAction
@property (nonatomic ,strong)TTVFavoriteActionEntity *entity;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
@property (nonatomic, copy) void(^favoriteActionDone)(BOOL favorite);

- (void)execute:(TTActivityType)type;
@end



@interface TTVCommodityActionEntity : TTVMoreActionEntity
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *categoryId;
@end

@interface TTVCommodityAction : TTVMoreAction
@property (nonatomic ,strong)TTVCommodityActionEntity *entity;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@end
