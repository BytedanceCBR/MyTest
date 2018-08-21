//
//  TTRecommendRedpacketUserViewController.h
//  Article
//
//  Created by lipeilun on 2017/10/26.
//

#import "SSViewControllerBase.h"

@class TTRecommendRedpacketAction;
@class RecommendRedpacketData;

typedef void (^TTRecommendRedpacketUserDismissBlock)(NSSet *userSet);

@interface TTRecommendRedpacketUserViewController : SSViewControllerBase

@property (nonatomic, copy) NSString *categoryName; // 卡片出现的频道
@property (nonatomic, copy) NSString *recommendType; // 推人理由
@property (nonatomic, strong) RecommendRedpacketData *recommendRedpacketData;
@property (nonatomic, copy) TTRecommendRedpacketUserDismissBlock dismissBlock;

@property (nonatomic, strong) TTRecommendRedpacketAction *action;

/**
 * 初始化方法
 * @param userArray 关注用户列表
 * @param title 页面标题
 * @param buttonFormat 关注按钮文字格式
 * @return
 */
- (instancetype)initWithRelatedUsers:(NSArray *)userArray title:(NSString *)title buttonFormat:(NSString *)buttonFormat;

@end
