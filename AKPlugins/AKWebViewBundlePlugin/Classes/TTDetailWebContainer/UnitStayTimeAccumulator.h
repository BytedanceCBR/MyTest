//
//  UnitStayTimeAccumulator.h
//  Article
//
//  Created by Huaqing Luo on 16/3/15.
//
//

#import <Foundation/Foundation.h>

// This class assumes that the processed view page is of full screen
@interface UnitStayTimeAccumulator : NSObject

@property (nonatomic, assign) CGFloat currentOffset;
@property (nonatomic, assign) CGFloat maxOffset;

@property (nonatomic, strong, readonly) NSArray * totalStayTimes;
@property (nonatomic, strong, readonly) NSArray * maxStayTimes;
@property (nonatomic, strong, readonly) NSArray * recordTimes;

- (id)initWithUnitHeight:(CGFloat)unitHeight;

// Calling stopAccumulating causes the Accumulator to be reset (remove all elements of stayTimes), while calling suspendAccumulating does not.
- (void)suspendAccumulating;
- (void)stopAccumulating;

@end
