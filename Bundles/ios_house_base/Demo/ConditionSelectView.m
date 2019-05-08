//
//  ConditionSelectView.m
//  Demo
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "ConditionSelectView.h"
#import <Masonry/Masonry.h>

@interface ConditionSelectView ()
{
    NSString* _name;
}
@end

@implementation ConditionSelectView

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    UILabel* label = [[UILabel alloc] init];
    [self addSubview:label];
    label.text = _name;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)viewWillDisplay {
    NSLog(@"viewWillDisplay %@", _name);
}

-(void)viewDidDisplay {
    NSLog(@"viewDidDisplay %@", _name);
}

-(void)viewWillDismiss {
    NSLog(@"viewWillDismiss %@", _name);
}

-(void)viewDidDismiss {
    NSLog(@"viewDidDismiss %@", _name);
}

@end
