//
//  TTInterestCell.m
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "TTInterestCell.h"

@implementation TTInterestCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        [self setAvatarViewStyle:SSAvatarViewStyleRectangle];
    }
    return self;
}

- (void)dealloc {
    _interestModel = nil;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _interestModel = nil;
}

- (void)reloadWithModel:(TTInterestItemModel *)aModel {
    if (!aModel) return;
    _interestModel = aModel;
    
    self.titleLabel.text = [aModel nameString];
    self.subtitle2Label.text = [aModel descriptionString];
    if (!isEmptyString([aModel avatarURLString])) {
        [self.avatarView showAvatarByURL:[aModel avatarURLString]];
    } else {
        UIImage *defaultImage = [UIImage imageWithColor:[UIColor tt_themedColorForKey:kColorBackground2] size:CGSizeMake(2, 2)];
        [self.avatarView setLocalAvatarImage:[defaultImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    }
    
//    // update contraints
//    CGFloat offsetXToMarginRight = [self.class spacingByMargin] + (self.followStatusButton.hidden ? 0 : self.followStatusButton.width + [self.class spacingByMargin]);
//    [self.textContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.contentView.mas_right).with.offset(-offsetXToMarginRight);
//    }];

    [self layoutIfNeeded];
}

#pragma mark - properties

- (void)setInterestModel:(TTInterestItemModel *)interestModel {
    [self reloadWithModel:interestModel];
}

#pragma mark - layout constants

+ (CGFloat)imageNormalSize{
    return 50.f;
}

+ (CGFloat)imageSize {
    return [TTDeviceUIUtils tt_padding:100.f/2];
}

+ (CGFloat)spacingOfTitle {
    return [TTDeviceUIUtils tt_padding:20.f/2];
}

+ (CGFloat)titleFontSize {
    return [TTDeviceUIUtils tt_fontSize:32.f/2];
}

+ (CGFloat)subtitle2FontSize {
    return [TTDeviceUIUtils tt_fontSize:26.f/2];
}

+ (CGFloat)cellHeight {
    return [TTDeviceUIUtils tt_padding:140.f/2];
}

+ (CGFloat)extraInsetTop {
    return [TTDeviceUIUtils tt_padding:-10.f/2];
}
@end
