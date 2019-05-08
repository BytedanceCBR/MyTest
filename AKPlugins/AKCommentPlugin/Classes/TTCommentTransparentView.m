//
//  TTCommentTransparentView.m
//  Article
//
//  Created by zhaoqin on 23/02/2017.
//
//

#import "TTCommentTransparentView.h"

@implementation TTCommentTransparentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction)];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction)];
        [self addGestureRecognizer: tapGesture];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)panGestureAction {
    if (self.touchComplete) {
        self.touchComplete();
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    返回nil表明不响应点击事件
//    if (self.isResponseTouchEvent) {
//        return self;
//    }
//    if (self.touchComplete) {
//        self.touchComplete();
//    }
//    return nil;
//    if (self.touchComplete) {
//        self.touchComplete();
//    }
//    return self;
//}


@end
