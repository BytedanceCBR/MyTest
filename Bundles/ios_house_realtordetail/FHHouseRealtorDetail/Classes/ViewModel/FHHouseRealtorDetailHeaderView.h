//
//  FHHouseRealtorDetailHeaderView.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailHeaderView : UIView
@property (weak, nonatomic) UIViewController *controller;
@property (copy, nonatomic) NSString *channel;
@property (copy, nonatomic) NSString *bacImageName;
@property (assign, nonatomic) CGFloat viewHeight;
@end

NS_ASSUME_NONNULL_END
