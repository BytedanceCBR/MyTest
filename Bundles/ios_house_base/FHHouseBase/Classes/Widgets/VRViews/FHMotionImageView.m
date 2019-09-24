//
//  FHMotionImageView.m
//  MotionAnimate
//
//  Created by 谢飞 on 2019/9/23.
//  Copyright © 2019 谢飞. All rights reserved.
//

#import "FHMotionImageView.h"
#import <CoreMotion/CoreMotion.h>

static CGFloat widthXRate = 0.25f;
static CGFloat heightYRate = 1.0f;
static CGFloat widthXHalf = 0.125f;
static CGFloat heightYHalf = 0.5f;

@interface FHMotionImageView()
@property(nonatomic,strong)UIImageView *contentImageView;
@property(nonatomic,strong)UIImageView *loadingImageView;
@property(strong,nonatomic) CMMotionManager *manager;

@end

static CGFloat multiplier = 4;

@implementation FHMotionImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
 

        [self setupUI];
        [self setupBackground];
        self.clipsToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

#pragma mark 前后台切换停止
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self.manager stopGyroUpdates];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self setupBackground];
}


- (void)setupUI {
    self.contentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sky"]];
    [self.contentImageView setBackgroundColor:[UIColor yellowColor]];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    //图要让它完全超出父视图
    self.contentImageView.frame = CGRectMake(-self.frame.size.width * widthXHalf, -self.frame.size.height * heightYHalf, self.frame.size.width * (1 + widthXRate), self.frame.size.height * (1 + heightYRate));
    self.contentImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    [self insertSubview:self.contentImageView atIndex:1];
}


- (void)setupBackground {
    
    CGFloat centerWidthHalf = self.frame.size.width / 2.0f;
    CGFloat centerheightHalf= self.frame.size.height / 2.0f;
    
    //    开始使用陀螺仪
    if (self.manager.gyroAvailable) {
        self.manager.gyroUpdateInterval = 1 / 60;
        //        使用当前进程，也就是UI的进程
        [self.manager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            
            //做一下防抖动的处理，如果手机旋转的不太大，就不执行操作
            if (fabs(gyroData.rotationRate.x) * multiplier < 0.2 && fabs(gyroData.rotationRate.y) * multiplier < 0.2) {
                return ;
            }
            
            NSLog(@"x=%.2f,y=%.2f,z=%.2f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z);
            
            // 让背景图片开始随着屏幕进行移动
            CGFloat imageRotationX = self.contentImageView.center.x + gyroData.rotationRate.y * multiplier;
            CGFloat imageRotationY = self.contentImageView.center.y + gyroData.rotationRate.x * multiplier;
            
            // 为了防止超出边界，进行限制
            if (imageRotationX > self.frame.size.width * widthXHalf +  centerWidthHalf) {
                imageRotationX = self.frame.size.width * widthXHalf +  centerWidthHalf;
            }
            
            if(imageRotationX < (centerWidthHalf - self.frame.size.width * widthXHalf)){
                imageRotationX = (centerWidthHalf - self.frame.size.width * widthXHalf);
            }
            
            if (imageRotationY >= (self.frame.size.height * heightYHalf + centerheightHalf)) {
                imageRotationY = (self.frame.size.height * heightYHalf + centerheightHalf);
            }
            
            if (imageRotationY < (centerheightHalf - self.frame.size.height * heightYHalf)) {
                imageRotationY = (centerheightHalf - self.frame.size.height * heightYHalf);
            }
            
            //动画进行背景图变化
            [UIView animateWithDuration:0.3 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
             UIViewAnimationOptionCurveEaseOut animations:^{
                 self.contentImageView.center = CGPointMake(imageRotationX, imageRotationY);
             } completion:nil];
            
        }];
    }
}

- (CMMotionManager *)manager {
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    return _manager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
