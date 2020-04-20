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
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property (nonatomic, assign) NSTimeInterval configTime;//服务端下发时间

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
            self.stayTime = [[NSDate date] timeIntervalSince1970];
            self.configTime = [model.data.triggerTime integerValue];
        }
    }];
}

- (BOOL)checkTimeIsInvalid{
    if (self.configTime == 0) {
        return YES;
    }
     NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] -  self.stayTime);
    if (duration > self.configTime) {
        return YES;
    }else{
        return NO;
    }
}

- (NSArray *)getCurrentSimilarArray
{
    return self.similarItems;
}

- (void)resetSimilarArray
{
    self.similarItems = nil;
}

@end
