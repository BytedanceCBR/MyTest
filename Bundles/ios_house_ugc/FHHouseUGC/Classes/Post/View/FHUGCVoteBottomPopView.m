//
//  FHUGCVoteBottomPopView.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/15.
//

#import "FHUGCVoteBottomPopView.h"

@interface FHUGCVoteBottomPopView()
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, weak) UIView *contentView;
@end

@implementation FHUGCVoteBottomPopView

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
        self.alpha = 0;
    }
    return self;
}

- (void)showOnView:(UIView *)onView withView: (UIView *)view{
    
    if(self.superview == onView) {
        [onView bringSubviewToFront:self];
    }
    else {
        [onView addSubview:self];
    }
    
    self.contentView = view;
    
    __block CGRect frame = view.frame;
    frame.origin.y = self.bounds.size.height;
    view.frame = frame;
    [self addSubview:view];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
        frame.origin.y = self.bounds.size.height - view.frame.size.height;
        view.frame = frame;
    }];
}

- (void)hide {

    CGRect frame = self.contentView.frame;
    frame.origin.y = self.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = frame;
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview removeFromSuperview];
        }];
        [self removeFromSuperview];
    }];
}

@end
