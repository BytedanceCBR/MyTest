//
//  TTMovieNetTrafficView.m
//  Article
//
//  Created by xiangwu on 2016/11/10.
//
//

#import "TTMovieNetTrafficView.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"

static const CGFloat kTopHeight = 44;
static const CGFloat kVPadding1 = 14.5;
static const CGFloat kVPadding2 = 23.5;
static const CGFloat kHPadding = 8;

@implementation TTMovieNetTrafficViewModel

@end

@interface TTMovieNetTrafficView ()

@property (nonatomic, strong) SSThemedLabel *tipLabel1;
@property (nonatomic, strong) SSThemedLabel *tipLabel2;
@property (nonatomic, strong) SSThemedLabel *tipLabel3;
@property (nonatomic, strong) SSThemedView *lineView;
@property (nonatomic, strong) UIButton *continuePlayBtn;

@end

@implementation TTMovieNetTrafficView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        _tipLabel1 = [[SSThemedLabel alloc] init];
        _tipLabel1.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        _tipLabel1.textAlignment = NSTextAlignmentCenter;
        _tipLabel1.font = [UIFont systemFontOfSize:14.f];
        _tipLabel1.text = NSLocalizedString(@"正在使用非WiFi网络，播放将产生流量费用", nil);
        [_tipLabel1 sizeToFit];
        [self addSubview:_tipLabel1];
        _tipLabel2 = [[SSThemedLabel alloc] init];
        _tipLabel2.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        _tipLabel2.textAlignment = NSTextAlignmentCenter;
        _tipLabel2.font = [UIFont systemFontOfSize:12.f];
        _tipLabel2.text = [NSString stringWithFormat:@"%@ 00:00", NSLocalizedString(@"视频时长", nil)];
        [_tipLabel2 sizeToFit];
        [self addSubview:_tipLabel2];
        _lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 1, 8)];
        _lineView.backgroundColor = [UIColor tt_defaultColorForKey:kColorText9];
        [self addSubview:_lineView];
        _tipLabel3 = [[SSThemedLabel alloc] init];
        _tipLabel3.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        _tipLabel3.textAlignment = NSTextAlignmentCenter;
        _tipLabel3.font = [UIFont systemFontOfSize:12.f];
        _tipLabel3.text = [NSString stringWithFormat:@"%@0MB", NSLocalizedString(@"流量 约", nil)];
        [_tipLabel3 sizeToFit];
        [self addSubview:_tipLabel3];
        _continuePlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 28)];
        _continuePlayBtn.layer.cornerRadius = 6;
        _continuePlayBtn.layer.masksToBounds = YES;
        _continuePlayBtn.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine11].CGColor;
        _continuePlayBtn.layer.borderWidth = 1;
        [_continuePlayBtn setTitle:NSLocalizedString(@"继续播放", nil) forState:UIControlStateNormal];
        [_continuePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText10] forState:UIControlStateNormal];
        _continuePlayBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_continuePlayBtn addTarget:self action:@selector(continuePlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_continuePlayBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat th = _tipLabel1.height + kVPadding1 + _tipLabel2.height + kVPadding2 + _continuePlayBtn.height;
    CGFloat y = 0;
    if (_viewModel.isInDetail) {
        y = (self.height - kTopHeight - th) / 2 + kTopHeight;
    } else {
        y = (self.height - th) / 2;
    }
    _tipLabel1.centerX = self.width / 2;
    _tipLabel1.top = y;
    y += _tipLabel1.height + kVPadding1;
    _tipLabel2.top = y;
    _tipLabel3.top = y;
    _lineView.centerX = self.width / 2;
    _lineView.centerY = _tipLabel2.centerY;
    _tipLabel2.right = _lineView.left - kHPadding;
    _tipLabel3.left = _lineView.right + kHPadding;
    y += _tipLabel2.height + kVPadding2;
    _continuePlayBtn.top = y;
    _continuePlayBtn.centerX = self.width / 2;
}

- (void)continuePlayBtnClicked:(UIButton *)sender {
    if (_continuePlayBlock) {
        _continuePlayBlock();
    }
}

- (void)setViewModel:(TTMovieNetTrafficViewModel *)viewModel {
    _viewModel = viewModel;
    NSInteger minute = viewModel.videoDuration / 60;
    NSInteger second = viewModel.videoDuration % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%02ld:%02ld", minute, second];
    _tipLabel2.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"视频时长", nil), timeStr];
    CGFloat size = viewModel.videoSize / 1024.f / 1024.f;
    _tipLabel3.text = [NSString stringWithFormat:@"%@%.2lfMB", NSLocalizedString(@"流量 约", nil), size];
    [_tipLabel2 sizeToFit];
    [_tipLabel3 sizeToFit];
    [self setNeedsLayout];
}

@end
