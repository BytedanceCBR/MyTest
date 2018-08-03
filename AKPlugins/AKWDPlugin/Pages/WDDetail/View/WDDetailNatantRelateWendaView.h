//
//  WDDetailNatantRelateWendaView.h
//  Article
//
//  Created by 延晋 张 on 16/4/27.
//
//

#import "WDDetailNatantViewBase.h"
#import "WDDetailNatantItemModel.h"

@class WDDetailModel;

@interface WDDetailNatantRelateWendaView : WDDetailNatantViewBase

@property(nonatomic, strong, nullable)WDDetailModel * detailModule;

+ (nullable WDDetailNatantRelateWendaView *)genViewForModel:(nullable WDDetailNatantRelatedItemModel *)model
                                                          width:(float)width;

- (void)hideBottomLine:(BOOL)hide;

@end
