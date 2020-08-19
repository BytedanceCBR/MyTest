//
//  FHRealtorAvatarView.m
//  Pods
//
//  Created by bytedance on 2020/8/11.
//

#import "FHRealtorAvatarView.h"
#import <BDWebImage/BDWebImage.h>
#import <Masonry/Masonry.h>
#import <FHHouseDetail/FHDetailBaseModel.h>

@interface FHRealtorAvatarView ()

@end

@implementation FHRealtorAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        UIImageView *avatarImageView = [[UIImageView alloc] init];
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        avatarImageView.image = [UIImage imageNamed:@"detail_default_avatar"];
        avatarImageView.userInteractionEnabled = YES;
        [self addSubview:avatarImageView];
        self.avatarImageView = avatarImageView;
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        UIImageView *identifyImageView = [[UIImageView alloc] init];
        identifyImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:identifyImageView];
        self.identifyImageView = identifyImageView;
        [self.identifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.avatarImageView.layer.cornerRadius != self.avatarImageView.frame.size.width/2) {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    }
}

- (void)updateAvatarImageURL:(NSString *)url {
    if (url.length) {
        [self.avatarImageView bd_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
    }
}

- (void)updateIdentifyImageURL:(NSString *)url {
    if (url.length) {
        self.identifyImageView.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:url] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (!error && image) {
                weakSelf.identifyImageView.image = image;
                CGFloat ratio = 0;
                if (image.size.height > 0 && image.size.width) {
                    ratio = image.size.height / image.size.width;
                }
                [weakSelf.identifyImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.bottom.right.mas_equalTo(0);
                    make.height.mas_equalTo(weakSelf.avatarImageView.mas_width).multipliedBy(ratio);
                }];
            }
        }];
    } else {
        self.identifyImageView.hidden = YES;
    }
}

- (void)updateAvatarWithModel:(FHDetailContactModel *)contactModel {
    if (contactModel.avatarUrl.length) {
        [self updateAvatarImageURL:contactModel.avatarUrl];
    }
    if (contactModel.imageTag.imageUrl.length) {
        self.identifyImageView.hidden = NO;
        [self updateIdentifyImageURL:contactModel.imageTag.imageUrl];
    }
    
//    if (contactModel.realtorCellShow == FHRealtorCellShowStyle0) {
//        self.identifyImageView.hidden = YES;
//    }
    if (contactModel.realtorCellShow == FHRealtorCellShowStyle3){
        self.identifyImageView.hidden = YES;
    }
}

@end
