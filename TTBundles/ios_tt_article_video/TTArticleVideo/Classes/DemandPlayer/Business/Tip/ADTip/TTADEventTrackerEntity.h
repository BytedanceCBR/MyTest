//
//  TTADEventTrackerEntity.h
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"
@class TTVFeedListItem;
@class ExploreOrderedData;
@class TTVFeedListItem;
@interface TTADEventTrackerEntity : NSObject<TTAd>
@property (nonatomic, copy) NSArray *adClickTrackURLs;
@property (nonatomic, copy) NSArray *adTrackURLs;
//@property (nonatomic, strong) NSString *adID;
//@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, strong) NSNumber *aggrType;
@property (nonatomic, strong) NSString *uniqueid;
@property (nonatomic, assign) NSInteger showScene;
@property (nonatomic, weak) TTVFeedListItem *feedListItem;
/**
 @param data TTVFeedItem or ExploreOrderedData
 */
+ (TTADEventTrackerEntity *)entityWithData:(id)data;
+ (TTADEventTrackerEntity *)entityWithData:(id)data item:(TTVFeedListItem *)item;
@end


