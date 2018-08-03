//
//  AKProfileBenefitManager.m
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import "ArticleURLSetting.h"
#import "ArticleBadgeManager.h"
#import "AKProfileBenefitModel.h"
#import "AKProfileBenefitManager.h"
#import <TTAccountManager.h>
#import <TTNetworkManager.h>
#import "AKTaskSettingHelper.h"
#import <TTTracker.h>
@implementation AKProfileBenefitManager

static AKProfileBenefitManager *shareInstance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AKProfileBenefitManager alloc] init];
    });
    return shareInstance;
}

- (void)requestBenefitInfoWithCompletion:(void (^)(NSArray<AKProfileBenefitModel *> *))completionBlock
{
    if (![AKTaskSettingHelper shareInstance].akBenefitEnable) {
        return;
    }
    if (![TTAccountManager isLogin]) {
        for (AKProfileBenefitModel *model in self.benefitModels) {
            model.digit = 0;
        }
        if (completionBlock) {
            completionBlock(self.benefitModels);
        }
        return;
    }
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting AKProfileBenefitInfo] params:@{@"sub_version" : @2} method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if ([jsonObj isKindOfClass:[NSDictionary class]] && !error) {
            NSDictionary *json = (NSDictionary *)jsonObj;
            NSDictionary *data = [json tt_dictionaryValueForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:3];
                AKProfileBenefitModel *model = [self modelWithType:@"score" inData:data];
                if (model) {
                    [models addObject:model];
                }
                model = [self modelWithType:@"cash" inData:data];
                if (model) {
                    [models addObject:model];
                }
                model = [self modelWithType:@"apprentice" inData:data];
                if (model) {
                    [models addObject:model];
                }
                NSArray *originModels = _benefitModels;
                self.benefitModels = models;
                [self postBadgeUpdateNotificationIfNeedWithNewModels:models originModels:originModels];
                if (completionBlock) {
                    completionBlock(models);
                }
            }
        }
    }];
}

- (AKProfileBenefitModel *)modelWithType:(NSString *)type inData:(NSDictionary *)data
{
    NSDictionary *result = [data tt_dictionaryValueForKey:type];
    if (result.count > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict addEntriesFromDictionary:result];
        [dict setValue:type forKey:@"type"];
        AKProfileBenefitModel *model = [[AKProfileBenefitModel alloc] initWithDictionary:dict error:nil];
        return model;
    }
    return nil;
}

- (void)postBadgeUpdateNotificationIfNeedWithNewModels:(NSArray<AKProfileBenefitModel *> *)newModels
                                          originModels:(NSArray<AKProfileBenefitModel *> *)originModels
{
    BOOL originNeed = [self needShowBadgeWithModels: originModels];
    BOOL newNeed = [self needShowBadgeWithModels:newModels];
    if (newNeed != originNeed) {
        [self postBadgeUpdateNotification];
    }
}

- (void)postBadgeUpdateNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kArticleBadgeManagerRefreshedNotification object:self];
}

- (BOOL)needShowBadgeWithModels:(NSArray<AKProfileBenefitModel *> *)models
{
    __block BOOL need = NO;
    [models enumerateObjectsUsingBlock:^(AKProfileBenefitModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.reddotInfo.needShow.boolValue) {
            need = YES;
            *stop = YES;
        }
    }];
    return need;
}

- (BOOL)needShowBadge
{
    return [self needShowBadgeWithModels:self.benefitModels];
}

- (void)trackForBenefitKey:(NSString *)benefitKey hasTip:(BOOL)hasTip
{
    NSString *event = @"";
    NSDictionary *param = @{@"with_tips": @(hasTip)};
    if ([benefitKey isEqualToString:@"score"]) {
        event = @"gold_income_click";
    } else if ([benefitKey isEqualToString:@"cash"]) {
        event = @"cash_income_click";
    } else if ([benefitKey isEqualToString:@"apprentice"]) {
        event = @"apprentice_click";
    }
    if (!isEmptyString(event)) {
        [TTTrackerWrapper eventV3:event params:param isDoubleSending:NO];
    }
}

@end
