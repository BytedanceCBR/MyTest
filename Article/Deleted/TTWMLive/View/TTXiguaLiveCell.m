//
//  TTXiguaLiveCell.m
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "TTXiguaLiveCell.h"
#import "ExploreCellHelper.h"
#import "TTXiguaLiveModel.h"
#import "ExploreArticleCellViewConsts.h"
#import <TTLabelTextHelper.h>
#import <TTAsyncCornerImageView.h>
#import <TTAsyncCornerImageView+VerifyIcon.h>
#import <TTVerifyIconHelper.h>
#import "UIView+TTCSSUIKit.h"
#import "TTArticleCellHelper.h"
#import <TTAlphaThemedButton.h>
#import "TTXiguaLiveLivingAnimationView.h"
#import "FRRouteHelper.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "TTXiguaLiveManager.h"
#import "UIView+UGCAdditions.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTUGCAttributedLabel.h"
#import "TTCSSUIKitHelper.h"

@interface TTXiguaLiveCell()
@property (nonatomic, strong) TTXiguaLiveCellView *liveCellView;
@end

@implementation TTXiguaLiveCell

+ (Class)cellViewClass {
    return [TTXiguaLiveCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)willAppear {
    [self.cellView willAppear];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context {
    [self.cellView didDisappear];
}

- (ExploreCellViewBase *)liveCellView {
    if (!_liveCellView) {
        _liveCellView = [[TTXiguaLiveCellView alloc] initWithFrame:self.bounds];
    }
    
    return _liveCellView;
}

@end

@interface TTXiguaLiveCellView()
@property (nonatomic, strong) TTAsyncCornerImageView *avatarImageView;
@property (nonatomic, strong) TTImageView *largePicView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) TTUGCAttributedLabel *contentLabel;
@property (nonatomic, strong) TTAlphaThemedButton *dislikeButton;
//@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, strong) TTXiguaLiveLivingAnimationView *livingAnimationView;

@property (nonatomic, strong) TTXiguaLiveModel *xiguaModel;
@property (nonatomic, strong, readonly) TTXiguaLiveLayoutBase *xiguaLayout;

//分割线（视图）
@property (nonatomic, strong) SSThemedView           * topSeparateView;
@property (nonatomic, strong) SSThemedView           * bottomSeparateView;
@end

@implementation TTXiguaLiveCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.largePicView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.dislikeButton];
//        [self addSubview:self.bottomLineView];
        [self addSubview:self.livingAnimationView];
        self.topSeparateView = [self ugc_addSubviewWithClass:[SSThemedView class] themePath:@"#ThreadU11TopSeparateView"];
        self.bottomSeparateView = [self ugc_addSubviewWithClass:[SSThemedView class]];
        self.bottomSeparateView.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:self.topSeparateView];
        [self addSubview:self.bottomSeparateView];
    }
    
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if (![data isKindOfClass:[ExploreOrderedData class]]) {
        return 0;
    }
    
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    TTXiguaLiveModel *xiguaModel = [orderedData xiguaLiveModel];
    if (!xiguaModel) {
        return 0;
    }
    
    if (!xiguaModel.layout) {
        xiguaModel.layout = [[TTXiguaLiveLayoutBase alloc] init];
    }
    
    [xiguaModel.layout refreshComponentsLayoutWithData:data width:width];
    return xiguaModel.layout.cellHeight;
}

- (void)willAppear {
    [self.livingAnimationView beginAnimation];
}

- (void)didDisappear {
    [self.livingAnimationView stopAnimation];
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[TTXiguaLiveModel class]]) {
        self.xiguaModel = (TTXiguaLiveModel *)self.orderedData.originalData;
    } else {
        self.xiguaModel = nil;
        return;
    }
    
    [self.avatarImageView tt_setImageWithURLString:self.xiguaLayout.avatarUrl];
    if (self.xiguaLayout.showVerifyIcon) {
        [self.avatarImageView showVerifyViewWithVerifyInfo:self.xiguaLayout.userAuthInfo];
    } else {
        [self.avatarImageView hideVerifyView];
    }
    
    self.nameLabel.text = [self.xiguaModel liveUserInfoModel].name;
    self.descLabel.text = self.xiguaLayout.descLabelStr;
    self.contentLabel.attributedText = self.xiguaLayout.contentAttributedStr;
    [self.largePicView setImageWithURLString:[self.xiguaModel largeImageModel].url];
}

