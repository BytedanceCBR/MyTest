//
//  FHMineHeaderView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineHeaderView.h"
#import "BDWebImage.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <UIImageView+BDWebImage.h>
#import "FHUtils.h"

@interface FHMineHeaderView ()

@property (nonatomic, assign) CGFloat naviBarHeight;

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
        make.right.mas_lessThanOrEqualTo(self).offset(-20).priorityHigh();
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
            NSLog(@"1");
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


@end
