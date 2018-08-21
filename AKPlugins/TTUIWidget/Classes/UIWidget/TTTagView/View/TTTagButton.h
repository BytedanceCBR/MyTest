//
//  TTTagButton.h
//  Article
//
//  Created by fengyadong on 16/5/26.
//
//

#import "SSThemed.h"
#import "TTTagItem.h"

@interface TTTagButton : SSThemedButton

- (void)updateWithTagItem:(TTTagItem *)tagItem;

@end
