//
//  WDListAnswerCellBottomView.m
//  AKWDPlugin
//
//  Created by 张元科 on 2019/6/14.
//

#import "WDListAnswerCellBottomView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"

@interface WDListAnswerCellBottomView ()

@end

@implementation WDListAnswerCellBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor redColor];
}

- (void)setupConstraints {
 
}

@end
