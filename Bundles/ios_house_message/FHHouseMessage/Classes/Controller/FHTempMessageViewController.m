//
//  FHMessageListViewController.m
//  FHHouseMessage
//
//  Created by fupeidong on 2019/2/20.
//

#import "FHTempMessageViewController.h"

@implementation FHTempMessageViewController

- (NSString *)getPageType {
    return @"im_message_list";
}

- (CGFloat)getBottomMargin {
    return 0;
}

- (BOOL)leftActionHidden {
    return NO;
}

- (BOOL) isAlignToSafeBottom {
    return NO;
}
@end
