//
//  FHErrorMaskView.m
//  Article
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "FHErrorMaskView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@interface FHErrorMaskView ()

@property(nonatomic , strong) UIImageView *errorImageView;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIButton *retryButton;
@property(nonatomic , strong) UITapGestureRecognizer *tapGesture;

@end

@implementation FHErrorMaskView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"group-9"];
        self.errorImageView = [[UIImageView alloc] initWithImage:image];
        self.errorImageView.userInteractionEnabled = NO;
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontRegular:14];
        _tipLabel.textColor = [UIColor themeGray1];
        _tipLabel.text = @"网络异常，请检查网络连接";//@"网络异常";
        [_tipLabel sizeToFit];
        
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_retryButton setTitle:@"刷新" forState:UIControlStateNormal];
        _retryButton.layer.cornerRadius  = 15;
        _retryButton.titleLabel.font = [UIFont themeFontRegular:14];
        _retryButton.layer.borderColor = [[UIColor themeRed1]CGColor];
        _retryButton.layer.borderWidth = 1;
        _retryButton.layer.masksToBounds = YES;
        [_retryButton addTarget:self action:@selector(retryAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:_errorImageView];
        [self addSubview:_tipLabel];
        [self addSubview:_retryButton];
 
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(20);
            make.left.mas_greaterThanOrEqualTo(20);
            make.right.mas_lessThanOrEqualTo(self).offset(-20);
            make.centerY.mas_equalTo(self).offset(20);
        }];
        
        [_errorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(126, 126));
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(_tipLabel.mas_top).offset(-20);
        }];
        
        [_retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(18);
            make.centerX.mas_equalTo(_tipLabel);
            make.size.mas_equalTo(CGSizeMake(84, 30));
        }];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retryAction:)];
    }
    return _tapGesture;
}

-(void)retryAction:(id)sender
{
    if (_tapGesture) {
        [self removeGestureRecognizer:_tapGesture];
    }
    if(_retryBlock){
        _retryBlock();
    }
}

-(void)showError:(NSError *)error
{
    self.tipLabel.text = error.description;
}

-(void)showErrorWithTip:(NSString *)tip
{
    self.tipLabel.text = tip;
}

-(void)showRetry:(BOOL)show
{
    self.retryButton.hidden = !show;
}

-(void)enableTap:(BOOL)enable
{
    if (enable) {
        [self addGestureRecognizer:self.tapGesture];
    }else if(_tapGesture){
        [self removeGestureRecognizer:_tapGesture];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
