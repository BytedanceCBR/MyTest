//
//  FHDetailHalfPopInfoCell.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 信息质检
@class FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel,FHDetailDataBaseExtraDetectiveReasonListItem;
@interface FHDetailHalfPopInfoCell : UITableViewCell

-(void)updateWithModel:(FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel *)model;
-(void)updateWithReasonInfoItem:(FHDetailDataBaseExtraDetectiveReasonListItem *)reasonInfoItem;

@end

NS_ASSUME_NONNULL_END
