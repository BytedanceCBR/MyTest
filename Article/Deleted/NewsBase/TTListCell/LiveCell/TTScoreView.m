//
//  TTScoreView.m
//  Article
//
//  Created by 杨心雨 on 16/8/18.
//
//

#import "TTScoreView.h"
#import "TTArticleCellHelper.h"

@interface TTScoreView ()

@property (nonatomic, strong) SSThemedLabel *leftScore;
@property (nonatomic, strong) SSThemedLabel *rightScore;
@property (nonatomic, strong) SSThemedLabel *colon;
@property (nonatomic, strong) SSThemedLabel *vs;
//@property (nonatomic, strong) SSThemedLabel *time;

@end

@implementation TTScoreView

- (SSThemedLabel *)leftScore {
    if (_leftScore == nil) {
        _leftScore = [[SSThemedLabel alloc] init];
        _leftScore.font = [UIFont fontWithName:@"DINAlternate-Bold" size:([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 30 : 36];
        _leftScore.textColorThemeKey = kColorText10;
        [self addSubview:_leftScore];
    }
    return _leftScore;
}

- (SSThemedLabel *)rightScore {
    if (_rightScore == nil) {
        _rightScore = [[SSThemedLabel alloc] init];
        _rightScore.font = [UIFont fontWithName:@"DINAlternate-Bold" size:([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 30 : 36];
        _rightScore.textColorThemeKey = kColorText10;
        [self addSubview:_rightScore];
    }
    return _rightScore;
}

- (SSThemedLabel *)colon {
    if (_colon == nil) {
        _colon = [[SSThemedLabel alloc] init];
        _colon.font = [UIFont tt_boldFontOfSize:([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 28 : 34];
        _colon.textColorThemeKey = kColorText10;
        _colon.textAlignment = NSTextAlignmentCenter;
        _colon.text = @":";
        [self addSubview:_colon];
    }
    return _colon;
}

- (SSThemedLabel *)vs {
    if (_vs == nil) {
        _vs = [[SSThemedLabel alloc] init];
        _vs.font = [UIFont fontWithName:@"DIN Condensed" size:([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 30 : 36];
        _vs.textColorThemeKey = kColorText10;
        _vs.text = @"VS";
        [self addSubview:_vs];
    }
    return _vs;
}

//- (SSThemedLabel *)time {
//    if (_time == nil) {
//        _time = [[SSThemedLabel alloc] init];
//        _time.font = [UIFont tt_boldFontOfSize:10];
//        _time.textColorThemeKey = kColorText10;
//        [self addSubview:_time];
//    }
//    return _time;
//}

- (void)updateScore:(LiveMatch *)match status:(NSInteger)status {
    if (status == 1) {
        self.leftScore.hidden = YES;
        self.colon.hidden = YES;
        self.rightScore.hidden = YES;
        self.vs.hidden = NO;
//        self.time.hidden = NO;
        if ([match time]) {
//            self.time.text = [match time];
            [self.vs sizeToFit];
//            [self.time sizeToFit];
            
            self.vs.centerY = ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 15 : 18;
            self.left = 0;
//            self.time.top = 36 + 4;
//            self.time.centerX = self.vs.centerX;
//            self.time.height = 10;
            
            self.width = self.vs.width;
            self.height = ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 30 : 36;
        }
    } else {
        self.leftScore.hidden = NO;
        self.colon.hidden = NO;
        self.rightScore.hidden = NO;
        self.vs.hidden = YES;
//        self.time.hidden = YES;
        NSNumber *score1 = [match score1];
        NSNumber *score2 = [match score2];
        if (score1 && score2) {
            self.leftScore.text = [NSString stringWithFormat:@"%@", score1];
            self.rightScore.text = [NSString stringWithFormat:@"%@", score2];
            
            [self.leftScore sizeToFit];
            [self.rightScore sizeToFit];
            [self.colon sizeToFit];
            
            CGFloat width = self.leftScore.width > self.rightScore.width ? self.leftScore.width : self.rightScore.width;
            
            self.colon.width += 20;
            self.size = CGSizeMake(width * 2 + self.colon.width, ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 30 : 36);
            self.colon.height = ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 30 : 36;
            self.colon.top = -8;
            self.colon.centerX = self.width / 2;
            self.leftScore.centerY = ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 15 : 18;
            self.leftScore.right = self.colon.left;
            self.rightScore.centerY = ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 15 : 18;
            self.rightScore.left = self.colon.right;
        }
    }
}

@end
