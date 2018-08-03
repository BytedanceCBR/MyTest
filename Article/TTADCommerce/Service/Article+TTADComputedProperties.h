//
//  Article+TTADComputedProperties.h
//  Article
//
//  Created by pei yun on 2017/9/19.
//
//

#import "Article.h"
#import "ExploreOrderedADModel.h"
#import "TTAdFeedDefine.h"
#import "TTAdFeedModel.h"

@interface Article (TTADComputedProperties)

@property (nonatomic, strong, readonly, nullable) id<TTAdFeedModel> adModel;
@property (nonatomic, strong, readonly, nullable) ExploreOrderedADModel *exploreAdModel;
@property (nonatomic, strong, readonly, nullable) TTAdFeedModel *rawAd;

// feed接口重新下发Article数据时清楚之前缓存的model
- (void)clearCachedModels;

// 判断是否为广告样式， 号外广告没有广告样式
- (BOOL)isAd;

@end
