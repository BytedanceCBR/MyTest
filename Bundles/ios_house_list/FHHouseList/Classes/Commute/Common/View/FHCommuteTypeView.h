//
//  FHCommuteTypeView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import <UIKit/UIKit.h>
#import "FHCommuteType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommuteTypeView : UIView

@property(nonatomic , copy) void (^updateType)(FHCommuteType type);

-(void)chooseType:(FHCommuteType)type;

-(FHCommuteType)currentType;

@end

NS_ASSUME_NONNULL_END
