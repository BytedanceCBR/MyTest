//
//  TTLiveHeaderView+Star.m
//  Article
//
//  Created by matrixzk on 8/11/16.
//
//

#import "TTLiveHeaderView+Star.h"
#import "TTRoute.h"
#import "TTLiveStreamDataModel.h"


#import "UIButton+WebCache.h"

@implementation TTLiveHeaderView (Star)

- (void)setupSubviews4LiveTypeStar
{    
    // Status And NumOfParticipants
    TTLiveStreamDataModel *model = [TTLiveStreamDataModel new];
    model.status = self.dataModel.status;
    model.status_display = self.dataModel.status_display;
    model.participated = self.dataModel.participated;
    [self refreshStatusViewWithModel:model];
    
//    // Avatar
//    CGFloat kSideOfAvatar = TTLivePadding(70);
//    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.avatarButton.adjustsImageWhenHighlighted = NO;
//    self.avatarButton.layer.masksToBounds = YES;
//    self.avatarButton.layer.cornerRadius = kSideOfAvatar/2;
//    self.avatarButton.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine12].CGColor;
//
//    self.avatarButton.layer.borderWidth = TTLivePadding(2);
//    [self addSubview:self.avatarButton];
//    [self.avatarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[self.dataModel.background.star.icon tt_stringValueForKey:@"url"]]
//                                           forState:UIControlStateNormal
//                                   placeholderImage:[UIImage themedImageNamed:@"default_sdk_login"]];
//    WeakSelf;
//    [self.avatarButton addTarget:self withActionBlock:^{
//        StrongSelf;
//        NSString *openURLStr = self.dataModel.background.star.openURL;
//        if (!isEmptyString(openURLStr)) {
//            [[TTRoute sharedRoute] openURL:[NSURL URLWithString:openURLStr]];
//            // evnet track
//            [self.chatroom eventTrackWithEvent:@"live" label:@"cell_guest_head"];
//        }
//    } forControlEvent:UIControlEventTouchUpInside];
//    [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kSideOfAvatar, kSideOfAvatar));
//        make.bottom.equalTo(self.numOfParticipantsView.mas_top).offset(-TTLivePadding(26));
//        make.left.equalTo(self).offset(TTLivePadding(15));
//    }];
//    
//    // Name
//    SSThemedLabel *nameLabel = [self labelWithColorKey:kColorText12 fontSize:TTLiveFontSize(18)];
//    [self addShadowToLabel:nameLabel];
//    nameLabel.text = self.dataModel.background.star.name;
//    [self addSubview:nameLabel];
//    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.avatarButton).offset(TTLivePadding(12));
//        make.left.equalTo(self.avatarButton.mas_right).offset(TTLivePadding(12));
//    }];
//    
//    // Title
//    SSThemedLabel *titleLabel = [self labelWithColorKey:kColorText12 fontSize:TTLiveFontSize(14)];
//    [self addShadowToLabel:titleLabel];
//    titleLabel.text = self.dataModel.background.star.title;
//    [self addSubview:titleLabel];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(nameLabel);
//        make.bottom.equalTo(self.avatarButton).offset(-TTLivePadding(12));
//    }];
}

- (void)addShadowToLabel:(UILabel *)label
{
    label.layer.shadowColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.85].CGColor;
    label.layer.shadowRadius = 2.5;
    label.layer.shadowOpacity = 0.85;
    label.layer.shadowOffset = CGSizeZero;
}

@end
