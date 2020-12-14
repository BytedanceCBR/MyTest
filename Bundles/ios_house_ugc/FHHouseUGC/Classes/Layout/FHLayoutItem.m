//
//  FHLayoutItem.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHLayoutItem.h"
#import "UIViewAdditions.h"

@implementation FHLayoutItem

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (FHLayoutItem *)layoutWithTop:(CGFloat)top left:(CGFloat)left width:(CGFloat)width height:(CGFloat)height {
    FHLayoutItem *item = [[FHLayoutItem alloc] init];
    item.top = top;
    item.left = left;
    item.width = width;
    item.height = height;
    return item;
}

+ (void)updateView:(UIView *)view withLayout:(FHLayoutItem *)layout {
    view.top = layout.top;
    view.left = layout.left;
    view.width = layout.width;
    view.height = layout.height;
}

- (CGFloat)right {
    return self.left + self.width;
}

- (CGFloat)bottom {
    return self.top + self.height;
}


@end
