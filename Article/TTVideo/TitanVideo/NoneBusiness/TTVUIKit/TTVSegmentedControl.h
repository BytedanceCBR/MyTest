//
//  TTVSegmentedControl.h
//  Article
//
//  Created by pei yun on 2017/3/22.
//
//

#ifndef TTVSegmentedControl_h
#define TTVSegmentedControl_h

@protocol TTVSegmentedControlDelegate <NSObject>

@optional
- (void)segmentedControllDidDragWithNormalizedOffset:(CGFloat)offset;

- (void)segmentedControllDidBeginSnapingToIndex:(NSUInteger)index withDuration:(NSTimeInterval)duration;

@end

@protocol TTVSegmentedControl <NSObject>

@property (nonatomic, weak) id <TTVSegmentedControlDelegate> segmentedControlDelegate;
@optional

- (void)moveToNormalizedOffset:(CGFloat)offset;

- (void)moveToIndex:(NSUInteger)index;

@end

#endif /* TTVSegmentedControl_h */
