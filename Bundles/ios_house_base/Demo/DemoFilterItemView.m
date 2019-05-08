//
//  DemoFilterItemView.m
//  Demo
//
//  Created by leo on 2018/11/16.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "DemoFilterItemView.h"
#import <FHHouseBase/FHHouseBase.h>
#import <Masonry/Masonry.h>

@implementation DemoFilterItemView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.label = [[UILabel alloc] init];
    [self addSubview:_label];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"未选中";
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)onSelected:(BOOL)isSelected {
    [super onSelected:isSelected];
    if (isSelected) {
        _label.text = @"选中";
    } else {
        _label.text = @"未选中";
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