- (void)refreshUI {
    self.topSeparateView.hidden = !self.xiguaLayout.needTopPadding;
    self.topSeparateView.frame = self.xiguaLayout.topSeparatorFrame;
    
    self.avatarImageView.frame = self.xiguaLayout.avatarViewFrame;
    self.avatarImageView.cornerRadius = self.avatarImageView.width / 2;
    [self.avatarImageView setupVerifyViewForLength:self.avatarImageView.width adaptationSizeBlock:nil];
    
    self.nameLabel.frame = self.xiguaLayout.nameLabelFrame;
    
    self.descLabel.frame = self.xiguaLayout.descLabelFrame;
    
    self.dislikeButton.left = self.xiguaLayout.dislikeButtonLeft;
    self.dislikeButton.size = self.xiguaLayout.dislikeButtonSize;
    self.dislikeButton.centerY = self.xiguaLayout.dislikeButtonCenterY;
    
    self.contentLabel.frame = self.xiguaLayout.contentFrame;
    self.contentLabel.numberOfLines = self.xiguaLayout.contentLines;
    self.largePicView.frame = self.xiguaLayout.largePicFrame;
    
    self.livingAnimationView.center = self.largePicView.center;
    
//    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
//    if ([(ExploreOrderedData *)self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
//        self.bottomLineView.hidden = YES;
//    } else {
//        self.bottomLineView.hidden = NO;
//    }
    
    self.bottomSeparateView.hidden = !self.xiguaLayout.needBottomPadding;
    self.bottomSeparateView.frame = self.xiguaLayout.bottomSeparatorFrame;
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {

    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:@(1) forKey:@"card_position"];
    [extraDic setValue:self.orderedData.categoryID forKey:@"category_name"];
    [extraDic setValue:self.orderedData.logPb forKey:@"log_pb"];
    [extraDic setValue:self.xiguaModel.groupId forKey:@"group_id"];
    [extraDic setValue:@"big_image" forKey:@"cell_type"];

    UIViewController *audienceVC = [[TTXiguaLiveManager sharedManager] audienceRoomWithUserID:[self.xiguaModel liveUserInfoModel].userId extraInfo:extraDic];
    [self.navigationController pushViewController:audienceVC animated:YES];
}

- (id)cellData {
    return self.orderedData;
}

- (void)avatarClick:(id)sender {
    [FRRouteHelper openProfileForUserID:[self.xiguaModel liveUserInfoModel].userId.longLongValue];
}

- (void)unInterestedAction:(TTAlphaThemedButton *)sender {
    if (!self.orderedData) {
        return;
    }
    
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = nil;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.xiguaLiveModel.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = sender.center;
    [dislikeView showAtPoint:point
                    fromView:sender
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (!self.orderedData) {
        return;
    }
    NSArray * filterWords = [view selectedWords];
    NSMutableDictionary * userInfo = @{}.mutableCopy;
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark - GET
- (TTXiguaLiveLayoutBase *)xiguaLayout {
    return self.xiguaModel.layout;
}

- (TTAsyncCornerImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[TTAsyncCornerImageView alloc] initWithFrame:self.xiguaLayout.avatarViewFrame allowCorner:YES];
        _avatarImageView.borderWidth = 0.0f;
        _avatarImageView.coverColor = [UIColor colorWithWhite:0 alpha:0.05];
        _avatarImageView.cornerRadius = TTFLOAT(@"#ThreadU12Cell", @"avatarWidth")/2.f;
        _avatarImageView.placeholderName = @"default_avatar";
        [_avatarImageView setupVerifyViewForLength:TTFLOAT(@"#ThreadU12Cell", @"avatarWidth") adaptationSizeBlock:nil];
        [_avatarImageView addTouchTarget:self action:@selector(avatarClick:)];
    }
    return _avatarImageView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.font = [UIFont tt_boldFontOfSize:14];
    }
    return _nameLabel;
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColorThemeKey = kColorText3;
        _descLabel.font = [UIFont tt_fontOfSize:12];
    }
    return _descLabel;
}

- (TTAlphaThemedButton *)dislikeButton {
    if (!_dislikeButton) {
        _dislikeButton = [[TTAlphaThemedButton alloc] init];
        _dislikeButton.imageName = @"add_textpage";
        [_dislikeButton addTarget:self action:@selector(unInterestedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dislikeButton;
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    }
    return _contentLabel;
}

- (TTImageView *)largePicView {
    if (!_largePicView) {
        _largePicView = [[TTImageView alloc] init];
        _largePicView.enableNightCover = YES;
        _largePicView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _largePicView.clipsToBounds = YES;
        _largePicView.backgroundColorThemeKey = kColorBackground3;
    }
    return _largePicView;
}

//- (SSThemedView *)bottomLineView {
//    if (!_bottomLineView) {
//        _bottomLineView = [[SSThemedView alloc] init];
//        _bottomLineView.backgroundColorThemeKey = kColorLine1;
//    }
//    return _bottomLineView;
//}

- (TTXiguaLiveLivingAnimationView *)livingAnimationView {
    if (!_livingAnimationView) {
        _livingAnimationView = [[TTXiguaLiveLivingAnimationView alloc] initWithStyle:TTXiguaLiveLivingAnimationViewStyleLargeAndLine];
    }
    return _livingAnimationView;
}

@end


































