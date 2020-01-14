//
//  FHMineHeaderView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineHeaderView.h"
#import <BDWebImage/BDWebImage.h>
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIImageView+BDWebImage.h"
#import "FHUtils.h"
#import "UIButton+TTAdditions.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "TTRoute.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "TTDeviceHelper.h"

@interface FHMineHeaderView ()

@property (nonatomic, assign) CGFloat naviBarHeight;
@property (nonatomic, copy) NSString *homePageScheme;

@end


@implementation FHMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight {
    self = [super initWithFrame:frame];
    
    if(self){
        _naviBarHeight = naviBarHeight;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self initView];
    [self initConstaints];
}

- (void)initView {
    self.headerImageView = [[UIImageView alloc] init];
    UIImage *image = [self ct_imageFromImage:[UIImage imageNamed:@"fh_mine_header_bg"] inRect:self.bounds];
    _headerImageView.image = image;
    [self addSubview:_headerImageView];
    
    self.beforeHeaderView = [[UIImageView alloc] init];
    _beforeHeaderView.image = [self ct_imageFromImage:image inRect:CGRectMake(0,0, image.size.width, 1)];
    [self addSubview:_beforeHeaderView];
    
    self.iconBorderView = [[UIView alloc] init];
    [self addSubview:_iconBorderView];
    
    self.icon = [[UIImageView alloc] init];
    self.icon.contentMode = UIViewContentModeScaleAspectFill;
    [self.iconBorderView addSubview:_icon];
    
    self.userNameLabel = [[UILabel alloc] init];
    [self addSubview:_userNameLabel];
    [self setNameLabelStyle:_userNameLabel];
    
    self.descLabel = [[UILabel alloc] init];
    [self addSubview:_descLabel];
    [self setDesclabelStyle:_descLabel];
    
    self.editIcon = [[UIImageView alloc] init];
    _editIcon.image = [UIImage imageNamed:@"fh_mine_edit"];
    [self addSubview:_editIcon];
    
    self.homePageBtn = [[UIButton alloc] init];
    _homePageBtn.imageView.contentMode = UIViewContentModeCenter;
    [_homePageBtn setImage:[UIImage imageNamed:@"fh_ugc_arrow_right_white"] forState:UIControlStateNormal];
    [_homePageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _homePageBtn.titleLabel.font = [UIFont themeFontRegular:12];
    _homePageBtn.hidden = YES;
    [_homePageBtn addTarget:self action:@selector(goToHomePage:) forControlEvents:UIControlEventTouchUpInside];
//    _homePageBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    
//    if([TTDeviceHelper isScreenWidthLarge320]){
//        _homePageBtn.titleLabel.layer.masksToBounds = YES;
//        _homePageBtn.layer.cornerRadius = 4;
//        _homePageBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
//        _homePageBtn.layer.borderWidth = 0.5;
//
//    }else{
//        _homePageBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
//    }
    
    [self addSubview:_homePageBtn];
}

- (void)initConstaints {
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.beforeHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.headerImageView.mas_top);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(500);
    }];
    
    [self.iconBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(self.naviBarHeight);
        make.width.height.mas_equalTo(66);
    }];
    
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconBorderView).offset(6);
        make.top.mas_equalTo(self.iconBorderView).offset(4);
        make.width.height.mas_equalTo(54);
    }];

    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28);
        make.top.mas_equalTo(self.iconBorderView.mas_top).offset(7);
        make.left.mas_equalTo(self.iconBorderView.mas_right).offset(8);
        make.right.mas_equalTo(self).offset(-20);
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userNameLabel.mas_left);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom);
        make.right.mas_lessThanOrEqualTo(self.userNameLabel.mas_right);
        make.height.mas_equalTo(20);
    }];
    
    [_editIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.left.mas_equalTo(self.descLabel.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(self.descLabel);
    }];
    
    [_homePageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconBorderView);
        make.bottom.mas_equalTo(self);
        make.width.mas_equalTo(50);
        make.right.mas_equalTo(self);
        make.centerY.mas_equalTo(self.iconBorderView.mas_centerY);
    }];
    
    [self layoutIfNeeded];
    [FHUtils addShadowToView:self.icon withOpacity:0.1 shadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(0, 0) shadowRadius:6 andCornerRadius:27];
}

