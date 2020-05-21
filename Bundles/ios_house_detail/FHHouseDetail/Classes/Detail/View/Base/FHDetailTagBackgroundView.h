//
//  FHDetailTagBackgroundView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailTagBackgroundView : UIView

- (void)removeAllTag;
- (void)refreshWithTags:(NSArray *)tags withNum:(NSUInteger)num withmaxLen:(CGFloat)maxLen;
@end

NS_ASSUME_NONNULL_END
