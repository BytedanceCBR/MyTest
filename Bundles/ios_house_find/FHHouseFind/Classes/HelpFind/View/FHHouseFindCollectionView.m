//
//  FHHouseFindCollectionView.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/3.
//

#import "FHHouseFindCollectionView.h"

@implementation FHHouseFindCollectionView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (![touch.view isKindOfClass:[UITextField class]] && ![touch.view isKindOfClass:[UILabel class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endEditing:NO];
        });

    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
