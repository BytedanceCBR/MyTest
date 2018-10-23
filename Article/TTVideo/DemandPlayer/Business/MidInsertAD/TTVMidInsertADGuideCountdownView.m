//
//  TTVMidInsertADGuideCountdownView.m
//  Article
//
//  Created by pei yun on 2017/10/29.
//

#import "TTVMidInsertADGuideCountdownView.h"
#import <TTThemed/SSThemed.h>
#import "NSTimer+NoRetain.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import "NSTimer+Additions.h"

@interface TTVMidInsertADGuideCountdownView ()

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) TTVMidInsertADModel *adModel;
@property (nonatomic, assign) int durationTime;

@end

@implementation TTVMidInsertADGuideCountdownView

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVMidInsertADModel *)adModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adModel = adModel;
        self.durationTime = roundf(adModel.midInsertADInfoModel.guideTime.intValue / 1000.f);
        
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:self.bounds];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground5] colorWithAlphaComponent:.5f];
        _titleLabel.layer.cornerRadius = self.bounds.size.height / 2;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self configureTitleLabel];
        [self addSubview:_titleLabel];
        
        @weakify(self);
        self.timer = [NSTimer tt_timerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
            @strongify(self);
            self.durationTime--;
            [self configureTitleLabel];
            if (self.durationTime == 0) {
                [self.timer invalidate];
                self.timer = nil;
                if (self.guideCountdownCompleted) {
                    self.guideCountdownCompleted();
                }
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.titleLabel.layer.cornerRadius = self.bounds.size.height / 2;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.titleLabel.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground5] colorWithAlphaComponent:.5f];
}

- (void)configureTitleLabel
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    if (!isEmptyString(self.adModel.midInsertADInfoModel.guideWords)) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", self.adModel.midInsertADInfoModel.guideWords] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]]}]];
    }
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ds", self.durationTime] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]]}]];
    self.titleLabel.attributedText = attrStr;
}

#pragma mark - TTVADGuideCountdownViewProtocol

- (void)performVerticalTranslation:(BOOL)toolBarHidden needShiftDown:(BOOL)needShiftDown animated:(BOOL)animated
{
    CGFloat offset = needShiftDown ? 20 : 0;
    CGFloat top = toolBarHidden ? (10.0f + offset) : (35.5f + offset);
    if (animated) {
        [UIView animateWithDuration:0.25f customTimingFunction:CustomTimingFunctionCubicOut animation:^{
            self.top = top;
        }];
    } else {
        self.top = top;
    }
}

- (void)pauseTimer
{
    [self.timer tt_pause];
}

- (void)resumeTimer
{
    [self.timer tt_resume];
}

- (void)terminateTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
