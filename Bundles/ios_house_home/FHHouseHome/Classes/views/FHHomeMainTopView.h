//
//  FHHomeMainTopView.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import <UIKit/UIKit.h>
#import <HMSegmentedControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainTopView : UIView
@property(nonatomic,strong)HMSegmentedControl *segmentControl;
@property(nonatomic,strong)HMSegmentedControl *houseSegmentControl;

@property(nonatomic,copy) void (^indexChangeBlock)(NSInteger index);
@property(nonatomic,copy) void (^indexHouseChangeBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
