//
//  TTRealnameAuthProgressView.m
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "TTRealnameAuthProgressView.h"
#import "TTRealnameAuthProgressStepView.h"
#import "TTRealnameAuthProgressLineView.h"

@interface TTRealnameAuthProgressView ()

@property (nonatomic, strong) TTRealnameAuthProgressStepView *idView;
@property (nonatomic, strong) TTRealnameAuthProgressStepView *faceView;
@property (nonatomic, strong) TTRealnameAuthProgressStepView *endView;
@property (nonatomic, strong) TTRealnameAuthProgressLineView *leftLine;
@property (nonatomic, strong) TTRealnameAuthProgressLineView *rightLine;

@end

@implementation TTRealnameAuthProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _idView = [TTRealnameAuthProgressStepView new];
        _faceView = [TTRealnameAuthProgressStepView new];
        _endView = [TTRealnameAuthProgressStepView new];
        _leftLine = [TTRealnameAuthProgressLineView new];
        _rightLine = [TTRealnameAuthProgressLineView new];
        
        [self addSubview:_idView];
        [self addSubview:_faceView];
        [self addSubview:_endView];
        [self addSubview:_leftLine];
        [self addSubview:_rightLine];
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self.idView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.centerX.equalTo(self.mas_centerX).with.offset(-118);
    }];
    [self.faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.endView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.centerX.equalTo(self.mas_centerX).with.offset(118);
    }];
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(2);
        make.left.equalTo(self.idView.mas_centerX).with.offset(14);
        make.right.equalTo(self.faceView.mas_centerX).with.offset(-14);
        make.centerY.equalTo(self.mas_top).with.offset(9);
    }];
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(2);
        make.left.equalTo(self.faceView.mas_centerX).with.offset(14);
        make.right.equalTo(self.endView.mas_centerX).with.offset(-14);
        make.centerY.equalTo(self.mas_top).with.offset(9);
    }];
    
    self.idView.title = @"身份认证";
    self.faceView.title = @"脸部识别";
    self.endView.title = @"完成";
}

- (void)setupViewWithStep:(TTRealnameAuthProgressStep)step
{
    switch (step) {
        case TTRealnameAuthProgressStart:
            self.leftLine.percent = 0.f;
            self.idView.highlight = NO;
            self.faceView.highlight = NO;
            self.endView.highlight = NO;
            break;
        case TTRealnameAuthProgressID:
            self.leftLine.percent = 0.5f;
            self.idView.highlight = YES;
            self.faceView.highlight = NO;
            self.endView.highlight = NO;
            break;
        case TTRealnameAuthProgressFace:
            self.leftLine.percent = 1.f;
            self.rightLine.percent = 0.5f;
            self.idView.highlight = YES;
            self.faceView.highlight = YES;
            self.endView.highlight = NO;
            break;
        case TTRealnameAuthProgressEnd:
            self.leftLine.percent = 1.f;
            self.rightLine.percent = 1.f;
            self.idView.highlight = YES;
            self.faceView.highlight = YES;
            self.endView.highlight = YES;
            break;
        default:
            break;
    }
}

@end
