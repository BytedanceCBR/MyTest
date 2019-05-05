//
//  TTBaseInfoPhotoView.m
//  Article
//
//  Created by wangdi on 2017/5/18.
//
//

#import "TTBaseInfoPhotoView.h"

@interface TTBaseInfoPhotoItemView ()

@property (nonatomic, strong) SSThemedImageView *addIcon;
@property (nonatomic, strong) SSThemedLabel *bottomLabel;
@property (nonatomic, strong) TTBaseInfoPhotoItemImageView *photoImageView;

@end

@implementation TTBaseInfoPhotoItemView

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
    
    SSThemedLabel *bottomLabel = [[SSThemedLabel alloc] init];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = @"手持身份证照片";
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
        self.bottomLabel.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.addIcon.width = [TTDeviceUIUtils tt_newPadding:57];
    self.addIcon.height = self.addIcon.width;
    self.addIcon.centerX = self.width * 0.5;
    self.addIcon.top = [TTDeviceUIUtils tt_newPadding:41.5];
    
    self.bottomLabel.left = 0;
    self.bottomLabel.top = self.addIcon.bottom + [TTDeviceUIUtils tt_newPadding:10];
    self.bottomLabel.width = self.width;
    self.bottomLabel.height = [TTDeviceUIUtils tt_newPadding:20];
    
    self.photoImageView.left = [TTDeviceUIUtils tt_newPadding:10];
    self.photoImageView.width = self.width - 2 * self.photoImageView.left;
    self.photoImageView.height = [TTDeviceUIUtils tt_newPadding:109];
    self.photoImageView.top  = (self.height - self.photoImageView.height) * 0.5;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@interface TTBaseInfoPhotoView ()

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTBaseInfoPhotoItemView *photoOne;
@property (nonatomic, strong) TTBaseInfoPhotoItemView *photoTwo;

@end

@implementation TTBaseInfoPhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.text = @"上传身份证明";
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    titleLabel.textColorThemeKey = kColorText1;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    TTBaseInfoPhotoItemView *photoOne = [[TTBaseInfoPhotoItemView alloc] init];
    photoOne.tag = TTPhotoTypeIDCard;
    [photoOne addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    photoOne.bottomLabel.text = @"手持身份证照片";
    [self addSubview:photoOne];
    self.photoOne = photoOne;
    
    
    TTBaseInfoPhotoItemView *photoTwo = [[TTBaseInfoPhotoItemView alloc] init];
    [photoTwo addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    photoTwo.tag = TTPhotoTypePerson;
    photoTwo.bottomLabel.text = @"身份证正面照片";
    [self addSubview:photoTwo];
    self.photoTwo = photoTwo;
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image photoType:(TTPhotoType)photoType
{
    if(photoType == TTPhotoTypeIDCard) {
        [self.photoOne.photoImageView setImage:image];
        if(image) {
            self.photoOne.addIcon.hidden = YES;
            self.photoOne.bottomLabel.hidden = YES;
        } else {
            self.photoOne.addIcon.hidden = NO;
            self.photoOne.bottomLabel.hidden = NO;

        }
        
    } else {
        [self.photoTwo.photoImageView setImage:image];
        if(image) {
            self.photoTwo.addIcon.hidden = YES;
            self.photoTwo.bottomLabel.hidden = YES;
        } else {
            self.photoTwo.addIcon.hidden = NO;
            self.photoTwo.bottomLabel.hidden = NO;
            
        }
    }
}

- (void)photoClick:(TTBaseInfoPhotoItemView *)photoView
{
    if(!photoView.photoImageView.hidden) return;
    if(self.takePhotoBlock) {
        self.takePhotoBlock((int)photoView.tag);
    }
}

- (BOOL)isCompleted
{
    return !self.photoOne.photoImageView.hidden && !self.photoTwo.photoImageView.hidden;
}

- (NSDictionary *)images
{
    NSMutableDictionary *images = [NSMutableDictionary dictionary];
    [images setValue:self.photoOne.photoImageView.imageView.image forKey:@"id_photo1"];
    [images setValue:self.photoTwo.photoImageView.imageView.image forKey:@"id_photo2"];
    return images;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.width = self.width;
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
    
    CGFloat photoItemW = [TTDeviceUIUtils tt_newPadding:165];
    CGFloat margin = (self.width - photoItemW * 2) / 3;
    self.photoOne.left = margin;
    self.photoOne.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:10];
    self.photoOne.width = photoItemW;
    self.photoOne.height = self.photoOne.width;
    
    self.photoTwo.top = self.photoOne.top;
    self.photoTwo.width = self.photoOne.width;
    self.photoTwo.height = self.photoTwo.width;
    self.photoTwo.left = photoItemW + 2 * margin;
    self.height = self.photoOne.bottom;
}

@end
