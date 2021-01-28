//
//  FHMineMyItemView.m
//  FHHouseMine
//
//  Created by bytedance on 2021/1/27.
//

#import "FHMineMyItemView.h"

@implementation FHMineMyItemView


- (instancetype)initWithImageView:(UIImageView *)imgView andLabel:(UILabel *) label
{
    self = [super init];
    if (self) {
        self.imgView = imgView;
        self.label = label;
    }
    [self addSubview:imgView];
    [self addSubview:label];
    return self;
}
@end
