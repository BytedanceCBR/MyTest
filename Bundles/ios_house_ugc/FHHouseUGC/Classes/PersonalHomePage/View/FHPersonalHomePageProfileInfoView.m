//
//  FHPersonalHomePageProfileInfoView.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageProfileInfoView.h"
#import "TTPhotoScrollViewController.h"
#import "TTInteractExitHelper.h"
#import "TTAccountManager.h"
#import "UIImageView+BDWebImage.h"
#import "UILabel+BTDAdditions.h"
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
@property(nonatomic,strong) UILabel *verifyContentLabel;
@property(nonatomic,strong) UILabel *descLabel;
@property(nonatomic,strong) UIButton *changeButton;
@property(nonatomic,strong) UIView *seperatorView;
@property (nonatomic, copy , nullable) NSString *bigAvatarUrl;
@end

@implementation FHPersonalHomePageProfileInfoView
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.shadowView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.shadowView];
    
    self.backView = [[FHPersonalHomePageProfileInfoBackView alloc] initWithFrame:CGRectZero];
    self.backView.backgroundColor = [UIColor themeWhite];
    [self addSubview:self.backView];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconView.layer.cornerRadius = 40;
    self.iconView.layer.borderColor = [UIColor themeGray7].CGColor;
    self.iconView.layer.borderWidth = 2;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.userInteractionEnabled = YES;
    [self.iconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigAvatar:)]];
    [self addSubview:self.iconView];
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 54, SCREEN_WIDTH - 40 , 28)];
    self.userNameLabel.textColor = [UIColor themeGray1];
    self.userNameLabel.font = [UIFont themeFontSemibold:20];
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.textColor = [UIColor themeGray2];
    self.descLabel.font = [UIFont themeFontRegular:14];
    self.descLabel.numberOfLines = 5;

    self.verifyContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.verifyContentLabel.numberOfLines = 2;
    self.verifyContentLabel.hidden = YES;

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
    [self.backView addSubview:self.verifyContentLabel];
    [self.backView addSubview:self.descLabel];
    [self.backView addSubview:self.changeButton];
}

- (void)updateWithModel:(FHPersonalHomePageProfileInfoDataModel *)model isVerifyShow:(BOOL)isVerifyShow {
    CGFloat backViewHeight = 90 - 8 + 15;
    
    self.shadowView.frame = CGRectMake(0,0, SCREEN_WIDTH, 130 + self.homePageManager.safeArea);
    self.shadowView.image = [UIImage imageNamed:[NSString stringWithFormat:@"fh_ugc_personal_page_backview"]];
    self.iconView.frame = CGRectMake(20, 74 + self.homePageManager.safeArea, 80, 80);
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    self.bigAvatarUrl = model.bigAvatarUrl;
    self.userNameLabel.text = model.name;
    
    CGFloat verifyHeight = 0;
    if(isVerifyShow && !isEmptyString(model.verifiedContent)) {
        NSString *verifiedString = [NSString stringWithFormat:@" 认证：%@",model.verifiedContent];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString  alloc] initWithString:verifiedString];
        [attrStr addAttributes:@{
            NSFontAttributeName :[UIFont themeFontRegular:14],
            NSForegroundColorAttributeName : [UIColor themeGray1]
        } range:NSMakeRange(0, verifiedString.length)];
        NSTextAttachment *attachMent = [[NSTextAttachment alloc] init];
        attachMent.image = [UIImage imageNamed:@"ugc_v_tag"];
        attachMent.bounds = CGRectMake(-2, -2, 16, 16);
        [attrStr insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachMent] atIndex:0];

        self.verifyContentLabel.attributedText = attrStr;
        CGFloat height = [self.verifyContentLabel btd_heightWithWidth:SCREEN_WIDTH - 40];
        if(height > 25) {
            height = 40;
        } else {
            height = 20;
        }
        verifyHeight = 8 + height;
        backViewHeight = backViewHeight + verifyHeight;
        self.verifyContentLabel.frame = CGRectMake(20, 90, SCREEN_WIDTH - 40, height);
        self.verifyContentLabel.hidden = NO;
    }
   
    NSString *desc = model.desc;
    if([desc isKindOfClass:[NSString class]]) {
        desc = [desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if(!isEmptyString(desc)) {
        desc = [NSString stringWithFormat:@"简介：%@",model.desc];
        self.descLabel.text = desc;
        CGFloat descLabelHeight = [desc btd_sizeWithFont: [UIFont themeFontRegular:14] width:SCREEN_WIDTH - 40 maxLine:5].height;
        CGFloat offset = 90 + verifyHeight;
        self.descLabel.frame = CGRectMake(20, offset, SCREEN_WIDTH - 40, descLabelHeight);
        backViewHeight = backViewHeight + 8 + descLabelHeight;
    }

    if([model.userId isEqualToString:[TTAccountManager userID]]) {
        self.changeButton.hidden = NO;
    }
    
    self.backView.frame = CGRectMake(0, 110 + self.homePageManager.safeArea, SCREEN_WIDTH, backViewHeight);
    self.viewHeight = 110 + backViewHeight + self.homePageManager.safeArea;
    self.seperatorView.frame = CGRectMake(0, self.viewHeight - 5, SCREEN_WIDTH, 5);
}


- (void)changeProfileInfo {
    NSURL* url = [NSURL URLWithString:@"sslocal://editUserProfile"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}


- (void)showBigAvatar:(UIView *)sender {
    TTPhotoScrollViewController * controller = [[TTPhotoScrollViewController alloc] init];
    controller.mode = PhotosScrollViewSupportBrowse;
    controller.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    NSMutableArray * infoModels = [NSMutableArray arrayWithCapacity:10];
   
    TTImageInfosModel * iModel = [[TTImageInfosModel alloc] initWithURL:self.bigAvatarUrl];
    if (iModel) {
        [infoModels addObject:iModel];
    }

    controller.imageInfosModels = infoModels;
    [controller setStartWithIndex:0];
    
    NSMutableArray * frames = [NSMutableArray arrayWithCapacity:9];
    CGRect frame = [self.iconView convertRect:self.iconView.bounds toView:nil];
    [frames addObject:[NSValue valueWithCGRect:frame]];
        
    controller.placeholderSourceViewFrames = frames;
    controller.placeholders = [self photoObjs];
    [controller presentPhotoScrollView];
}

- (NSArray *)photoObjs {
    NSMutableArray *photoObjs = [NSMutableArray array];
    if (self.iconView.image) {
        [photoObjs addObject:self.iconView.image];
    }
    return photoObjs;
}

@end
