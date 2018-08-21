//
//  UIView+UGCAdditions.m
//  Article
//
//  Created by SongChai on 2017/4/23.
//
//

#import "UIView+UGCAdditions.h"
#import "UIView+TTCSSUIKit.h"

@implementation UIView (UGCAdditions)

- (id) ugc_addSubviewWithClass:(Class)viewClass {
    return [self ugc_addSubviewWithClass:viewClass frame:CGRectZero];
}

- (id) ugc_addSubviewWithClass:(Class)viewClass frame:(CGRect)frame {
    
    if (![viewClass isSubclassOfClass:[UIView class]]) return nil;
    
    UIView * subView = [[viewClass alloc] initWithFrame:frame];
    
    [self addSubview:subView];
    
    return subView;
}

- (id)ugc_addSubviewWithClass:(Class)viewClass themePath:(NSString *)themePath {
    id result = [self ugc_addSubviewWithClass:viewClass];
    [result tt_applyTheme:themePath];
    return result;
}
@end
