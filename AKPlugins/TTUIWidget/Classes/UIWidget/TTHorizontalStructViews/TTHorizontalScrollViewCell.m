//
//  TTHorizontalScrollViewCell.m
//  Article
//
//  Created by Zhang Leonardo on 16-6-25.
//
//

#import "TTHorizontalScrollViewCell.h"
#import <TTBaseLib/TTBaseMacro.h>
#define kDefaultCellIdentifierKey @"kDefaultCellIdentifierKey"

@implementation TTHorizontalScrollViewCell

- (void)dealloc
{
    self.reuseIdentifier = nil;
    self.delegate = nil;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _isCurrentDisplayCell = NO;
        _index = 0;
        if (isEmptyString(reuseIdentifier)) {
            self.reuseIdentifier = kDefaultCellIdentifierKey;
        }
        else {
            self.reuseIdentifier = reuseIdentifier;
        }
    }
    return self;
}

- (void)isCurrentDisplayWhenEndDecelerating:(BOOL)currentDisplay {
    self.isCurrentDisplayCell = currentDisplay;
}

- (void)parentViewWillBeginDragging {}


- (UIView *)contentView
{
    return nil;
}


@end
