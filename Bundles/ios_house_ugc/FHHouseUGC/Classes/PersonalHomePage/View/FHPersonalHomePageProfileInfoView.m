//
//  FHPersonalHomePageProfileInfoView.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageProfileInfoView.h"
#import "TTAccountManager.h"
#import "UIImageView+BDWebImage.h"
#import "NSString+BTDAdditions.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTRoute.h"

@interface FHPersonalHomePageProfileInfoBackView : UIView
@end

@implementation FHPersonalHomePageProfileInfoBackView

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
}

@end


@interface FHPersonalHomePageProfileInfoView ()
@property(nonatomic,strong) UIView *backView;
@property(nonatomic,strong) UIImageView *iconView;
@property(nonatomic,strong) UILabel *userNameLabel;
@property(nonatomic,strong) UILabel *descLabel;
@property(nonatomic,strong) UIButton *changeButton;
@property(nonatomic,strong) UIView *seperatorView;
@end

@implementation FHPersonalHomePageProfileInfoView
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.shadowView = [[FHPersonalHomePageProfileInfoImageView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 160)];
    [self addSubview:self.shadowView];
    
    self.backView = [[FHPersonalHomePageProfileInfoBackView alloc] initWithFrame:CGRectZero];
    self.backView.backgroundColor = [UIColor themeWhite];
    [self addSubview:self.backView];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 74, 80, 80)];
    self.iconView.layer.cornerRadius = 40;
    self.iconView.layer.borderColor = [UIColor themeWhite].CGColor;
    self.iconView.layer.borderWidth = 2;
    self.iconView.layer.masksToBounds = YES;
    [self addSubview:self.iconView];
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 54, SCREEN_WIDTH - 40 , 28)];
    self.userNameLabel.textColor = [UIColor themeGray1];
    self.userNameLabel.font = [UIFont themeFontSemibold:20];
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.textColor = [UIColor themeGray2];
    self.descLabel.font = [UIFont themeFontRegular:14];
    
    self.changeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 92, 14, 72, 30)];
    self.changeButton.titleLabel.font = [UIFont themeFontRegular:13];
    self.changeButton.layer.cornerRadius = 15;
    self.changeButton.layer.masksToBounds = YES;
    self.changeButton.layer.borderColor = [UIColor themeGray2].CGColor;
    self.changeButton.layer.borderWidth = 0.5;
    [self.changeButton setTitle:@"修改资料" forState:UIControlStateNormal];
    [self.changeButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [self.changeButton addTarget:self action:@selector(changeProfileInfo) forControlEvents:UIControlEventTouchUpInside];
    self.changeButton.hidden = YES;

    self.seperatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.seperatorView.backgroundColor = [UIColor themeGray6];
    [self addSubview:self.seperatorView];
    
    [self.backView addSubview:self.userNameLabel];
    [self.backView addSubview:self.descLabel];
    [self.backView addSubview:self.changeButton];
}

- (void)updateWithModel:(FHPersonalHomePageProfileInfoModel *)model isVerifyShow:(BOOL)isVerifyShow{
    CGFloat backViewHeight = 90 - 8 + 15;
    
    [self.shadowView updateWithUrl:model.data.avatarUrl];
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:model.data.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    self.userNameLabel.text = model.data.name;
   
    if(!isEmptyString(model.data.desc)) {
        CGSize descLabelSize = [model.data.desc btd_sizeWithFont:[UIFont themeFontRegular:14] width:SCREEN_WIDTH - 40];
        self.descLabel.text = model.data.desc;
        self.descLabel.frame = CGRectMake(20, 90, descLabelSize.width, descLabelSize.height);
        backViewHeight = backViewHeight + 8 + descLabelSize.height;
    }

    if([model.data.userId isEqualToString:[TTAccountManager userID]]) {
        self.changeButton.hidden = NO;
    } else {
        self.changeButton.hidden = YES;
    }
    
    self.backView.frame = CGRectMake(0, 110, SCREEN_WIDTH, backViewHeight);
    self.viewHeight = 110 + backViewHeight;
    self.seperatorView.frame = CGRectMake(0, self.viewHeight - 0.5, SCREEN_WIDTH, 0.5);
}


- (void)changeProfileInfo {
    NSURL* url = [NSURL URLWithString:@"sslocal://editUserProfile"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

@end



@interface FHPersonalHomePageProfileInfoImageView ();
@property(nonatomic,strong) UIImageView *imageView;
@end

@implementation FHPersonalHomePageProfileInfoImageView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, - 0.2 * SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH)];
        [self addSubview:_imageView];
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        effectView.frame = frame;
        effectView.alpha = 1;
        [self addSubview:effectView];
        [self bringSubviewToFront:effectView];
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)updateWithUrl:(NSString *)url {
    [self.imageView bd_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
}
@end

