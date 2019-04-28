//
//  TTLayOutCellDataHelper.h
//  Article
//
//  Created by 王双华 on 16/10/14.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOrderedData+TTBusiness.h"
#import "TTImageInfosModel.h"

@interface TTLayOutCellDataHelper : NSObject

+ (NSString *)getSourceImageUrlStringForUGCCellWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getSourceImageUrlStringForUFCellWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getSourceNameStringForUGCCellWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getSourceNameStringForUFCellWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getTitleStringWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getTitleStringForCommentCellWithOrderedData:(ExploreOrderedData *)data;

+ (NSArray *)getInfoStringWithOrderedData:(ExploreOrderedData *)data hideTimeLabel:(BOOL)hideTimeLabel;

+ (NSString *)getInfoStringForUFCellWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getUserVerifiedStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getTimeStringAndFollowStatusStringAndUserVerifiedStringOrRecommendReasonStringWithOrderedData:(ExploreOrderedData*)data;

+ (NSString *)getRecommendReasonStringWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getTimeStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getLikeStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getEntityStringWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getCommentStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getCommentNumberStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getForwardStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getDigNumberStringWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getTypeStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getAbstractStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getSubscriptStringWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)getTimeDurationStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getUserAuthInfoWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getUserDecorationWithOrderedData:(ExploreOrderedData *)data;
+ (BOOL)isFollowedWithOrderedData:(ExploreOrderedData *)data;
+ (BOOL)userIsFollowedByOthersWithOrderedData:(ExploreOrderedData *)data;

+ (BOOL)shouldShowPlayButtonWithOrderedData:(ExploreOrderedData *)data;
+ (void)setFollowed:(BOOL)followed withOrderedData:(ExploreOrderedData *)data;

+ (BOOL)userDiggWithOrderedData:(ExploreOrderedData *)data;

+ (NSString *)userIDWithOrderedData:(ExploreOrderedData *)data;

+ (NSDictionary *)getLogExtraDictionaryWithOrderedData:(ExploreOrderedData *)data;

@end

@interface TTLayOutCellDataHelper (TTAd_feedAdapter)
+ (BOOL)isADSubtitleUserInteractive:(ExploreOrderedData *)data;
+ (BOOL)isAdShowLocation:(ExploreOrderedData *)data;
+ (BOOL)isAdShowSourece:(ExploreOrderedData *)data;
+ (NSString *)getADSourceStringWithOrderedDada:(ExploreOrderedData *)data;
+ (NSString *)getAdLocationStringForUnifyADCellWithOrderData:(ExploreOrderedData *)data WithIndex:(NSInteger)index;
+ (NSString *)getCommentStringForUnifyADCellWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getInfoStringForUnifyADCellWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getSubtitleStringWithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getTitleStyle1WithOrderedData:(ExploreOrderedData *)data;
+ (NSString *)getTitleStyle2WithOrderedData:(ExploreOrderedData *)data;
@end
