//
//  FHFindHouseAreaConditionFilterPanel.h
//  ios_house_filter
//
//  Created by leo on 2018/12/9.
//

#import <UIKit/UIKit.h>
#import "ConditionSelectPanelDelegate.h"
#import "FHConditionPanelNodeSelection.h"
#import "AreaConditionFilterPanel.h"
@class FHFilterNodeModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHFindHouseAreaSelectionPanel : UIView<ConditionSelectPanelDelegate, FHConditionPanelNodeSelection>
{
    NSMutableArray<HotLink*>* _hotLinks;
    NSMutableArray<UITableView*>* _tables;
    AreaSelectionTableViewVM* _lastListViewModel;
}
@property (nonatomic, strong) NSArray<AreaSelectionTableViewVM*>* selectionViewModels;
@property (nonatomic, strong) ButtomBarView* buttomBarView;
@property (nonatomic, weak) id<FHConditionPanelDelegate> delegate;
@property (nonatomic, weak) id<UserReactionListener> userReactionListener;
-(instancetype)initWithLastListViewModel:(AreaSelectionTableViewVM*)lastListViweModel;
-(void)setNodes:(NSArray<FHFilterNodeModel*>*)nodes;
-(void)addRightVerticalLineViewToMiddleView:(UIView*)target;
-(void)onExtendCategoryActivite;
-(void)onExtendCategoryDeactivite;
-(void)initLayoutTables;
-(NSArray<FHFilterNodeModel *> *)selectedNodes;

-(void)onReset:(id)sender;
@end

NS_ASSUME_NONNULL_END
