//
//  UIView+TTVViewKey.h
//  Article
//
//  Created by yangshaobo on 2018/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView(TTVViewKey)

/**
 * 给需要加到播放器上的View添加这个Key后，可以在其它模块通过每个播放器上的公共View(topView, bottomView, layoutView){不包含四个角的SortView}查找到相应的View
 */
@property (nonatomic, strong) NSString *ttvPlayerLayoutViewKey;

@end

NS_ASSUME_NONNULL_END
