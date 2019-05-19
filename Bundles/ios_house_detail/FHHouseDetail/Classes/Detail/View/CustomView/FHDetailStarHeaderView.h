//
//  FHDetailStarHeaderView.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailStarHeaderView : UIView

- (void)updateStarsCount:(NSInteger)scoreValue;
- (void)updateTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
