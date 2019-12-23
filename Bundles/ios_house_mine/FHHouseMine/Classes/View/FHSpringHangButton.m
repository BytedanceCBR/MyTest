//
//  FHSpringHangButton.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/12/23.
//

#import "FHSpringHangButton.h"
#import <Masonry.h>

@interface FHSpringHangButton ()

@property(nonatomic , strong) UIButton *closeBtn;

@end

@implementation FHSpringHangButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_yunying_close"]];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
}

@end
