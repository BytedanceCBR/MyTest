//
//  TTVDislikeAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import <Foundation/Foundation.h>
#import "TTVMoreAction.h"
#import "ExploreItemActionManager.h"

@interface TTVDislikeActionEntity : TTVMoreActionEntity
@property (nonatomic, strong) NSArray <NSDictionary *> *filterWords;
@property (nonatomic, weak) UIView *dislikePopFromView;//显示dislike pop from unInterestedButton
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic ,strong)NSNumber *adID;
@property (nonatomic, strong) NSString *logExtra;
@end

@interface TTVDislikeAction : TTVMoreAction
@property (nonatomic ,strong)TTVDislikeActionEntity *entity;
@property (nonatomic, copy) void (^didClickDislikeSubmitButtonBlock)(TTVFeedItem *cellEntity, NSArray *filterWords, CGRect dislikeAnchorFrame, TTDislikeSourceType dislikeSourceType);
@property (nonatomic, copy) void (^didTrakDislikeSubmiteActionBlock)(NSArray * filterWords);
- (instancetype)initWithEntity:(TTVDislikeActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@end
