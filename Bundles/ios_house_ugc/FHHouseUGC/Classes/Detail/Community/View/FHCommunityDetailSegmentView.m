//
//  FHCommunityDetailSegmentView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/11/11.
//

#import "FHCommunityDetailSegmentView.h"

@implementation FHCommunityDetailSegmentView

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
