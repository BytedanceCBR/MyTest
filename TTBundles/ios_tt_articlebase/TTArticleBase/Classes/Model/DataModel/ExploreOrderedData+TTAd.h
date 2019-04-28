//
//  ExploreOrderedData+TTAd.h
//  Article
//
//  Created by carl on 2017/10/18.
//

#import "ExploreOrderedData.h"

#import "TTAdFeedDefine.h"

@class TTVPlayerUrlTracker,TTADTrackEventLinkModel,ExploreOrderedADModel,TTAdFeedModel;

@interface ExploreOrderedData (TTAd)

@property (nonatomic, strong, nullable) TTAdFeedModel   *raw_ad;
@property (nonatomic, strong, nullable) TTADTrackEventLinkModel *adEventLinkModel;
@property (nonatomic, strong, nullable, readonly) id<TTAdFeedModel> adModel;
@property (nonatomic, copy, nullable, readonly) NSString *ad_id;
@property (nonatomic, copy, nullable, readonly) NSString *log_extra;
@property (nonatomic, copy, nullable, readonly) NSDictionary *adExtraData;

/**
 包含创意标识 id 都是广告数据
 不区分 号外 伪装广告 还是明显标识广告
 @return 是否包含推广数据
 */
- (BOOL)isAd;
- (BOOL)isAdButtonUnderPic;
- (BOOL)isAdExpire;
- (nullable ExploreOrderedADModel *)exploreAdModel;
- (nullable TTVPlayerUrlTracker *)videoPlayTracker;

- (NSDictionary *)realTimeAdExtraData:(NSString *)tag label:(NSString *)label extraData:( NSDictionary *)extraData;

@end
