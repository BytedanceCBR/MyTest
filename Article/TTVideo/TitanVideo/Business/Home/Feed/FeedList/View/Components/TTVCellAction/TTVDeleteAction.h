//
//  TTVDeleteAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVMoreAction.h"
#import "TTIndicatorView.h"


@interface TTVDeleteActionEntity : TTVMoreActionEntity
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *userId;
@end

@interface TTVDeleteAction : TTVMoreAction
@property (nonatomic ,strong)TTVDeleteActionEntity *entity;
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;

+ (void)showShareIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler;
@end
