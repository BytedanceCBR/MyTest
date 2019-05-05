//
//  TTRecommendUserCollectionViewWrapper.m
//  Article
//
//  Created by lipeilun on 2017/6/19.
//
//

#import "TTRecommendUserCollectionViewWrapper.h"
#import "NSStringAdditions.h"

@implementation TTRecommendUserCollectionViewWrapper

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame isWeitoutiao:NO];
}


- (instancetype)initWithFrame:(CGRect)frame isWeitoutiao:(BOOL)isWeitoutiao {
    if (self = [super initWithFrame:frame]) {
        SSThemedLabel *recommendLabel = [[SSThemedLabel alloc] init];
        recommendLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        recommendLabel.textColorThemeKey = kColorText1;
        recommendLabel.text = @"相关推荐";
        [recommendLabel sizeToFit];
        recommendLabel.left = [TTDeviceUIUtils tt_newPadding:15];
        recommendLabel.top = [TTDeviceUIUtils tt_newPadding:10];
        recommendLabel.height = [recommendLabel.text sizeWithFontCompatible:recommendLabel.font].height;
        [self addSubview:recommendLabel];
        self.titleLabel = recommendLabel;
        
        TTRecommendUserCollectionView *rucollectionView = [TTRecommendUserCollectionView collectionView];
        if (isWeitoutiao) {
            rucollectionView.followSource = TTFollowNewSourceRecommendRelateWeitoutiaoCategory;
        } else {
            rucollectionView.followSource = TTFollowNewSourceRecommendRelateMainFeed;
        }
        rucollectionView.disableDislike = YES;
        rucollectionView.backgroundColor = [UIColor clearColor];
        rucollectionView.frame = CGRectMake(0, recommendLabel.bottom + [TTDeviceUIUtils tt_newPadding:12], self.width, 0);
        [self addSubview:rucollectionView];
        self.collectionView = rucollectionView;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    if (frame.size.height > 0) {
    
    
    if (frame.size.height != 0 && self.collectionView.height == 0) {
        self.collectionView.frame = CGRectMake(0, self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:1], self.width, self.height - self.titleLabel.bottom - [TTDeviceUIUtils tt_newPadding:6]);
    }
//    } else {
//        self.titleLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:10], self.width - [TTDeviceUIUtils tt_newPadding:30], 0);
//        self.collectionView.frame = CGRectMake(0, self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:1], self.width, 0);
//    }
}
@end
