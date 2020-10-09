//
//  TTMultiDiggManager+FHUGC.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/9/25.
//

#import "TTMultiDiggManager+FHUGC.h"
#import "UIButton+FHUGCMultiDigg.h"
@implementation TTMultiDiggManager (FHUGC)

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.randomRadiusPercent = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(longPressBegin) name:TTMultiDiggAnimationLongPressBeginNotification object:nil];
    }
    return self;
}

-(void)longPressBegin {
    UIButton *button = [self valueForKey:@"button"];
    button.longPressNeedSend = YES;
}

@end
