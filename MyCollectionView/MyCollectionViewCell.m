//
//  MyCollectionViewCell.m
//  MyCollectionView
//
//  Created by bytedance on 2021/2/8.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
- (void) initView
{
    self.backgroundColor = [UIColor blackColor];
    
}
@end
