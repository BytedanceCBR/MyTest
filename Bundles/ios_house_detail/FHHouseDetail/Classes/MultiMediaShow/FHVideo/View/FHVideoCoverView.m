//
//  FHVideoCoverView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/25.
//

#import "FHVideoCoverView.h"
#import <Masonry.h>
#import "UIImageView+BDWebImage.h"

@interface FHVideoCoverView ()

@property(nonatomic, strong) UIImage *placeHolder;

@end

@implementation FHVideoCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstaints];
    }
    
    return self;
}

- (void)initViews {
    self.coverView = [[UIImageView alloc] initWithFrame:self.bounds];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.clipsToBounds = YES;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_coverView];
    
    self.startBtn = [[UIButton alloc] init];
    [_startBtn setImage:[UIImage imageNamed:@"video_start"] forState:UIControlStateNormal];
    [_startBtn setImage:[UIImage imageNamed:@"video_start"] forState:UIControlStateHighlighted];
    [_startBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_startBtn];
}

- (void)initConstaints {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
             make.width.height.mas_equalTo(60);
            make.center.equalTo(self);
    }];
}

- (void)setHouseType:(FHMultiMediaCellHouseType)houseType {
    _houseType = houseType;
    if (_houseType == FHMultiMediaCellHouseSecond)  {
        [self.startBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(52);
            make.top.mas_equalTo(94);
            make.centerX.mas_equalTo(self);
        }];
    }
}
-(void)showWithImageUrl:(NSString *)imageUrl placeHoder:(UIImage *)placeHolder
{
    _imageUrl = imageUrl;
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    if(!placeHolder){
        placeHolder = self.placeHolder;
    }
    [self.coverView bd_setImageWithURL:url placeholder:placeHolder];
}

- (void)setImageUrl:(NSString *)imageUrl {

    [self showWithImageUrl:imageUrl placeHoder:nil];
}


- (void)playVideo {
    if(self.delegate && [self.delegate respondsToSelector:@selector(playVideo)]){
        [self.delegate playVideo];
    }
}

-(UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

@end
