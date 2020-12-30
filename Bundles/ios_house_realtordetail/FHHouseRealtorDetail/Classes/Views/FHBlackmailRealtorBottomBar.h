//
//  FHBlackmailRealtorBottomBar.h
//  FHHouseRealtorDetail
//
//  Created by wangzhizhou on 2020/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHBlackmailRealtorBottomBar : UIView
@property (nonatomic, copy) void(^btnActionBlock)(void);
- (void)show:(BOOL)isShow WithHint:(NSString *)hint btnAction:(void (^)(void))actionBlock;
@end

NS_ASSUME_NONNULL_END
