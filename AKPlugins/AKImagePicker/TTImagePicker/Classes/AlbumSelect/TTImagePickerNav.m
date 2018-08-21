//
//  TTImagePickerNav.m
//  Article
//
//  Created by tyh on 2017/4/19.
//
//

#import "TTImagePickerNav.h"
#import "SSThemed.h"
#import "TTImageAlbumSelectView.h"
#import "TTAlbumModel.h"
#import "TTImagePickerTrackManager.h"
#import "UIViewAdditions.h"
#import "UIButton+TTAdditions.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"

@interface TTImagePickerNav()<TTImageAlbumSelectViewDelegate>
{
    UILabel *numLabel;
    UILabel *completeLabel;
    int seletedCount;
    UIView *bottomLine;
}

@property (nonatomic,strong) UILabel *ablumName;
@property (nonatomic,strong) UIImageView *arrow;
@property (nonatomic,strong) TTAlbumModel *model;
@property (nonatomic,strong) UIButton *tipBtn;
@property (nonatomic,assign) BOOL isShowAlbum;

@property (nonatomic,strong) TTImageAlbumSelectView *albumSelectView;

@property (nonatomic,assign) BOOL isTrackChanged;  //跟踪是否改变了相册，埋点用



@end

@implementation TTImagePickerNav

- (instancetype)init;
{

    self = [super initWithFrame:CGRectMake(0, 20, KScreenWidth, 50)];
    if (self) {
        seletedCount = 0;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedCountDidChange:) name:TTImagePickerSelctedCountDidChange object:nil];
    }
    return self;
}


- (void)setImagePickerMode:(TTImagePickerMode)imagePickerMode
{
    _imagePickerMode = imagePickerMode;
    [self _initViews];

}


- (void)_initViews
{
    if (self.imagePickerMode == TTImagePickerModeVideo) {
        self.frame = CGRectMake(0, 0, KScreenWidth, 50);
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.top = TTSafeAreaInsetsTop;
    }
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    //默认标题
    self.ablumName = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 120, 16)];
    self.ablumName.font = [UIFont boldSystemFontOfSize:16];
    self.ablumName.text = @"相机胶卷";
    self.ablumName.textAlignment = NSTextAlignmentCenter;
    self.ablumName.centerX = self.centerX;
    self.ablumName.textColor = [UIColor tt_themedColorForKey:kColorText9];

    [self addSubview:self.ablumName];
    
    self.tipBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.ablumName.bottom + 4, 62, 10)];
    [self.tipBtn setTitle:@"轻触更改相册" forState:UIControlStateNormal];
    self.tipBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    self.tipBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-40, -5, -5, -5);
    [self.tipBtn setTitleColor:[UIColor tt_themedColorForKey:kColorText9] forState:0];

    WeakSelf;
    [self.tipBtn addTarget:self withActionBlock:^{
        StrongSelf;
        
        [self navBarTapAction];
        
    } forControlEvent:UIControlEventTouchUpInside];
    [self addSubview:self.tipBtn];
    
    self.arrow = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.ablumName.bottom + 4, 10, 10)];
    
    self.arrow.image = [[UIImage imageNamed:@"ImgPic_drop_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrow.tintColor = [UIColor tt_themedColorForKey:kColorText9];
    [self addSubview:self.arrow];
    
    self.tipBtn.left = (self.width - (self.tipBtn.width + self.arrow.width + 4))/2.0;
    self.arrow.left = self.tipBtn.right + 4;
    
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.width = 24;
    closeBtn.height = 24;
    closeBtn.left = 10;
    closeBtn.centerY = self.height/2;
    closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    
    [closeBtn setImage:[[UIImage imageNamed:@"ImgPic_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:0];
    closeBtn.tintColor = [UIColor blackColor];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        closeBtn.tintColor = [UIColor tt_themedColorForKey:kColorText9];
    }
    
    
    [closeBtn addTarget:self withActionBlock:^{
        StrongSelf;
        
        if (self.isShowAlbum) {
            [self navBarTapAction];
        }else{
            if ([self.delegate respondsToSelector:@selector(ttImagePickerNavDidClose)]) {
                [self.delegate ttImagePickerNavDidClose];
            }
        }
    } forControlEvent:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    
    if (self.imagePickerMode != TTImagePickerModeVideo) {
        completeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 32 - 15, 0, 35, self.height)];
        completeLabel.textAlignment = NSTextAlignmentCenter;
        completeLabel.text = @"完成";
        completeLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
        completeLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:completeLabel];
        
        numLabel = [[UILabel alloc]initWithFrame:CGRectMake(completeLabel.left - 20 - 5, 12.5, 20, 20)];
        numLabel.centerY = completeLabel.centerY;
        numLabel.text = @"0";
        numLabel.hidden = YES;
        numLabel.layer.cornerRadius = 10;
        numLabel.layer.masksToBounds = YES;
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.font = [UIFont systemFontOfSize:15];
        
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight) {
            numLabel.layer.borderColor = [UIColor whiteColor].CGColor;
            numLabel.layer.borderWidth = 1;
        }
        
 
        numLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground8];
        numLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
        [self addSubview:numLabel];
        
        UIView *completeTouch = [[UIView alloc]initWithFrame:CGRectMake(self.width - 84, 0, 84, self.height)];
        [self addSubview:completeTouch];
        
        UITapGestureRecognizer *completetap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(completeTapAction)];
        [completeTouch addGestureRecognizer:completetap];
    }
    
    self.albumSelectView = [[TTImageAlbumSelectView alloc]initWithFrame:CGRectMake(0, self.bottom, KScreenWidth, KScreenHeight - self.bottom)];
    self.albumSelectView.delegate = self;
    self.albumSelectView.hidden = YES;

    bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,self.bottom, self.width, 0.5)];
    bottomLine.backgroundColor = [UIColor tt_themedColorForKey:kColorLine10];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(navBarTapAction)];
    [self.albumSelectView.maskView addGestureRecognizer:tap];
    
    self.layer.mask = [self bezierPathLayer:self.bounds];
}

