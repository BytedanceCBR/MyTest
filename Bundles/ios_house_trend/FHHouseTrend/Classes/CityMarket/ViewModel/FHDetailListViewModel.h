//
//  FHDetailListViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHSectionCellPlaceHolder.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailListViewModel : NSObject<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<id<FHSectionCellPlaceHolder>>* sections;
@property (nonatomic, weak) UITableView* tableView;

-(void)addSectionPlaceHolder:(id<FHSectionCellPlaceHolder>)placeHolder;
-(void)adjustSectionOffset;
-(void)notifyCellDisplay;
@end

NS_ASSUME_NONNULL_END
