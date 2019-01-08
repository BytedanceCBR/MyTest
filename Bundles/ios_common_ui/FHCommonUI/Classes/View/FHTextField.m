//
//  FHTextField.m
//  Pods
//
//  Created by 张静 on 2019/1/8.
//

#import "FHTextField.h"

@implementation FHTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}
@end
