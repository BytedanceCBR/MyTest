//
//  FHHouseComfortFindHeaderView.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/22.
//

#import <UIKit/UIKit.h>
#import "FHCommonDefines.h"
#import <FHHomeEntranceItemView.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseComfortFindHeaderView : UIView
@property(nonatomic,assign) NSUInteger itemsCount;
-(void)refreshView;
@end

NS_ASSUME_NONNULL_END
