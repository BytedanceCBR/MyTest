//
//  TTVLabelSegmentedControl.h
//  Article
//
//  Created by pei yun on 2017/3/23.
//
//

#import "TTVLabelTabbar.h"
#import "TTVSegmentedControl.h"

@interface TTVLabelSegmentedControl : TTVLabelTabbar <TTVSegmentedControl>

@property (nonatomic, strong) NSArray *titles;

+ (instancetype)segmentedControlWithTitles:(NSArray *)titles;

@end
