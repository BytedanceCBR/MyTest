//
//  FHNeighborhoodDetailQuickEntryCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailQuickEntryCollectionCell : FHDetailBaseCollectionCell
@property (nonatomic, copy) void (^quickEntryClickBlock)(NSString *quickEntryName);

@end

@interface FHNeighborhoodDetailQuickEntryModel : NSObject

@property (nonatomic, strong) NSArray<NSString *> *quickEntryNames;
@property(nonatomic, copy, nullable) NSString *gaodeLng;
@property(nonatomic, copy, nullable) NSString *gaodeLat;
@property(nonatomic, copy, nullable) NSString *baiduPanoramaUrl;
@property(nonatomic, copy, nullable) NSString *mapCentertitle;
- (void)clearUpQuickEntryNames ;

@end

@interface FHNeighborhoodDetailQuickEntryView : UIButton

- (void)updateWithQuickEntryName : (NSString *)quickEntryName;

@end

NS_ASSUME_NONNULL_END
