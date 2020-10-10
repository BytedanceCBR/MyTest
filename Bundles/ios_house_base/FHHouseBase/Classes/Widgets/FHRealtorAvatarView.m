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
#import <FHFeedUGCCellModel.h>
#import <TTShortVideoModel.h>
#import <FHCommonDefines.h>

@interface FHRealtorAvatarView ()

@end

@implementation FHRealtorAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _placeHoldName = @"detail_default_avatar";
        [self addSubview:_avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

-(UIImageView *)identifyImageView {
    if(!_identifyImageView) {
        _identifyImageView = [[UIImageView alloc] init];
        _identifyImageView.contentMode = UIViewContentModeScaleAspectFill;
        _identifyImageView.hidden = YES;
        [self addSubview:_identifyImageView];
        [self.identifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self);
            make.height.mas_equalTo(0);
        }];
    }
    return _identifyImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarImageView.layer.cornerRadius = MIN(self.frame.size.width, self.frame.size.height)/2;
}

- (void)updateAvatarImageURL:(NSString *)url {
    if(url.length) {
        [self.avatarImageView bd_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:self.placeHoldName]];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:self.placeHoldName];
    }
}

- (void)updateIdentifyImageURL:(NSString *)url {
    if (url.length) {
        self.identifyImageView.hidden = NO;
        WeakSelf;
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:url] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            StrongSelf;
            if (!error && image) {
                self.identifyImageView.image = image;
                CGFloat ratio = 0;
                if (image.size.height > 0 && image.size.width) {
                    ratio = image.size.height / image.size.width;
                }
                [self.identifyImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.avatarImageView.mas_width).multipliedBy(ratio);
                }];
            }
        }];
    } else {
        self.identifyImageView.hidden = YES;
    }
}

- (void)updateAvatarWithModel:(FHDetailContactModel *)contactModel {
    [self updateAvatarImageURL:contactModel.avatarUrl];
    [self updateIdentifyImageURL:contactModel.imageTag.imageUrl];

    if (contactModel.realtorCellShow == FHRealtorCellShowStyle3){
        self.identifyImageView.hidden = YES;
    }
}

-(void)updateAvatarWithUGCCellModel:(FHFeedUGCCellModel *)cellModel {
    if(cellModel.realtor.avatarUrl.length) {
        [self updateAvatarImageURL:cellModel.realtor.avatarUrl];
    }else if(cellModel.user.avatarUrl.length) {
        [self updateAvatarImageURL:cellModel.user.avatarUrl];
    }else{
         [self updateAvatarImageURL:nil];
    }
    
    [self updateIdentifyImageURL:cellModel.realtor.avatarTagUrl];
}

-(void)updateAvatarWithTSVUserModel:(FHFeedUGCCellModel *)userModel {
    if(userModel.realtor.avatarUrl.length) {
        [self updateAvatarImageURL:userModel.realtor.avatarUrl];
    }else if(userModel.user.avatarUrl.length) {
        [self updateAvatarImageURL:userModel.user.avatarUrl];
    }else{
         [self updateAvatarImageURL:nil];
    }
    [self updateIdentifyImageURL:userModel.realtor.avatarTagUrl];
}

@end
