//
//  TTVDetailFollowRecommendView.h
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "TTVDetailFollowRecommendCollectionView.h"

typedef void (^recordRecommendViewOffSetBlock)(CGPoint offset);

@interface TTVDetailFollowRecommendView : SSThemedView

@property (nonatomic, strong) TTVDetailFollowRecommendCollectionView *collectionView;
@property (nonatomic, assign) BOOL isSpread;
@property (nonatomic, copy) NSString *actionType;  //区别点击ArrowImage show事件
@property (nonatomic, assign) BOOL ifNeedToSendShowAction;
@property (nonatomic, copy) NSString *position;  //列表页 or 详情页
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSDictionary *rtFollowExtraDict; //统一关注动作埋点传入

@property (nonatomic, copy) recordRecommendViewOffSetBlock recordContentOffsetblc;

- (void)logRecommendViewAction;

@end
