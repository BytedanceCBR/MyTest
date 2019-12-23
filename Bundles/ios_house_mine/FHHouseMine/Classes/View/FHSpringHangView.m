//
//  FHSpringHangView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/12/23.
//

#import "FHSpringHangView.h"
#import <Masonry.h>

@interface FHSpringHangView ()

@property(nonatomic , strong) UIButton *closeBtn;

@end

@implementation FHSpringHangView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_yunying"]];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
}

@end
