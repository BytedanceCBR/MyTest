//
//  FHAppUpdateView.m
//  FHHouseHome
//
//  Created by bytedance on 2020/9/21.
//

#import "FHAppUpdateView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import <ios_house_im/UIView+Utils.h>
#import <TTBaseLib/TTUIResponderHelper.h>

@interface FHAppUpdateView ()

@property (nonatomic, weak) UIView *backgroundView;

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *bgImageView;
//@property (nonatomic, weak) UIView *borderView;
//@property (nonatomic, weak) UILabel *versionLabel;
@property (nonatomic, weak) UILabel *contentLabel;

@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIButton *updateButton;

@end

@implementation FHAppUpdateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [[UIColor colorWithHexString:@"#333333"] colorWithAlphaComponent:0.7];
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        //279 400
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(frame) - 327/2, CGRectGetMidY(frame) - 476/2 - 35, 327, 476)];
        [self addSubview:contentView];
        self.contentView = contentView;
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
                make.width.mas_equalTo(320);
            } else {
                make.width.mas_equalTo(327);
                make.height.mas_equalTo(476);
            }
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self).mas_offset(-35);
        }];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [bgImageView setImage:[UIImage imageNamed:@"app_update_bg"]];
        [self.contentView addSubview:bgImageView];
        self.bgImageView = bgImageView;
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
//        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(62, 127, 155, 119)];
//        borderView.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
//        borderView.layer.borderColor = [UIColor colorWithHexString:@"#ff3c00"].CGColor;
//        borderView.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:borderView];
//        self.borderView = borderView;
//        [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(UIEdgeInsetsMake(127, 62, 154, 62));
//        }];
        
//        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.contentView.frame), 105, 0, 14)];
//        versionLabel.font = [UIFont themeFontRegular:10];
//        versionLabel.textColor = [UIColor colorWithHexString:@"#ff3c00"];
//        versionLabel.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:versionLabel];
//        self.versionLabel = versionLabel;
//        [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(self.contentView);
//            make.top.mas_equalTo(105);
//            make.height.mas_equalTo(14);
//        }];
        
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.textColor = [UIColor colorWithHexString:@"#ff3c00"];;
        contentLabel.font = [UIFont themeFontRegular:14];
        contentLabel.numberOfLines = 6;
        contentLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(150);
            make.left.mas_equalTo(72);
            make.right.mas_equalTo(-72);
//            make.height.mas_lessThanOrEqualTo(self.borderView.mas_height).mas_offset(-16);
        }];
    }
    return self;
}

- (void)updateInfoWithVersion:(NSString *)version content:(NSString *)content forceUpdate:(BOOL )forceUpdate {
//    self.versionLabel.text = version;
    if (content.length) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#ff3c00"], NSFontAttributeName : [UIFont themeFontRegular:14]}];
        NSMutableParagraphStyle *style = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
        style.lineSpacing = 6;
        [string addAttributes:@{NSParagraphStyleAttributeName: style.copy} range:NSMakeRange(0, string.length)];
        self.contentLabel.attributedText = string.copy;
    }
    __weak typeof(self) weakSelf = self;
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
        if (weakSelf.updateBlock) {
            weakSelf.updateBlock();
        }
    }];
    [updateButton setBackgroundImage:[UIImage imageNamed:@"app_update_ok"] forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateButton.titleLabel.font = [UIFont themeFontRegular:15];
    [updateButton setTitle:@"立即升级" forState:UIControlStateNormal];
    [self.contentView addSubview:updateButton];
    self.updateButton = updateButton;
    [self.updateButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(54);
        make.right.mas_equalTo(-64);
        make.bottom.mas_equalTo(-73);
        make.height.mas_equalTo(56);
    }];
    
    if (!forceUpdate) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.closeBlock) {
                weakSelf.closeBlock();
            }
        }];
        [closeButton setImage:[UIImage imageNamed:@"app_update_close"] forState:UIControlStateNormal];
        [self.contentView addSubview:closeButton];
        self.closeButton = closeButton;
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.updateButton.mas_centerX);
            make.bottom.mas_equalTo(-13);
//            make.width.mas_equalTo(114);
//            make.height.mas_equalTo(32);
        }];
    }
}

- (void)show {
    
    UIWindow *keyWindow = [UIView keyWindow];
    [keyWindow endEditing:YES];
    [keyWindow addSubview:self];
    self.frame = keyWindow.bounds;
    
    UIViewController *topViewController = [TTUIResponderHelper topmostViewController];
    if (topViewController && [topViewController isKindOfClass:[UIViewController class]]) {
        [topViewController.view endEditing:YES];
    }
    
    self.backgroundView.alpha = 0.0;
    self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        self.backgroundView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.backgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
