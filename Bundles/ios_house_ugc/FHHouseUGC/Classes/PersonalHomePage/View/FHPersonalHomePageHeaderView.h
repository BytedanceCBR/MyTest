//
//  FHPersonalHomePageHeaderView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import <UIKit/UIKit.h>
#import "FHPersonalHomePageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageHeaderView : UIView

@property (nonatomic, assign)   CGFloat       headerViewheight;
- (void)updateData:(FHPersonalHomePageModel *)model tracerDic:(nonnull NSDictionary *)tracerDic refreshAvatar:(BOOL)refreshAvatar;

@end

NS_ASSUME_NONNULL_END
