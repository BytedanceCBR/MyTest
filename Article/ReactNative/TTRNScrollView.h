//
//  TTRNScrollView.h
//  Article
//
//  Created by yin on 2017/7/27.
//
//

#import <React/RCTScrollView.h>

@interface TTRNScrollView : RCTScrollView

@property (nonatomic, strong) NSArray* scrollList;

/// @name Managing the Display of Content

/**
 *  Sets the contentOffset of the ScrollView and animates the transition. The
 *  animation takes 0.25 seconds.
 *
 * @param contentOffset  A point (expressed in points) that is offset from the
 *                       content view’s origin.
 * @param timingFunction A timing function that defines the pacing of the
 *                       animation.
 */
- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction;

/**
 *  Sets the contentOffset of the ScrollView and animates the transition.
 *
 * @param contentOffset  A point (expressed in points) that is offset from the
 *                       content view’s origin.
 * @param timingFunction A timing function that defines the pacing of the
 *                       animation.
 * @param duration       Duration of the animation in seconds.
 */
- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration;


@end
