//
//  TTImagePickerBackGestureView.m
//  Article
//
//  Created by tyh on 2017/4/18.
//
//

#import "TTImagePickerBackGestureView.h"
#import "UIView+TTImagePickerViewController.h"
#import "TTImagePickerTrackManager.h"
#import "UIViewAdditions.h"

typedef enum : NSUInteger {
    BackGestureDirectionNone,
    BackGestureDirectionDown,  //下拉关闭
    BackGestureDirectionRight  //右滑关闭
} BackGestureDirection;

typedef enum : NSUInteger {
    BackGestureBegin,
    BackGestureMoving,
    BackGestureEnd
} BackGestureStatus;

@interface TTImagePickerBackGestureView()<UIGestureRecognizerDelegate>
{
    CGFloat startOfSetY;
}

@property (nonatomic,assign)BackGestureDirection backDirection;
@property (nonatomic,assign)BackGestureStatus backStatus;


@end

@implementation TTImagePickerBackGestureView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        pan.delegate = self;
      
    }
    return self;

}



- (void)panAction:(UIPanGestureRecognizer*)pan {
    if (!_collectionView) {
        return;
    }

    if (pan.state == UIGestureRecognizerStateBegan) {
        [self startWithPan:pan];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self transitionWithPan:pan];
    } else if(pan.state == UIGestureRecognizerStateEnded) {
        [self endWithPan:pan];
    } else {
        [self recoverUI];
    }
}

- (void)startWithPan:(UIPanGestureRecognizer *)pan
{
    self.backStatus = BackGestureBegin;
    startOfSetY = _collectionView.contentOffset.y;
    if (startOfSetY < 0) {
        startOfSetY = 0;
    }
}


- (void)transitionWithPan:(UIPanGestureRecognizer *)pan
{
    CGPoint point =  [pan translationInView:self];
    
    
    //确定这次滑动关闭的方向
    if (self.backStatus == BackGestureBegin) {
        
        CGFloat setY = point.y;
        if (point.y < 0) {
            setY = -point.y;
        }
        //解决左右滑动和上下滑动的冲突
        if (point.x > 0 && point.x > setY) {
            self.backDirection = BackGestureDirectionRight;
            self.backStatus = BackGestureMoving;
            
        }else if (point.y >0)
        {
            self.backDirection = BackGestureDirectionDown;
            self.backStatus = BackGestureMoving;
            
        }else{
            self.backDirection = BackGestureDirectionNone;
        }
        
        
    }
    //如果没方向，直接返回
    if (self.backDirection == BackGestureDirectionNone)
    {
        return;
    }
    // 不支持任何方向
    if (self.disableDirection == BackGestureDirectionDisabledAll) {
        return;
    }
    if (self.backDirection == BackGestureDirectionRight && self.disableDirection == BackGestureDirectionDisabledRight) {
        return;
    }
    if (self.backDirection == BackGestureDirectionDown && self.disableDirection == BackGestureDirectionDisabledDown) {
        return;
    }
    
    if (self.backDirection == BackGestureDirectionDown) {
        
        if (_collectionView.contentOffset.y <= 0) {
           
            if (point.y - startOfSetY <= 0) {
                self.top = 0;
                
            }else{
                self.top = point.y - startOfSetY;
            }
        }else{
            self.top = 0;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerBackGestureViewdidScrollScale:)]) {
            float scale = self.top/self.height;
            [self.delegate ttImagePickerBackGestureViewdidScrollScale:scale];
        }
        
    }else{
        _collectionView.scrollEnabled = NO;
        if (point.x <= 0 ) {
            self.left = 0;
        }else{
            self.left = point.x;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerBackGestureViewdidScrollScale:)]) {
            float scale = self.left/self.width;
            [self.delegate ttImagePickerBackGestureViewdidScrollScale:scale];
        }
    }
}

- (void)endWithPan:(UIPanGestureRecognizer *)pan
{
    self.backStatus = BackGestureEnd;
    _collectionView.scrollEnabled = YES;
    startOfSetY = 0;
    
    switch (self.backDirection) {
        case BackGestureDirectionRight:
            if (self.left > 0.2 * self.width) {
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerBackGestureViewdidFinnish)]) {
                    [self.delegate ttImagePickerBackGestureViewdidFinnish];
                }
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.left = self.width;
                } completion:^(BOOL finished) {
                    [self.ttImagePickerViewController dismissViewControllerAnimated:NO completion:nil];
                }];
            }else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerBackGestureViewdidCancel)]) {
                    [self.delegate ttImagePickerBackGestureViewdidCancel];
                }
                [self recoverUI];
            }
            break;
            
        case BackGestureDirectionDown:
            if (self.top > 0.2 * self.height) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerBackGestureViewdidFinnish)]) {
                    [self.delegate ttImagePickerBackGestureViewdidFinnish];
                }
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.top = self.height;
                } completion:^(BOOL finished) {
                    if (self.imagePickerMode == TTImagePickerModeVideo) {
                        TTImagePickerTrack(TTImagePickerTrackKeyVideoGestureClose, nil);
                    }
                    
                    [self.ttImagePickerViewController dismissViewControllerAnimated:NO completion:nil];
                }];
            }else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerBackGestureViewdidCancel)]) {
                    [self.delegate ttImagePickerBackGestureViewdidCancel];
                }
                [self recoverUI];
            }
            
        default:
            
            break;
    }
    self.backDirection = BackGestureDirectionNone;
    
}

- (void)recoverUI
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, 0, self.width, self.height);
    } completion:^(BOOL finished) {
    }];
    
}

@end

@implementation TTImagePickerBackGestureCollectionView


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}




@end
