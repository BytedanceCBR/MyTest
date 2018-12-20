//
//  FHMainManager+Toast.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHMainManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMainManager (Toast)

-(void)showToast:(NSString *)toast duration:(CGFloat)duration;

-(void)showToast:(NSString *)toast duration:(CGFloat)duration inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
