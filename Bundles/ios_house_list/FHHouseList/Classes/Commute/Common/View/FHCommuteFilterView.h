//
//  FHCommuteFilterView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import <UIKit/UIKit.h>
#import "FHCommuteTypeView.h"
#import "FHCommuteChooseView.h"

NS_ASSUME_NONNULL_BEGIN
//通勤选择
@interface FHCommuteFilterView : UIView

@property(nonatomic , strong) FHCommuteTypeView *typeView;
@property(nonatomic , strong) FHCommuteChooseView *timeChooseView;
@property(nonatomic , assign , readonly) FHCommuteType type;
@property(nonatomic , strong , readonly) NSString *time;
@property(nonatomic , copy) void (^chooseBlock)(NSString *time , FHCommuteType type);

-(instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets type:(FHCommuteType) type;

-(void)updateType:(FHCommuteType)type time:(NSString *)time;

@end

NS_ASSUME_NONNULL_END
