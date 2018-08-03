//
//  TTCommentDetailHeaderGroupItem.m
//  Article
//
//  Created by muhuai on 2017/4/18.
//
//

#import "TTCommentDetailHeaderGroupItem.h"
#import <TTBaseLib/TTLabelTextHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTImage/TTImageView.h>
#import <TTRoute/TTRoute.h>

@interface TTCommentDetailHeaderGroupItem ()
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTImageView *thumbImageView;
@property (nonatomic, strong) SSThemedImageView *playIconView;
@property (nonatomic, strong) TTCommentDetailModel *model;
@end

@implementation TTCommentDetailHeaderGroupItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupLayouts];
        [self addGestureRecognizer:({
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundOnClick:)];
            gesture;
        })];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColorThemeKey = kColorBackground3;
    [self.thumbImageView addSubview:self.playIconView];
    [self addSubview:self.thumbImageView];
    [self addSubview:self.titleLabel];
}

- (void)setupLayouts {
    self.playIconView.center = CGPointMake(CGRectGetMidX(self.thumbImageView.bounds), CGRectGetMidY(self.thumbImageView.bounds));
    self.thumbImageView.left = [TTDeviceUIUtils tt_padding:8.f];
    self.titleLabel.left = self.thumbImageView.right + [TTDeviceUIUtils tt_padding:10.f];
    self.titleLabel.height = [TTDeviceUIUtils tt_padding:48.f];
    self.titleLabel.width = self.width - [TTDeviceUIUtils tt_padding:8.f] - self.titleLabel.left;
    self.titleLabel.centerY = self.thumbImageView.centerY = CGRectGetMidY(self.bounds);
}

- (void)refreshWithDetailModel:(TTCommentDetailModel *)detailModel {
    self.model = detailModel;
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:detailModel.groupTitle fontSize:[TTDeviceUIUtils tt_fontSize:14.f] lineHeight:[TTDeviceUIUtils tt_fontSize:19.f] lineBreakMode:NSLineBreakByTruncatingTail];

    [self.thumbImageView setImageWithURLString:detailModel.groupThumbURL placeholderImage:[UIImage themedImageNamed:@"default_feed_share_icon"]];
    self.playIconView.hidden = detailModel.groupMediaType != 2;
}

- (void)backgroundOnClick:(id)sender {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.model.groupOpenURL]];
}

#pragma mark - getter & setter
- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText2;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (TTImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_padding:42.f], [TTDeviceUIUtils tt_padding:42.f])];
        _thumbImageView.backgroundColorThemeKey = kColorBackground2;
    }
    return _thumbImageView;
}

- (SSThemedImageView *)playIconView {
    if (!_playIconView) {
        _playIconView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_padding:30.f],  [TTDeviceUIUtils tt_padding:30.f])];
        _playIconView.imageName = @"u11_play";
        _playIconView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _playIconView.hidden = YES;
    }
    return _playIconView;
}
@end
