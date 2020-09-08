//
//  FHNewHouseDetailSectionController.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailSectionModel,FHNewHouseDetailViewController;
@interface FHNewHouseDetailSectionController : IGListSectionController

@property (nonatomic, strong, nullable, readonly) FHNewHouseDetailSectionModel *sectionModel;

@property (nonatomic, weak, nullable, readonly) FHNewHouseDetailViewController *detailViewController;

- (void)didUpdateToObject:(id)object NS_REQUIRES_SUPER;
@end

NS_ASSUME_NONNULL_END
