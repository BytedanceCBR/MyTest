//
//  TTCertificationOccupationalPhotoView.m
//  Article
//
//  Created by wangdi on 2017/5/21.
//
//

#import "TTCertificationOccupationalPhotoView.h"
#import "TTAlphaThemedButton.h"

@interface TTCertificationOccupationalPhotoItemView : TTAlphaThemedButton

@property (nonatomic, strong) SSThemedImageView *addIcon;
@property (nonatomic, strong) SSThemedLabel *topLabel;
@property (nonatomic, strong) SSThemedLabel *middleLabel;
@property (nonatomic, strong) SSThemedLabel *bottomLabel;
@property (nonatomic, strong) TTBaseInfoPhotoItemImageView *photoImageView;

@end

@implementation TTCertificationOccupationalPhotoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground3;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhoto) name:kDeletePhotoNotification object:nil];
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedImageView *addIcon = [[SSThemedImageView alloc] init];
    addIcon.imageName = @"icon_add";
    [self addSubview:addIcon];
    self.addIcon = addIcon;
    
    SSThemedLabel *topLabel = [[SSThemedLabel alloc] init];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = @"在职证明、工牌、职业资质均可";
    topLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    topLabel.textColorThemeKey = kColorText3;
    [self addSubview:topLabel];
    self.topLabel = topLabel;
    
    SSThemedLabel *middleLabel = [[SSThemedLabel alloc] init];
    middleLabel.textAlignment = NSTextAlignmentCenter;
    middleLabel.text = @"提供加盖公章的证明材料可提高审核通过率";
    middleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    middleLabel.textColorThemeKey = kColorText3;
    [self addSubview:middleLabel];
    self.middleLabel = middleLabel;
    
    SSThemedLabel *bottomLabel = [[SSThemedLabel alloc] init];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = @"上传资料系统自动打水印保护隐私";
    bottomLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    bottomLabel.textColorThemeKey = kColorText3;
    [self addSubview:bottomLabel];
    self.bottomLabel = bottomLabel;
    
    TTBaseInfoPhotoItemImageView *photoImageView = [[TTBaseInfoPhotoItemImageView alloc] init];
    photoImageView.hidden = YES;
    [self addSubview:photoImageView];
    self.photoImageView = photoImageView;
}

- (void)deletePhoto
{
    if(self.photoImageView.hidden) {
        self.addIcon.hidden = NO;
        self.topLabel.hidden = NO;
        self.middleLabel.hidden = NO;
        self.bottomLabel.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.addIcon.width = [TTDeviceUIUtils tt_newPadding:51];
    self.addIcon.height = self.addIcon.width;
    self.addIcon.centerX = self.width * 0.5;
    self.addIcon.top = [TTDeviceUIUtils tt_newPadding:20];
    
    self.topLabel.left = 0;
    self.topLabel.width = self.width;
    self.topLabel.height = [TTDeviceUIUtils tt_newPadding:20];
    self.topLabel.top = self.addIcon.bottom + [TTDeviceUIUtils tt_newPadding:13];
    
    self.middleLabel.left = 0;
    self.middleLabel.width = self.width;
    self.middleLabel.height = [TTDeviceUIUtils tt_newPadding:20];
    self.middleLabel.top = self.topLabel.bottom;
    
    self.bottomLabel.left = 0;
    self.bottomLabel.width = self.width;
    self.bottomLabel.height = [TTDeviceUIUtils tt_newPadding:20];
    self.bottomLabel.top = self.middleLabel.bottom;
    
    self.photoImageView.width = [TTDeviceUIUtils tt_newPadding:180];
    self.photoImageView.height = [TTDeviceUIUtils tt_newPadding:135];
    self.photoImageView.top = [TTDeviceUIUtils tt_newPadding:19];
    self.photoImageView.centerX = self.width * 0.5;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface TTCertificationOccupationalPhotoView ()

@property (nonatomic, strong) TTCertificationOccupationalPhotoItemView *photoItemView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@end

@implementation TTCertificationOccupationalPhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
    
}

- (void)setImage:(UIImage *)image
{
    [self.photoItemView.photoImageView setImage:image];
    if(image) {
        self.photoItemView.addIcon.hidden = YES;
        self.photoItemView.topLabel.hidden = YES;
        self.photoItemView.middleLabel.hidden = YES;
        self.photoItemView.bottomLabel.hidden = YES;
    } else {
        self.photoItemView.addIcon.hidden = NO;
        self.photoItemView.topLabel.hidden = NO;
        self.photoItemView.middleLabel.hidden = NO;
        self.photoItemView.bottomLabel.hidden = NO;
    }
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.text = @"上传证明材料";
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    titleLabel.textColorThemeKey = kColorText1;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    TTCertificationOccupationalPhotoItemView *photoItemView = [[TTCertificationOccupationalPhotoItemView alloc] init];
    [photoItemView addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:photoItemView];
    self.photoItemView = photoItemView;
    
}

- (void)photoClick:(TTCertificationOccupationalPhotoItemView *)photoView
{
    if(!photoView.photoImageView.hidden) return;
    if(self.takePhotoBlock) {
        self.takePhotoBlock();
    }
}

- (BOOL)isCompleted
{
    return !self.photoItemView.photoImageView.hidden;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.width = self.width - self.titleLabel.left;
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
    
    self.photoItemView.left = [TTDeviceUIUtils tt_newPadding:15];
    self.photoItemView.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:10];
    self.photoItemView.height = [TTDeviceUIUtils tt_newPadding:165];
    self.photoItemView.width = self.width - 2 * self.photoItemView.left;
    
    self.height = self.photoItemView.bottom;
}

@end
