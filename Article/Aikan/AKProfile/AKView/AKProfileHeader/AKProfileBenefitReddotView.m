//
//  AKProfileBenefitReddotView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import "AKProfileBenefitModel.h"
#import "AKProfileBenefitReddotView.h"

#import <UIColor+TTThemeExtension.h>
@interface AKProfileBenefitReddotView ()
@property (nonatomic, strong)UIImageView            *backImageView;
@property (nonatomic, strong)UILabel                *textLabel;

@end

@implementation AKProfileBenefitReddotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)createComponent
{
    _backImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIImage *image = [UIImage imageNamed:@"ak_profile_reddot_bg"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 0.5, image.size.width / 2 - 0.5, image.size.height / 2 - 0.5, image.size.width / 2 - 0.5) resizingMode:UIImageResizingModeStretch];
        imageView.image = image;
        imageView;
    });
    [self addSubview:_backImageView];
    
    _textLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10];
        label;
    });
    [self addSubview:self.textLabel];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.center = CGPointMake(self.width / 2 + 2.f, self.height / 2);
}

- (void)refreshContentWithInfo:(AKProfileBenefitReddotInfo *)info
{
    self.textLabel.text = info.text;
    [self.textLabel sizeToFit];
    if (isEmptyString(self.textLabel.text)) {
        self.size = CGSizeMake(4, 4);
        self.backImageView.backgroundColor = [UIColor colorWithHexString:@"F85959"];
        self.backImageView.image = nil;
        self.backImageView.layer.cornerRadius = self.width / 2;
        self.reddotType = AKProfileBenefitReddotViewTypeSimple;
    } else {
        self.reddotType = AKProfileBenefitReddotViewTypeText;
        if (!self.backImageView.image) {
            UIImage *image = [UIImage imageNamed:@"ak_profile_reddot_bg"];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 0.5, image.size.width / 2 - 0.5, image.size.height / 2 - 0.5, image.size.width / 2 - 0.5) resizingMode:UIImageResizingModeStretch];
            self.backImageView.image = image;
            self.backImageView.backgroundColor = UIColor.clearColor;
        }
        self.size = CGSizeMake(self.textLabel.width + 15, self.backImageView.image.size.height);
    }
}

- (void)checkFixIfNeedAdjustLabelWidth
{
    UIView *superView = self.superview;
    if (!superView) {
        return;
    }
    CGFloat dis = self.right - superView.width;
    if (dis > 0) {
        self.textLabel.width -= dis;
        self.width -= dis;
        [self setNeedsLayout];
    }
}

@end
