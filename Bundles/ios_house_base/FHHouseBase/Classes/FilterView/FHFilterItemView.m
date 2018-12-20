//
//  FHFilterItemView.m
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHFilterItemView.h"

@implementation FHFilterItemView

- (instancetype)initWithConditionSelectPanel:(UIView<ConditionSelectPanelDelegate> *)conditionSelectPanel {
    self = [super init];
    if (self) {
        self.conditionSelectPanel = conditionSelectPanel;
    }
    return self;
}

-(void)onSelected:(BOOL)isSelected {
    [_conditionSelectPanel setHidden:!isSelected];
    if (isSelected) {
        [_conditionSelectPanel viewWillDisplay];

        [_conditionSelectPanel viewDidDisplay];
    } else {
        [_conditionSelectPanel viewWillDismiss];

        [_conditionSelectPanel viewDidDismiss];
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
