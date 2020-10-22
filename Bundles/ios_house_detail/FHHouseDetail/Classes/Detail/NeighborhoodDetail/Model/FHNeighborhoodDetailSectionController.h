//
//  FHNeighborhoodDetailSectionController.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHNeighborhoodDetailSectionModel,FHNeighborhoodDetailViewController;

@interface FHNeighborhoodDetailSectionController : IGListSectionController

@property (nonatomic, strong, nullable, readonly) FHNeighborhoodDetailSectionModel *sectionModel;

- (FHNeighborhoodDetailViewController *)detailViewController;

- (NSDictionary *)detailTracerDict;

- (NSDictionary *)subPageParams;

- (void)didUpdateToObject:(id)object NS_REQUIRES_SUPER;

@property (nonatomic, weak, readonly) NSMutableDictionary *elementShowCaches;

@end


@interface FHNeighborhoodDetailBindingSectionController : IGListBindingSectionController

@property (nonatomic, strong, nullable, readonly) FHNeighborhoodDetailSectionModel *sectionModel;

- (FHNeighborhoodDetailViewController *)detailViewController;

- (NSDictionary *)detailTracerDict;

- (NSDictionary *)subPageParams;

- (void)didUpdateToObject:(id)object NS_REQUIRES_SUPER;

@property (nonatomic, weak, readonly) NSMutableDictionary *elementShowCaches;

@end


NS_ASSUME_NONNULL_END
