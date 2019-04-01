//
//  FHDetailTracerPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/31.
//

#import "FHDetailTracerPlaceHolder.h"

@implementation FHDetailTracerPlaceHolder

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(NSUInteger)sectionWithOffset:(NSIndexPath*)indexPath {
    return indexPath.section - self.sectionOffset;
}

-(NSIndexPath*)indexPathWithOffset:(NSIndexPath*)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - self.sectionOffset];
}

@end
