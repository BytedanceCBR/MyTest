//
//  FHCommuteChooseView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import <UIKit/UIKit.h>
#import "FHCommuteType.h"

NS_ASSUME_NONNULL_BEGIN
//通行方式选择
@interface FHCommuteChooseView : UIView

@property(nonatomic , copy) NSString *chooseTime;
@property(nonatomic , assign) BOOL boldTitle;

-(instancetype)initWithFrame:(CGRect)frame type:(FHCommuteType)type durationItems:(NSArray<NSString *>*)items;

-(void)chooseType:(FHCommuteType)type;


@end

NS_ASSUME_NONNULL_END