//
//  FHHouseFindHelpRegionSheet.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import <UIKit/UIKit.h>
#import "FHFilterNodeModel.h"
#import "FHConditionPanelNodeSelection.h"
#import "FHFindHouseAreaSelectionPanel.h"

#define REGION_CONTENT_HEIGHT 258
#define REGION_CELL_ID @"region_cell_id"

typedef void(^FHHouseFindRegionCompleteBlock)(void);
typedef void(^FHHouseFindRegionCancelBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindHelpRegionItemCell: UITableViewCell

@property(nonatomic, strong) UILabel *regionLabel;
@property(nonatomic, strong) UIImageView *selectImgView;
@property(nonatomic, assign) BOOL regionSelected;

@end

@interface FHHouseFindHelpRegionSheet : UIView

@property(nonatomic, strong) FHFindHouseAreaSelectionPanel *areaPanel;
@property(nonatomic, weak) id tableViewDelegate;

- (void)setNodes:(NSArray<FHFilterNodeModel*>*)nodes;
- (void)setSelectedNodes:(NSArray<FHFilterNodeModel *> *)nodes selectedIndexes:(NSArray<NSNumber *> *)selectedIndexes;
- (NSArray<FHFilterNodeModel *> *)selectedNodes;
- (void)showWithCompleteBlock:(FHHouseFindRegionCompleteBlock)completeBlock cancelBlock:(FHHouseFindRegionCancelBlock)cancelBlock;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
