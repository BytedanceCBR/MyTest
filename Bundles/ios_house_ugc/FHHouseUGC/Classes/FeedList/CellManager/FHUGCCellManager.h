//
//  FHUGCCellManager.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHHouseUGCHeader.h"
#import "SSImpression_Emums.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellManager : NSObject

- (void)registerAllCell:(UITableView *)tableView;

- (Class)cellClassFromCellViewType:(FHUGCFeedListCellSubType)cellType data:(nullable id)data;

+ (SSImpressionModelType)impressModelTypeWithCellType:(FHUGCFeedListCellType)cellType;

@end

NS_ASSUME_NONNULL_END
