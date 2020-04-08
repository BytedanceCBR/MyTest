//
//  FHFloorPanListCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanListCell : FHDetailBaseCell

- (void)refreshWithData:(id)data isFirst:(bool)isFirst isLast:(BOOL)isLast;

@end

NS_ASSUME_NONNULL_END
