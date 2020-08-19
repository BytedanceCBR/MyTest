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
@property (weak, nonatomic) UIImageView *titleImage;
@property (copy, nonatomic) NSString *bacImageUrl;
@property (assign, nonatomic) CGFloat viewHeight;
- (void)reloadDataWithDic:(NSDictionary *)dic;
- (void)updateWhenScrolledWithContentOffset:(CGFloat)offset isScrollTop:(BOOL)isScrollTop scrollView:(UIScrollView *)scrollView;
- (void)updateRealtorWithHeightScore;
@end

NS_ASSUME_NONNULL_END
