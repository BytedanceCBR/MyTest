//
//  FHNewHouseDetailSectionController.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

CGFloat const FHNewHouseDetailSectionLeftMargin = 9;
CGFloat const FHNewHouseDetailSectionItemSpace = 9;

@class FHNewHouseDetailSectionModel,FHNewHouseDetailViewController;

@interface FHNewHouseDetailSectionController : IGListSectionController

@property (nonatomic, strong, nullable, readonly) FHNewHouseDetailSectionModel *sectionModel;

- (FHNewHouseDetailViewController *)detailViewController;

- (NSDictionary *)detailTracerDict;

- (NSDictionary *)subPageParams;

- (void)didUpdateToObject:(id)object NS_REQUIRES_SUPER;

- (__kindof UICollectionViewCell *)defaultCellAtIndex:(NSInteger)index;

@property (nonatomic, weak, readonly) NSMutableDictionary *elementShowCaches;

@end

@interface FHNewHouseDetailBindingSectionController : IGListBindingSectionController

@property (nonatomic, strong, nullable, readonly) FHNewHouseDetailSectionModel *sectionModel;

- (FHNewHouseDetailViewController *)detailViewController;

- (NSDictionary *)detailTracerDict;

- (NSDictionary *)subPageParams;

- (void)didUpdateToObject:(id)object NS_REQUIRES_SUPER;

- (__kindof UICollectionViewCell *)defaultCellAtIndex:(NSInteger)index;

@property (nonatomic, weak, readonly) NSMutableDictionary *elementShowCaches;

@end

NS_ASSUME_NONNULL_END
