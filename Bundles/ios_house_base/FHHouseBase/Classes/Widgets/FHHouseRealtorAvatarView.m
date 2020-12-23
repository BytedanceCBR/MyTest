//
//  FHHouseRealtorAvatarView.m
//  FHHouseBase
//
//  Created by bytedance on 2020/12/17.
//

#import "FHHouseRealtorAvatarView.h"
#import <BDWebImage/BDWebImage.h>
#import <Masonry/Masonry.h>
#import <FHHouseDetail/FHDetailBaseModel.h>
#import "UIImage+FIconFont.h"

@interface FHHouseRealtorAvatarView ()

@property (nonatomic, weak) UIImageView *maskImageView;

@end

@implementation FHHouseRealtorAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
//        UIImageView *maskImageView = [[UIImageView alloc] init];
//        [self.avatarImageView addSubview:maskImageView];
//        self.maskImageView = maskImageView;
//        [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(UIEdgeInsetsZero);
//        }];
    }
    return self;
}

-(UIImageView *)identifyImageView {
    if(!_identifyImageView) {
        _identifyImageView = [[UIImageView alloc] init];
        _identifyImageView.contentMode = UIViewContentModeScaleAspectFill;
        _identifyImageView.hidden = YES;
        [self addSubview:_identifyImageView];
    }
    return _identifyImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.bounds)/2;
//    UIImage *cornerImage = [UIImage fh_roundRectMaskImageWithCornerRadius:CGRectGetWidth(self.bounds)/2 color:[UIColor whiteColor] size:self.frame.size];
//    self.maskImageView.image = cornerImage;
}

- (void)updateAvatarImageURL:(NSString *)url {
    if(url.length) {
        [self.avatarImageView bd_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"detail_default_avatar"];
    }
}

- (void)updateIdentifyImageURL:(NSString *)url {
    if (url.length) {
        self.identifyImageView.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:url] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!error && image) {
                strongSelf.identifyImageView.image = image;
                CGFloat ratio = 0;
                if (image.size.height > 0 && image.size.width) {
                    ratio = image.size.height / image.size.width;
                }
                [strongSelf.identifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.bottom.right.mas_equalTo(strongSelf);
                    make.height.mas_equalTo(strongSelf.avatarImageView.mas_width).multipliedBy(ratio);
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
@end
