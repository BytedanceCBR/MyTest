//
//  TTVMidInsertIconADView.m
//  Article
//
//  Created by lijun.thinker on 07/09/2017.
//
//

#import "TTVMidInsertIconADView.h"
#import "TTShowImageView.h"
#import "TTImageInfosModel.h"
#import <Masonry.h>

@interface TTVMidInsertIconADView() <TTShowImageViewDelegate>

@property (nonatomic, strong) TTShowImageView  *imageView;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UILabel *adLabel;

@property (nonatomic, strong) TTImageInfosModel *imageModel;

@property (nonatomic, assign) BOOL closeEnable;

@end

@implementation TTVMidInsertIconADView

- (instancetype)initWithFrame:(CGRect)frame imageModel:(TTImageInfosModel *)imageModel closeEnabled:(BOOL)enable {
    
    if (self = [super initWithFrame:frame]) {
        
        _imageModel = imageModel;
        _closeEnable = enable;
        [self ttv_setupViews];
    }
    
    return self;
}

- (void)ttv_setupViews {
    
    self.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[TTShowImageView alloc] initWithFrame:CGRectZero];
    self.imageView.delegate = self;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.imageInfosModel = self.imageModel;
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    if (_closeEnable) {
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"video_commodity_close"];
        [self.closeBtn setImage:image forState:UIControlStateNormal];
        self.closeBtn.backgroundColor = [UIColor blackColor];
        self.closeBtn.layer.cornerRadius = 7;
        self.closeBtn.clipsToBounds = YES;
        self.closeBtn.alpha = .7f;
        [self.closeBtn addTarget:self action:@selector(closeBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.height.mas_equalTo(14.f);
            make.width.mas_equalTo(14.f);
        }];
    }
    
    _adLabel = [[UILabel alloc] init];
    _adLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
    _adLabel.textColor = [UIColor whiteColor];
    _adLabel.backgroundColor = [UIColor blackColor];
    _adLabel.alpha = .7f;
    _adLabel.layer.cornerRadius = 2.f;
    _adLabel.clipsToBounds = YES;
    _adLabel.text = @"广告";
    [self addSubview:_adLabel];
    [self.adLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
    }];
}

- (void)updatSizeForFullScreenStatusChanged:(BOOL)isFullScreen {
    
    CGFloat scale = MAX([UIScreen mainScreen].scale, 1);
    
    if (isFullScreen) {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.imageModel.width / scale);
            make.height.mas_equalTo(self.imageModel.height / scale);
        }];
    } else {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.imageModel.width / scale * .6f);
            make.height.mas_equalTo(self.imageModel.height / scale * .6f);
        }];
    }
}

- (void)closeBtnDidClicked:(UIButton *)sender {
 
    (!self.TTVMidInsertIconADCloseAction) ?: self.TTVMidInsertIconADCloseAction();
}

#pragma makr - TTShowImageViewDelegate

- (void)showImageViewOnceTap:(TTShowImageView *)imageView {
    
    (!self.TTVMidInsertIconADGoDetailAction) ?: self.TTVMidInsertIconADGoDetailAction();
}

@end
