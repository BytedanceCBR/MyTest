//
//  FHDetailTopBannerView.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailTopBannerView : UIView

- (void)updateWithTitle:(NSString *)title content:(NSString *)content isCanClick:(BOOL)isCanClick clickUrl:(NSString *)clickUrl;

@end


NS_ASSUME_NONNULL_END
