//
//  FRSpreaderButton.m
//  Article
//
//  Created by lipeilun on 2017/6/1.
//
//

#import "FRSpreaderButton.h"

@implementation FRSpreaderButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect originBounds = self.bounds;
    CGRect newBounds = CGRectMake(-self.spreadEdgeInsets.left, -self.spreadEdgeInsets.top, originBounds.size.width + self.spreadEdgeInsets.left + self.spreadEdgeInsets.right, originBounds.size.height + self.spreadEdgeInsets.bottom + self.spreadEdgeInsets.top);
    return CGRectContainsPoint(newBounds, point);
}

@end