- (void)completeTapAction
{
    if (seletedCount <= 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerNavDidFinish)]) {
        [self.delegate ttImagePickerNavDidFinish];
    }
}



- (void)navBarTapAction
{
    if (!_enableSelcect) {
        return;
    }
    
    
    self.isShowAlbum = !self.isShowAlbum;
    if (self.isShowAlbum) {
        [self.tipBtn setTitle:@"轻触这里收起" forState:UIControlStateNormal];
        self.arrow.transform = CGAffineTransformMakeRotation(M_PI);

        
        [self.albumSelectView showAlbum];

        if (self.imagePickerMode == TTImagePickerModePhoto) {
            TTImagePickerTrack(TTImagePickerTrackKeyClickAlbumList, nil);
        }else if (self.imagePickerMode == TTImagePickerModeVideo){
            TTImagePickerTrack(TTImagePickerTrackKeyVideoClickAlbumList, nil);
        }else{
            TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoClickAlbumList, nil);
        }
    }
    else {
        
        if (!self.isTrackChanged) {
            if (self.imagePickerMode == TTImagePickerModePhoto) {
                TTImagePickerTrack(TTImagePickerTrackKeyAlbumUnchanged, nil);
            }else if (self.imagePickerMode == TTImagePickerModeVideo){
                TTImagePickerTrack(TTImagePickerTrackKeyVideoAlbumUnchanged, nil);
            }else{
                TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoAlbumUnchanged, nil);
            }
        }else{
            self.isTrackChanged = NO;
        }
        [self.tipBtn setTitle:@"轻触更改相册" forState:UIControlStateNormal];
        self.arrow.transform = CGAffineTransformIdentity;

        
        [self.albumSelectView hideAlbum];
    }

}


- (void)setEnableSelcect:(BOOL)enableSelcect
{
    _enableSelcect = enableSelcect;
    
    if (_enableSelcect) {
        self.ablumName.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [self.tipBtn setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:0];
        self.arrow.tintColor = [UIColor tt_themedColorForKey:kColorText1];

    }else{
        self.ablumName.textColor = [UIColor tt_themedColorForKey:kColorText9];
        [self.tipBtn setTitleColor:[UIColor tt_themedColorForKey:kColorText9] forState:0];
        self.arrow.tintColor = [UIColor tt_themedColorForKey:kColorText9];

    }
}


- (void)didCompletedTheRequestWithAlbums:(NSArray <TTAlbumModel *> *)models
{
    self.albumSelectView.models = models;
}


- (CAShapeLayer *)bezierPathLayer:(CGRect)bounds
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

#pragma mark - TTImageAlbumSelectViewDelegate
- (void)ttImageAlbumSelectViewDidSelect:(TTAlbumModel *)model
{
    if (self.imagePickerMode == TTImagePickerModePhoto) {
        TTImagePickerTrack(TTImagePickerTrackKeyAlbumChanged, nil);
    }else if (self.imagePickerMode == TTImagePickerModeVideo){
        TTImagePickerTrack(TTImagePickerTrackKeyVideoAlbumChanged, nil);
    }else{
        TTImagePickerTrack(TTImagePickerTrackKeyPhotoVideoAlbumChanged, nil);
    }
    
    self.ablumName.text = model.name;
    self.isTrackChanged = YES;
    [self navBarTapAction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePickerNavDidSelect:)]) {
        [self.delegate ttImagePickerNavDidSelect:model];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
  
    [self.superview addSubview:bottomLine];

    [self.superview addSubview:self.albumSelectView];

}


#pragma mark - Notify

- (void)selectedCountDidChange:(NSNotification *)notify
{
    if ([notify.object intValue] <= 0) {
        completeLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
        numLabel.hidden = YES;
    }else{
        numLabel.hidden = NO;
        numLabel.text = [notify.object stringValue];
        completeLabel.textColor = [UIColor tt_themedColorForKey:kColorText6];
        //小动画
        numLabel.transform = CGAffineTransformMakeScale(0.2, 0.2);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            numLabel.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    }
    seletedCount = [notify.object intValue];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
