//
//  FHHouseBaseTableView.m
//  FHCommonUI
//
//  Created by 张静 on 2019/4/18.
//

#import "FHHouseBaseTableView.h"

@implementation FHHouseBaseTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.handleTouch) {
        self.handleTouch();
    }
}

@end
