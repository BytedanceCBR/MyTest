//
//  TTPersonalHomeSegmentView.m
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "TTPersonalHomeSegmentView.h"
#import "TTIndicatorView.h"
#import <NetworkUtilities.h>

@implementation TTPersonalHomeSegmentView

- (void)titleClick:(UITapGestureRecognizer *)tap
{
     SSThemedLabel *label = (SSThemedLabel *)tap.view;
    NSString *title = self.titles[label.tag];
    if(![title isEqualToString:@"频道"]) {
        [super titleClick:tap];
    } else {
        if([self.delegate respondsToSelector:@selector(segmentView:didSelectedItemAtIndex:toIndex:)]) {
            [self.delegate segmentView:self didSelectedItemAtIndex:0 toIndex:label.tag];
        }

    }
}

@end
