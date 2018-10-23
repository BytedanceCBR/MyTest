//
//  TTCertificationTakePhotoTipView.m
//  Article
//
//  Created by wangdi on 2017/5/23.
//
//

#import "TTCertificationTakePhotoTipView.h"
#import "TTLocalResourceDownloader.h"


@implementation TTCertificationTakePhotoTipModel

@end

@interface TTCertificationTakePhotoTipView ()

@property (nonatomic, strong) SSThemedImageView *topImageView;

@end

@implementation TTCertificationTakePhotoTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        SSThemedImageView *topImageView = [[SSThemedImageView alloc] init];
        topImageView.width = [TTDeviceUIUtils tt_newPadding:277];
        topImageView.height = [TTDeviceUIUtils tt_newPadding:176];
        topImageView.centerX = frame.size.width * 0.5;
        topImageView.top = [TTDeviceUIUtils tt_newPadding:88];
        [self addSubview:topImageView];
        self.topImageView = topImageView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];

        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    WeakSelf;
    [UIImage imageNamed:imageName completion:^(UIImage *image) {
        StrongSelf;
        self.topImageView.image = image;
    }];
}

- (void)setTitleModels:(NSArray<TTCertificationTakePhotoTipModel *> *)titleModels
{
    _titleModels = titleModels;
    UIView *refView = self.topImageView;
    for(int i = 0;i < titleModels.count;i++) {
        TTCertificationTakePhotoTipModel *model = titleModels[i];
        SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
        titleLabel.text = model.title;
        titleLabel.textColor = model.textColor;
        titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
        [self addSubview:titleLabel];
        titleLabel.left = self.topImageView.left;
        titleLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
        titleLabel.width = self.topImageView.width;
        CGFloat titleLabelTop = 0;
        if(i == 0) {
            titleLabelTop = refView.bottom + [TTDeviceUIUtils tt_newPadding:20];
        } else {
            titleLabelTop = refView.bottom + [TTDeviceUIUtils tt_newPadding:10];
        }
        titleLabel.top = titleLabelTop;
        refView = titleLabel;
    }
}

- (void)tapClick
{
    [self removeFromSuperview];
}

@end
