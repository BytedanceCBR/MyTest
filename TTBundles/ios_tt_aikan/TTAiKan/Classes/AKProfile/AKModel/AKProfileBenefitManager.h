//
//  AKProfileBenefitManager.h
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import <Foundation/Foundation.h>

@class AKProfileBenefitModel;
@interface AKProfileBenefitManager : NSObject

+ (instancetype)shareInstance;
@property (nonatomic, copy)NSArray<AKProfileBenefitModel *>       *benefitModels;

- (void)requestBenefitInfoWithCompletion:(void(^)(NSArray<AKProfileBenefitModel *> * model))completionBlock;
- (BOOL)needShowBadge;
- (void)postBadgeUpdateNotification;
- (void)trackForBenefitKey:(NSString *)benefitKey hasTip:(BOOL)hasTip;
@end
