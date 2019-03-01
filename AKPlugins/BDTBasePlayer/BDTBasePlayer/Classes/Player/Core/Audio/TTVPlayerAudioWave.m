//
//  TTVPlayerAudioWave.m
//  Article
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerAudioWave.h"
#import "TTVAudioWaveView.h"
#import "TTVPlayerAudioController.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIButton+TTAdditions.h"

@interface TTVPlayerAudioWave ()
@property (nonatomic, strong) TTVAudioWaveView *audioWave;
@end

@implementation TTVPlayerAudioWave

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _audioWave = [[TTVAudioWaveView alloc] initWithFrame:frame];
        _audioWave.userInteractionEnabled = NO;
        _audioWave.alpha = 0.9;
        [_audioWave finish];
        self.userInteractionEnabled = NO;
        [self addSubview:_audioWave];
    }
    return self;
}

- (void)layoutSubviews
{
    self.audioWave.right = self.width - 6;
    self.audioWave.bottom = self.height - 4;
    [super layoutSubviews];
}

- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    self.hidden = !muted;
    if (muted) {
        [self.audioWave wave];
    } else {
        [self.audioWave finish];
    }
}
@end
