//
//  FHErrorMaskView.m
//  Article
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "FHErrorMaskView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"

@interface FHErrorMaskView ()

@property(nonatomic , strong) UIImageView *errorImageView;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIButton *retryButton;

@end

@implementation FHErrorMaskView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"group-9"];
        self.errorImageView = [[UIImageView alloc] initWithImage:image];
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontRegular:14];
        _tipLabel.textColor = [UIColor themeGray];
        _tipLabel.text = @"网络不给力，试试刷新页面";//@"网络异常";
        [_tipLabel sizeToFit];
        
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setTitleColor:[UIColor themeBlue] forState:UIControlStateNormal];
        [_retryButton setTitle:@"重新加载" forState:UIControlStateNormal];
        _retryButton.layer.cornerRadius  = 15;
        _retryButton.titleLabel.font = [UIFont themeFontRegular:14];
        _retryButton.layer.borderColor = [[UIColor themeBlue]CGColor];
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

-(void)retryAction:(id)sender
{
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
