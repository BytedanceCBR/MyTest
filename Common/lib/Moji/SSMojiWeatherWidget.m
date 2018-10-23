//
//  SSMojiWeatherWidget.m
//  Article
//
//  Created by Kimimaro on 13-5-20.
//
//

#import "SSMojiWeatherWidget.h"
#import "SSMojiWeatherView.h"

@interface SSMojiWeatherWidget ()
@property (nonatomic, retain) SSMojiWeatherView *mojiView;
@end

@implementation SSMojiWeatherWidget

- (void)dealloc
{
    self.mojiView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mojiView = [[[SSMojiWeatherView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:_mojiView];
    }
    return self;
}

@end