-(void)setNameLabelStyle: (UILabel*) nameLabel {
    nameLabel.font = [UIFont themeFontMedium:20];
    nameLabel.textColor = [UIColor whiteColor];
}

-(void)setDesclabelStyle: (UILabel*) descLabel {
    descLabel.font = [UIFont themeFontRegular:14];
    descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
}

-(void)updateAvatar:(NSString *)avatarUrl {
    if(avatarUrl){
        [self.icon bd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"] options:BDImageRequestDefaultPriority completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        
        }];
    }else{
        self.icon.image = [UIImage imageNamed:@"fh_mine_avatar"];
    }
}

// state:0 展示username，居中，desc不显示，不可点击；（默认）
// state:1 展示username，展示desc，点击toast提示；
// state:2 展示username，展示desc，点击到编辑页面
- (void)setUserInfoState:(NSInteger)state
{
    NSInteger vState = state;
    if (vState > 2 || vState < 0) {
        vState = 0;
    }
    
    if (vState == 0) {
        _descLabel.hidden = YES;
        _editIcon.hidden = YES;
        
        [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(28);
            make.centerY.mas_equalTo(self.icon);
            make.left.mas_equalTo(self.icon.mas_right).offset(14);
            make.right.mas_lessThanOrEqualTo(self).offset(-20).priorityHigh();
        }];
    }else{
        _editIcon.hidden = NO;
        _descLabel.hidden = NO;
        
        [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(28);
            make.top.mas_equalTo(self.icon.mas_top).offset(3);
            make.left.mas_equalTo(self.icon.mas_right).offset(14);
            make.right.mas_lessThanOrEqualTo(self).offset(-20).priorityHigh();
        }];
    }
}

- (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}

- (void)sethomePageWithModel:(FHMineConfigDataHomePageModel *)model {
    if(model && model.showHomePage && [TTAccountManager isLogin] && [FHEnvContext isUGCOpen]){
        self.homePageBtn.hidden = NO;
        
        self.homePageScheme = model.schema;
        
//        if([TTDeviceHelper isScreenWidthLarge320]){
//            [_homePageBtn setTitle:model.homePageContent forState:UIControlStateNormal];
//            //文字的size
//            CGSize textSize = [_homePageBtn.titleLabel.text sizeWithFont:_homePageBtn.titleLabel.font];
//            CGSize imageSize = _homePageBtn.currentImage.size;
//
//            //目前仅支持最大4个汉字
//            if(textSize.width > 48){
//                textSize.width = 48;
//                CGRect frame = _homePageBtn.titleLabel.frame;
//                frame.size.width = textSize.width;
//                _homePageBtn.titleLabel.frame = frame;
//            }
//
//            CGFloat marginGay = 8;//图片跟文字之间的间距
//            _homePageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, textSize.width + marginGay/2, 0, - textSize.width - marginGay/2);
//            _homePageBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width - marginGay/2, 0, imageSize.width + marginGay/2);
//            _homePageBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 8 + marginGay/2, 0, 8 + marginGay/2);
//        }
        
        [self layoutIfNeeded];
        
        [_userNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-self.homePageBtn.size.width);
        }];
        
    }else{
        self.homePageBtn.hidden = YES;
        
        [_userNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-20);
        }];
    }
}

- (void)goToHomePage:(id)sender {
    if(TTAccountManager.userID){
        NSString *urlStr = [NSString stringWithFormat:@"sslocal://profile?uid=%@&from_page=mine",TTAccountManager.userID];
        NSURL* url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    }
}

@end
