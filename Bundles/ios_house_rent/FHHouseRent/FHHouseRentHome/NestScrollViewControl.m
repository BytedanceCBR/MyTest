//
//  NestScrollViewControl.m
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "NestScrollViewControl.h"

@interface NestScrollViewControl ()

@end

@implementation NestScrollViewControl

+ (instancetype)instanceWithMajorScrollView:(UIScrollView*)majorScrollView
                         withNestScrollView:(UIScrollView*)nestScrollView
{
    NestScrollViewControl* result = [[NestScrollViewControl alloc] initWithMajorScrollView:majorScrollView
                                                                        withNestScrollView:nestScrollView];
    return result;
}

- (instancetype)initWithMajorScrollView:(UIScrollView*)majorScrollView
                     withNestScrollView:(UIScrollView*)nestScrollView
{
    self = [super init];
    if (self) {
        self.majorScrollView = majorScrollView;
        self.nestScrollView = nestScrollView;
        _majorScrollView.delegate = self;
        _nestScrollView.delegate = self;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_majorScrollView.contentOffset.y < _thresholdYOffset) {
        CGFloat offset = _nestScrollView.contentOffset.y;
        _nestScrollView.contentOffset = CGPointMake(0, 0);
        CGPoint majorScrollViewOffset = _majorScrollView.contentOffset;
        _majorScrollView.contentOffset = CGPointMake(majorScrollViewOffset.x, majorScrollViewOffset .y + offset);
    } else {


    }
}

@end
