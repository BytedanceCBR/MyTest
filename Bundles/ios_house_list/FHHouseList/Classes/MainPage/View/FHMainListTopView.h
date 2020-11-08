//
//  FHMainListTopView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMainListTopView : UIView

-(instancetype)initWithBannerView:(UIView *)bannerView filterView:(UIView *)filterView filterTagsView:(UIView *)filterTagsView;

-(CGFloat)showNotify:(NSString *)message willCompletion:(void (^)(void))willCompletion;

-(CGFloat)filterTop;

-(CGFloat)filterBottom;

-(CGFloat)notifyHeight;

-(CGRect)relayout;

- (void)showFilterCorner:(BOOL)isShow;

- (CGFloat)filterHeight;

@end

NS_ASSUME_NONNULL_END
