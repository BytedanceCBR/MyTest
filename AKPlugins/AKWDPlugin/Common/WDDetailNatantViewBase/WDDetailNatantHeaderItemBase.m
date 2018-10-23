//
//  WDDetailNatantHeaderItemBase.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "WDDetailNatantHeaderItemBase.h"
#import "SSThemed.h"
#import "WDDefines.h"

@implementation WDDetailNatantHeaderItemBase


- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
    }
    return self;
}

- (void)refreshWithWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)refreshUI
{
    // subview implements
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)sendShowTrackIfNeededForGroup:(NSString *)groupID withLabel:(NSString *)label
{
    if (!_hasShown) {
        if (!isEmptyString(groupID)) {
            [TTTracker category:@"umeng"
                          event:@"detail"
                          label:label
                           dict:@{@"value":groupID}];
            self.hasShown = YES;
        }
    }
}

@end
