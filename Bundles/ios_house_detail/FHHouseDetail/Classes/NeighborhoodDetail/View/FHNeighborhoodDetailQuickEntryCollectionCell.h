//
//  FHNeighborhoodDetailQuickEntryCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHDetailBaseCell.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailQuickEntryCollectionCell : FHDetailBaseCollectionCell<IGListBindable>
@property (nonatomic, copy) void (^quickEntryClickBlock)(NSString *quickEntryName);

@end

@interface FHNeighborhoodDetailQuickEntryModel : NSObject<IGListDiffable>

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
