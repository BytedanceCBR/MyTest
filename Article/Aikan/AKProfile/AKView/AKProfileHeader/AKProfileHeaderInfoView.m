//
//  AKProfileHeaderViewInfoView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/5.
//
#import "AKProfileHeaderInfoView.h"
#import "AKProfileHeaderViewDefine.h"

#import <UIImageView+BDWebImage.h>
#import <UIColor+TTThemeExtension.h>
@interface AKProfileHeaderInfoView ()

@property (nonatomic, strong)UIImageView            *avatorImageView;
@property (nonatomic, strong)UILabel                *userNameLabel;
@property (nonatomic, strong)UILabel                *subTitleLabel;
@property (nonatomic, strong)UIView                 *infoContainerView;

@end

@implementation AKProfileHeaderInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatorImageView.left = kHPaddingContentView;
    self.avatorImageView.centerY = self.height / 2;
    [self refreshInfoContainerView];
    CGFloat HPaddinginfoContainerView = [TTDeviceUIUtils tt_newPadding:10];
    self.infoContainerView.width = self.width - self.avatorImageView.right - HPaddinginfoContainerView * 2;
    self.infoContainerView.centerY = self.avatorImageView.centerY;
    self.infoContainerView.left = self.avatorImageView.right + HPaddinginfoContainerView;
}

- (void)refreshInfoContainerView
{
    CGFloat labelPadding = 5.f;
    CGFloat viewHeight = self.userNameLabel.height + labelPadding + self.subTitleLabel.height;
    self.infoContainerView.height = viewHeight;
    self.userNameLabel.origin = CGPointMake(0, 0);
    self.subTitleLabel.left = self.userNameLabel.left;
    self.subTitleLabel.top = self.userNameLabel.bottom + labelPadding;
}

- (void)createComponent
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:50], [TTDeviceUIUtils tt_newPadding:50]);
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = imageView.size.width / 2;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
    imageView.userInteractionEnabled = NO;
    [self addSubview:imageView];
    self.avatorImageView = imageView;
    
    UIView *infoContainerView = [[UIView alloc] init];
    infoContainerView.backgroundColor = [UIColor clearColor];
    infoContainerView.userInteractionEnabled = NO;
    [self addSubview:infoContainerView];
    self.infoContainerView = infoContainerView;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = [UIColor colorWithHexString:@"1A1A1A"];
    nameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:18.f]];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"未登录";
    nameLabel.userInteractionEnabled = NO;
    [nameLabel sizeToFit];
    [infoContainerView addSubview:nameLabel];
    self.userNameLabel = nameLabel;
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.textColor = [UIColor colorWithHexString:@"999999"];
    subTitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
    subTitleLabel.text = @"查看并编辑个人资料";
    subTitleLabel.textAlignment = NSTextAlignmentLeft;
    subTitleLabel.userInteractionEnabled = NO;
    [subTitleLabel sizeToFit];
    [infoContainerView addSubview:subTitleLabel];
    self.subTitleLabel = subTitleLabel;
}

- (void)setupUserName:(NSString *)name
{
    self.userNameLabel.text = name;
    [self.userNameLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setupAvatorImageWithImageURL:(NSString *)url
{
    if (isEmptyString(url)) {
        self.avatorImageView.image = nil;
        return;
    }
    
    [self.avatorImageView bd_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default_avatar"]];
}

- (void)setupUserName:(NSString *)name avatorImage:(NSString *)imageURL
{
    [self setupAvatorImageWithImageURL:imageURL];
    [self setupUserName:name];
}

@end
