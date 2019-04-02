//
//  FHDetailTracerPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/31.
//

#import "FHDetailTracerPlaceHolder.h"
#import "FHUserTracker.h"
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

-(void)traceElementShow:(NSDictionary*)params {
    NSMutableDictionary* theParams = [params mutableCopy];
    theParams[@"page_type"] = @"city_market";
    theParams[@"rank"] = @"be_null";
    theParams[@"origin_from"] = @"city_market";
    theParams[@"origin_search_id"] = _tracer[@"origin_search_id"] ? : @"be_null";
    [FHUserTracker writeEvent:@"element_show" params:theParams];
}

@end
