//
//  FHErrorView.m
//  Article
//
//  Created by 张元科 on 2018/12/9.
//

#import "FHErrorView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@interface FHErrorView ()

@property(nonatomic , strong) UIImageView *errorImageView;
@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHErrorView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:kFHErrorMaskNoNetWorkImageName];
        self.errorImageView = [[UIImageView alloc] initWithImage:image];
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontRegular:14];
        _tipLabel.textColor = [UIColor themeGray3];
        _tipLabel.text = @"网络异常，请检查网络连接";
        [_tipLabel sizeToFit];
        
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_retryButton setTitle:@"刷新" forState:UIControlStateNormal];
        _retryButton.layer.cornerRadius  = 15;
        _retryButton.titleLabel.font = [UIFont themeFontRegular:14];
        _retryButton.layer.borderColor = [[UIColor themeRed1]CGColor];
        _retryButton.layer.borderWidth = 1;
        [_retryButton setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_retryButton setBackgroundImage:[self createImageWithColor:[[UIColor themeRed1] colorWithAlphaComponent:0.1]] forState:UIControlStateHighlighted];
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

- (void)retryAction:(id)sender
{
    if(_retryBlock){
        _retryBlock();
    }
}

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType {
    NSString *tips = @"网络异常，请检查网络连接";
    BOOL showenRetry = YES;
    NSString *imageName = kFHErrorMaskNoNetWorkImageName;
    switch (maskViewType) {
        case FHEmptyMaskViewTypeNoNetWorkAndRefresh:
            tips = @"网络异常，请检查网络连接";
            showenRetry = YES;
            imageName = kFHErrorMaskNoNetWorkImageName;
            break;
        case FHEmptyMaskViewTypeNoNetWorkNotRefresh:
            tips = @"网络异常，请检查网络连接";
            showenRetry = NO;
            imageName = kFHErrorMaskNoNetWorkImageName;
            break;
        case FHEmptyMaskViewTypeNoData:
            tips = @"数据走丢了";
            showenRetry = NO;
            imageName = kFHErrorMaskNoDataImageName;
            break;
        case FHEmptyMaskViewTypeNetWorkError:
            tips = @"网络异常";
            showenRetry = NO;
            imageName = kFHErrorMaskNetWorkErrorImageName;
            break;
        case FHEmptyMaskViewTypeEmptyMessage:
            tips = @"暂无消息";
            showenRetry = NO;
            imageName = kFHErrorMaskNoMessageImageName;
            break;
        case FHEmptyMaskViewTypeNoDataForCondition:
            tips = @"暂无搜索结果";
            showenRetry = NO;
            imageName = kFHErrorMaskNetWorkErrorImageName;
            break;
        default:
            break;
    }
    [self showEmptyWithTip:tips errorImageName:imageName showRetry:showenRetry];
}

- (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)showEmptyWithTip:(NSString *)tips errorImageName:(NSString *)imageName showRetry:(BOOL)showen {
    UIImage *image = [UIImage imageNamed:imageName];
    [self showEmptyWithTip:tips errorImage:image showRetry:showen];
}

- (void)showEmptyWithTip:(NSString *)tips errorImage:(UIImage *)image showRetry:(BOOL)showen {
    self.hidden = NO;
    self.errorImageView.image = image;
    self.tipLabel.text = tips;
    _retryButton.hidden = !showen;
}

- (void)hideEmptyView {
    self.hidden = YES;
}

@end
