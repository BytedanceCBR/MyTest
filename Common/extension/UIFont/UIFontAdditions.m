//
//  UIFontAdditions.m
//  UIExt
//
//  Created by David Fox on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIFontAdditions.h"


@implementation UIFont (SSUIFontAdditions)
- (CGFloat)LineHeight
{
    return (self.ascender - self.descender) + 1;
}
@end
