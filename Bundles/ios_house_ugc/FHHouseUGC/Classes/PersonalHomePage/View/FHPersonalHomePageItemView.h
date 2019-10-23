//
//  FHPersonalHomePageItemView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageItemView : UIView

@property(nonatomic, copy) void(^itemClickBlock)(void);

- (void)updateWithTopContent:(NSString *)topContent bottomContent:(NSString *)bottomContent;

@end

NS_ASSUME_NONNULL_END
