//
//  FHCommuteSlider.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import <UIKit/UIKit.h>
#import "FHCommuteType.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHCommuteSlider : UIView

@property(nonatomic , assign) CGFloat minValue;
@property(nonatomic , assign) CGFloat maxValue;

@property(nonatomic , assign) CGFloat value;

@property(nonatomic , assign) FHCommuteType type;

@property(nonatomic , copy) void (^updateValue)(CGFloat value , BOOL draging);

@end

NS_ASSUME_NONNULL_END
