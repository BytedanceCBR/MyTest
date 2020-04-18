//
//  FHHouseSimilarManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/17.
//

#import "FHHouseSimilarManager.h"
#import "FHMainApi.h"
#import "TTHttpTask.h"

@interface FHHouseSimilarManager()
@property(nonatomic,strong)TTHttpTask *similarTask;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsModel> *similarItems;
@end

@implementation FHHouseSimilarManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)requestForSimilarHouse:(NSDictionary *)parmasIds
{
    if (self.similarTask) {
        [self.similarTask cancel];
        self.similarTask = nil;
    }
    self.similarTask = [FHMainApi requestHomeSimilarRecommend:parmasIds completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        if (model.data.items) {
            self.similarItems = model.data.items;
        }
    }];
}

- (NSArray *)getCurrentSimilarArray
{
    return self.similarItems;
}
@end
