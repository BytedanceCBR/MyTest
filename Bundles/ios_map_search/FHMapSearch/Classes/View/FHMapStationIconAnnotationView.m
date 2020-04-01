//
//  FHMapStationIconAnnotationView.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/11/13.
//

#import "FHMapStationIconAnnotationView.h"
#import <FHHouseBase/FHCommonDefines.h>

@implementation FHMapStationIconAnnotationView

-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = SYS_IMG(@"mapsearch_station_icon_orange");
        
        CGRect frame = self.frame;
        frame.size = CGSizeMake(22,22);
        self.frame = frame;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
