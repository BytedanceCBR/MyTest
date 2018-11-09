//
//  TSVFeedFollowCellContentView.m
//  Article
//
//  Created by dingjinlu on 2017/12/8.
//

#import "TSVFeedFollowCellContentView.h"
#import "TTImageView.h"
#import "TTArticleCellHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoOriginalData.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTRouteService.h"
#import <HTSVideoPlay/HTSVideoPageParamHeader.h>
#import <TTUIWidget/TTNavigationController.h>
#import "NSObject+FBKVOController.h"
#import <TTRelevantDurationTracker.h>

#import <TSVDebugInfoView.h>
#import <TSVDebugInfoConfig.h>

#define kPlayIconSize               12.f
#define kPlayIconTopPadding         13.f
#define kPlayIconTitleGap           3.f
#define kPlayIconRightGap           2.f

#define kLeftPadding                15.f
#define kTopPadding                 10.f
#define kCoverAspectRatio           (335.f / 247.f)
#define kMaskAspectRatio            (68.f  / 247.f)
#define kItemWidthRatio             (247.f / 375.f)

#define kLeftGapOnTop               8.f
#define kInfoLabeRightGap           4.f

NS_INLINE CGFloat TTHuoShanCollectionCellInfobarLabelMinWidth() {
    static CGFloat minWidth = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *minStr = @"一";
        CGSize minSize = [minStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        minWidth = ceil(minSize.width);
    });
    return minWidth;
}

@interface TSVFeedFollowCellContentView()

@property(nonatomic, strong) TTImageView *coverImageView;         //封面图
@property(nonatomic, strong) UIImageView *bottomMaskImage;        //底部阴影
@property(nonatomic, strong) SSThemedImageView *playIcon;         //播放icon
//@property(nonatomic, strong) SSThemedLabel *titleLabel;           //标题
//@property(nonatomic, strong) SSThemedLabel *infoLabel;            //播放次数或者用户名
@property(nonatomic, strong) SSThemedLabel *extraLabel;           //评论/点赞数

@property(nonatomic, strong) ExploreOrderedData *orderedData;
@property(nonatomic, strong) TTShortVideoModel   *model;

@property (nonatomic, strong) TSVDebugInfoView *debugInfoView;

@end

@implementation TSVFeedFollowCellContentView

- (void)setupWithData:(ExploreOrderedData *)data
{
    self.orderedData = data;
    self.model = self.orderedData.shortVideoOriginalData.shortVideo;
    
    [self refreshUIData];
}

- (void)refreshUIData
{
    TTImageInfosModel *imageModel = self.model.detailCoverImageModel;

    [self.coverImageView setImageWithModel:imageModel placeholderImage:nil];
    
//    self.titleLabel.text = self.model.title;
//
//    self.infoLabel.text = [NSString stringWithFormat:@"%@次播放", [TTBusinessManager formatPlayCount:self.model.playCount]];
    
//    self.extraLabel.text = [self extraLabelText];
    
    self.debugInfoView.debugInfo = self.model.debugInfo;
    
    [self setNeedsLayout];
}

- (NSString *)extraLabelText{
     if (self.orderedData.cellCtrls && [self.orderedData.cellCtrls isKindOfClass: [NSDictionary class]]) {
        ExploreOrderedDataCellFlag cellFlag = [self.orderedData.cellCtrls tt_integerValueForKey:@"cell_flag"];
        if ((cellFlag & ExploreOrderedDataCellFlagShowCommentCount) != 0) {
            return [NSString stringWithFormat:@"%@评论", [TTBusinessManager formatCommentCount:self.model.commentCount]];
        } else if ((cellFlag & ExploreOrderedDataCellFlagShowDig) != 0) {
            return [NSString stringWithFormat:@"%@赞", [TTBusinessManager formatCommentCount:self.model.diggCount]];
        }
    }
    return [NSString stringWithFormat:@"%@评论", [TTBusinessManager formatCommentCount:self.model.commentCount]];
}

#pragma mark - UI

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [[[[[RACSignal combineLatest:@[RACObserve(self, model.commentCount),
                                       RACObserve(self, model.diggCount),
                                       RACObserve(self, model.playCount)]]
            distinctUntilChanged]
           takeUntil:[self rac_willDeallocSignal]]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self refreshUIData];
         }];
    }
    return self;
}

- (void)layoutSubviews
{
    
    self.coverImageView.frame = CGRectMake(0, 0, 200, 150);
    self.playIcon.center = self.coverImageView.center;

}


#pragma mark - UI Lazy Initialization

- (TTImageView *)coverImageView{
    if(!_coverImageView){
        _coverImageView = [[TTImageView alloc] init];
        _coverImageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
        _coverImageView.backgroundColorThemeKey = kColorBackground3;
        _coverImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _coverImageView.borderColorThemeKey = kColorLine1;
        _coverImageView.layer.cornerRadius = 4;
        _coverImageView.layer.masksToBounds = YES;
        [self addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UIImageView *)bottomMaskImage{
    if(!_bottomMaskImage) {
        _bottomMaskImage = [[UIImageView alloc] init];
        UIImage *tmpImage = [UIImage imageNamed:@"cover_huoshan"];
        _bottomMaskImage.image = [UIImage imageWithCGImage:tmpImage.CGImage
                                                         scale:tmpImage.scale
                                                   orientation:UIImageOrientationDown];
        _bottomMaskImage.backgroundColor = [UIColor clearColor];
        _bottomMaskImage.contentMode = UIViewContentModeScaleToFill;
//        [self.coverImageView addSubview:_bottomMaskImage];
    }
    return _bottomMaskImage;
}

- (SSThemedImageView *)playIcon{
    if(!_playIcon){
        _playIcon = [[SSThemedImageView alloc] init];
        _playIcon.contentMode = UIViewContentModeScaleAspectFill;
        _playIcon.imageName = @"Play";
        [_playIcon sizeToFit];
        [self addSubview:_playIcon];
    }
    return _playIcon;
}


- (SSThemedLabel *)extraLabel{
    if(!_extraLabel){
        _extraLabel = [[SSThemedLabel alloc] init];
        _extraLabel.textColorThemeKey = kColorText10;
        _extraLabel.numberOfLines = 1;
        _extraLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _extraLabel.font = [UIFont systemFontOfSize:12];
//        [self addSubview:_extraLabel];
    }
    return _extraLabel;
}

- (TSVDebugInfoView *)debugInfoView
{
    if (!_debugInfoView) {
        _debugInfoView = [[TSVDebugInfoView alloc] init];
        _debugInfoView.hidden = YES;
        [self addSubview:_debugInfoView];
    }
    
    return _debugInfoView;
}

- (void)refreshDebugInfo
{
    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        [self bringSubviewToFront:self.debugInfoView];
        self.debugInfoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 80);
        self.debugInfoView.hidden = NO;
    } else {
        self.debugInfoView.hidden = YES;
    }
}

@end
