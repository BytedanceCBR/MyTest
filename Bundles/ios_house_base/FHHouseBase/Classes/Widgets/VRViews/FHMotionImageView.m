//
//  FHMotionImageView.m
//  MotionAnimate
//
//  Created by 谢飞 on 2019/9/23.
//  Copyright © 2019 谢飞. All rights reserved.
//

#import "FHMotionImageView.h"
#import <CoreMotion/CoreMotion.h>
#import <Lottie/LOTAnimationView.h>
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import <BDWebImage/BDWebImageManager.h>

static CGFloat widthXRate = 0.20f;
static CGFloat heightYRate = 0.4f;
static CGFloat widthXHalf = 0.1f;
static CGFloat heightYHalf = 0.2f;

@interface FHMotionImageView()
@property(nonatomic,strong)UIImageView *contentImageView;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property (nonatomic, strong) UIView *maskBlackView;
@property(strong,nonatomic) CMMotionManager *manager;
@property(assign,nonatomic) NSInteger playCount;

@end

static CGFloat multiplier = 2;

@implementation FHMotionImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.playCount = 0;
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
    
    
    self.maskBlackView = [UIView new];
    [self.maskBlackView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    [self addSubview:self.maskBlackView];
    [self.maskBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    
    [self addSubview:self.vrLoadingView];
    [_vrLoadingView play];
    [_vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(70);
        make.width.mas_equalTo(70);
    }];
}

- (void)updateImageUrl:(NSURL *)imageUrl andPlaceHolder:(UIImage *)placeHolderImage
{
    [self.contentImageView bd_setImageWithURL:imageUrl placeholder:placeHolderImage];
}


- (void)setupBackground {
    
    CGFloat centerWidthHalf = self.frame.size.width / 2.0f;
    CGFloat centerheightHalf= self.frame.size.height / 2.0f;
    
    [_vrLoadingView play];
    
    __weak typeof(self) weakSelf = self;

    //    开始使用陀螺仪
    if (self.manager.gyroAvailable) {
        self.manager.gyroUpdateInterval = 1 / 60;
        //        使用当前进程，也就是UI的进程
        [self.manager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            
            //做一下防抖动的处理，如果手机旋转的不太大，就不执行操作
            if (fabs(gyroData.rotationRate.x) * multiplier < 0.2 && fabs(gyroData.rotationRate.y) * multiplier < 0.2) {
                return ;
            }
            
            // 让背景图片开始随着屏幕进行移动
            CGFloat imageRotationX = weakSelf.contentImageView.center.x + gyroData.rotationRate.y * multiplier;
            CGFloat imageRotationY = weakSelf.contentImageView.center.y + gyroData.rotationRate.x * multiplier;
            
            CGFloat rotationTmp = weakSelf.frame.size.width * widthXHalf +  centerWidthHalf;
            // 为了防止超出边界，进行限制
            if (imageRotationX > rotationTmp) {
                imageRotationX = rotationTmp;
            }
            
            rotationTmp = centerWidthHalf - weakSelf.frame.size.width * widthXHalf;
            if(imageRotationX < rotationTmp){
                imageRotationX = rotationTmp;
            }
            
            rotationTmp = weakSelf.frame.size.height * heightYHalf + centerheightHalf;
            if (imageRotationY >= rotationTmp) {
                imageRotationY = rotationTmp;
            }
            
            rotationTmp = centerheightHalf - weakSelf.frame.size.height * heightYHalf;
            if (imageRotationY < rotationTmp) {
                imageRotationY = rotationTmp;
            }
            
            //动画进行背景图变化
            [UIView animateWithDuration:0.3 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
             UIViewAnimationOptionCurveEaseOut animations:^{
                 weakSelf.contentImageView.center = CGPointMake(imageRotationX, imageRotationY);
             } completion:nil];
            
        }];
    }
}

-(LOTAnimationView *)vrLoadingView
{
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        _vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        _vrLoadingView.loopAnimation = NO;
        __weak typeof(self) weakSelf = self;
        _vrLoadingView.completionBlock = ^(BOOL animationFinished) {
            if (animationFinished) {
                [weakSelf.vrLoadingView playWithCompletion:^(BOOL animationFinished) {
                    [weakSelf.vrLoadingView playWithCompletion:^(BOOL animationFinished) {
                        
                    }];
                }];
            }
        };
    }
    return _vrLoadingView;
}

- (void)setCellHouseType:(FHMultiMediaCellHouseType)cellHouseType {
    _cellHouseType = cellHouseType;
    if (_cellHouseType == FHMultiMediaCellHouseSecond)  {
        [self.vrLoadingView  mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(60);
            make.top.mas_equalTo(104);
            make.centerX.mas_equalTo(self);
        }];
    }
}

- (CMMotionManager *)manager {
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    return _manager;
}

- (void)checkLoadingState
{
//    if (_vrLoadingView) {
//        [_vrLoadingView play];
//    }
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
