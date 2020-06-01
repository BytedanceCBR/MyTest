//
//  FHHouseAgentCardCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/6/1.
//

#import "FHListBaseCell.h"
#import "FHSearchBaseItemModel.h"
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseAgentCardCell : FHListBaseCell

- (void)bindData:(FHHouseNeighborAgencyModel *)model traceParams:(NSMutableDictionary *)params;

@end

NS_ASSUME_NONNULL_END
