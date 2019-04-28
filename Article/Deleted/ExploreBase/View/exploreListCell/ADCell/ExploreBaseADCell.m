//
//  ExploreBaseADCell.m
//  Article
//
//  Created by SunJiangting on 14-9-14.
//
//

#import "ExploreBaseADCell.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ArticleImpressionHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "ExploreCellViewBase.h"
#import "ExploreMixListDefine.h"
#import "ExploreOrderedData+TTAd.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData.h"
#import "ExploreOriginalData.h"
#import "NewsUserSettingManager.h"
#import "SSADActionManager.h"
#import "SSADEventTracker.h"
#import "SSItemActionSender.h"
#import "SSURLTracker.h"
#import "TTAlphaThemedButton.h"
#import "TTArticleCategoryManager.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "TTFeedDislikeView.h"
#import "TTPlatformSwitcher.h"
#import "TTThemeManager.h"
#import "TTUISettingHelper.h"

@interface ExploreBaseADCell ()
@end

Class ExploreADCellClassFromArticleDataSource(ExploreOrderedData * dataSource, NSString ** reuseIdentifier);
Class ExploreADCellClassFromADDataSource(ExploreOrderedData * dataSource, NSString ** reuseIdentifier);

@implementation ExploreBaseADCell {
    __weak UIView * _selectedView;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColorView = [[SSThemedView alloc] initWithFrame:self.cellView.bounds];
        self.backgroundColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColorView.backgroundColors = [TTUISettingHelper cellViewBackgroundColors];
        self.backgroundColorView.userInteractionEnabled = NO;
        [self.cellView addSubview:self.backgroundColorView];
        
        self.titleLabel = [[SSThemedLabel alloc] init];
        self.titleLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.titleLabel.textColors = [TTUISettingHelper cellViewTitleColors];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:[[self class] preferredContentTextSize]];
        self.titleLabel.numberOfLines = 0;
        [self.cellView addSubview:self.titleLabel];
        
        
        self.displayImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        self.displayImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.displayImageView.backgroundColor = [UIColor clearColor];
        [self.cellView addSubview:self.displayImageView];
        
        self.imageMaskView = [[SSThemedView alloc] initWithFrame:self.displayImageView.bounds];
        self.imageMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageMaskView.userInteractionEnabled = NO;
        self.imageMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.imageMaskView.hidden = YES;
        [self.displayImageView addSubview:self.imageMaskView];
        
        self.bottomView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
        [self.cellView addSubview:self.bottomView];
        
        {
            
            self.iconView = [[TTImageView alloc] init];;
            [self.bottomView addSubview:self.iconView];
            
            self.promoteLabel = [[UILabel alloc] init];
            self.promoteLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
            self.promoteLabel.textAlignment = NSTextAlignmentCenter;
            //self.promoteLabel.textColorThemeKey = kColorText3;
            self.promoteLabel.backgroundColor = [UIColor clearColor];
            [self.bottomView addSubview:self.promoteLabel];
            
            self.sourceLabel = [[SSThemedLabel alloc] init];
            self.sourceLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
            self.sourceLabel.textColorThemeKey = kColorText3;
            self.sourceLabel.backgroundColor = [UIColor clearColor];
            [self.bottomView addSubview:self.sourceLabel];
            
            self.commentLabel = [[SSThemedLabel alloc] init];
            self.commentLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
            self.commentLabel.textColorThemeKey = kColorText3;
            self.commentLabel.backgroundColor = [UIColor clearColor];
            [self.bottomView addSubview:self.commentLabel];
            
            self.timeLabel = [[SSThemedLabel alloc] init];
            self.timeLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
            self.timeLabel.textColorThemeKey = kColorText3;
            self.timeLabel.backgroundColor = [UIColor clearColor];
            [self.bottomView addSubview:self.timeLabel];
            
            self.accessoryButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(5, 0, 30, 25)];
            self.accessoryButton.imageName = @"add_textpage";
            self.accessoryButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 13, 13);
            [self.accessoryButton addTarget:self action:@selector(accessoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomView addSubview:self.accessoryButton];
        }
        
        self.separatorView = [[SSThemedView alloc] init];
        self.separatorView.backgroundColors = SSThemedColors(@"dddddd", @"363636");
        [self.cellView addSubview:self.separatorView];
        
        SSThemedView * selectedBackgroundView = [[SSThemedView alloc] initWithFrame:self.cellView.bounds];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectedBackgroundView.backgroundColors = SSThemedColors(@"eeeeee", @"303030");
        [self.cellView addSubview:selectedBackgroundView];
        [self.cellView sendSubviewToBack:selectedBackgroundView];
        [self.cellView sendSubviewToBack:self.backgroundColorView];
        _selectedView = selectedBackgroundView;

        [self themeChanged:nil];
    }
    return self;
}

- (id)cellData
{
    return self.orderedData;
}

//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    self.orderedData = nil;
//}

- (void)refreshWithData:(id)data {
    [super refreshWithData:data];
    self.orderedData = data;
    
    self.promoteLabel.text = nil;
    
    TTImageInfosModel *iconModel = nil;
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        iconModel = self.orderedData.article.listSourceIconModel;
    } else {
        iconModel = self.orderedData.article.listSourceIconNightModel;
    }
    
    if (iconModel) {
        [self.iconView setImageWithModel:iconModel];
        if (iconModel.width > 0 && iconModel.height > 0) {
            CGFloat w = (CGFloat)(kCellTypeLabelHeight * iconModel.width)/iconModel.height;
            self.iconView.size = CGSizeMake(ceilf(w), kCellTypeLabelHeight);
        } else {
            self.iconView.size = CGSizeMake(kCellTypeLabelWidth, kCellTypeLabelHeight);
        }
        self.promoteLabel.hidden = YES;
        self.iconView.hidden = NO;
    } else {
        self.iconView.hidden = YES;
        self.promoteLabel.hidden = NO;
        [ExploreCellHelper layoutTypeLabel:self.promoteLabel withOrderedData:self.orderedData];
    }
    
    /// 评论
    [self updateCommentCountLabel];
    
    double time = self.orderedData.behotTime;
    NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
//    
//    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
//    NSString *publishTime =  [NSString stringWithFormat:@"%@", midnightInterval > 0 ?
//                              [TTBusinessManager customtimeStringSince1970:time midnightInterval:midnightInterval] :
//                              [TTBusinessManager customtimeStringSince1970:time]];
    self.timeLabel.text = publishTime;
    
    if ([self.orderedData nextCellHasTopPadding]) {
        if (!self.separatorView.hidden) {
            self.separatorView.hidden = YES;
            [self setNeedsDisplay];
        }
    } else {
        if (self.separatorView.hidden) {
            self.separatorView.hidden = NO;
            [self setNeedsDisplay];
        }
    }
}


- (void)updateCommentCountLabel {
    NSString *str = nil;
    if (!isEmptyString(self.orderedData.originalData.infoDesc)) {
        str = self.orderedData.originalData.infoDesc;
    } else {
        int count = self.orderedData.originalData.commentCount;
        if (count > 0) {
            count = MAX(0, count);
            str = [NSString stringWithFormat:@"%@%@", [TTBusinessManager formatCommentCount:count], NSLocalizedString(@"评论", nil)];
        }
    }
    self.commentLabel.text = str;
}


- (void) refreshUI {
    [super refreshUI];
    self.titleLabel.font = [UIFont systemFontOfSize:[[self class] preferredContentTextSize]];
    [self.sourceLabel sizeToFit];
    [self.commentLabel sizeToFit];
    [self.timeLabel sizeToFit];
    
    CGFloat left = 0, margin = 6;
    if (!self.iconView.hidden) {
        // icon图标
        self.iconView.origin = CGPointMake(15, 0);
        left = self.iconView.right + margin;
        
    } else {
        if (self.promoteLabel.text.length == 0) {
            self.promoteLabel.hidden = YES;
            left = 15;
        } else {
            self.promoteLabel.hidden = NO;
            self.promoteLabel.left = 15;
            left = self.promoteLabel.right + margin;
        }
    }
    if ([self.orderedData isShowSourceLabel] && self.sourceLabel.text.length != 0) {
        self.sourceLabel.hidden = NO;
        self.sourceLabel.origin = CGPointMake(left, 0);
        left = self.sourceLabel.right + margin;
    } else {
        self.sourceLabel.hidden = YES;
    }
    if ([self.orderedData isShowCommentCountLabel] && self.commentLabel.text.length != 0) {
        self.commentLabel.hidden = NO;
        self.commentLabel.origin = CGPointMake(left, 0);
        left = self.commentLabel.right + margin;
    } else {
        self.commentLabel.hidden = YES;
    }
    if ([self.orderedData isShowTimeLabel] && self.timeLabel.text.length != 0) {
        self.timeLabel.hidden = NO;
        self.timeLabel.origin = CGPointMake(left, 0);
        left = self.timeLabel.right + margin;
    } else {
        self.timeLabel.hidden = YES;
    }
    
    self.accessoryButton.origin = CGPointMake(self.bottomView.width - 32, 0);
    self.separatorView.frame = CGRectMake(kCellLeftPadding, CGRectGetHeight(self.cellView.frame) - [TTDeviceHelper ssOnePixel], self.cellView.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
}

+ (CGFloat) preferredContentTextSize {
    return kCellTitleLabelFontSize;
}

- (void) themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.imageMaskView.hidden = [[TTThemeManager sharedInstance_tt] currentThemeMode] != TTThemeModeNight;
}

#pragma mark -- not interest
- (void) accessoryButtonClicked:(id)sender {
    UIButton *accessoryButton = (UIButton *)sender;
    CGPoint p = accessoryButton.origin;
    p.x += 8;
    p.y += 6;

    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = p;
    [dislikeView showAtPoint:point
                    fromView:accessoryButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self unInterestItemClicked:view];
             }];
}

- (void)unInterestItemClicked:(TTFeedDislikeView *)dislikeView {
    [[SSItemActionSender shareManager] sendADItemAction:SSItemActionTypeADDislike adID:nil finishBlock:^(NSDictionary *result, NSError *error) {
        
    }];
    
    if (!self.orderedData) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    
    NSArray *filterWords = [dislikeView selectedWords];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    
    if ([self.orderedData.adModel.type isEqualToString:@"call"]) {
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"dislike" eventName:@"feed_call"];        
    }
    
    //最后发通知 提前发会导致orderData 数据fault
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];

}


#pragma mark - TouchesEvent

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _selectedView.hidden = !highlighted;
}
- (void) fontSizeChanged {
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[[self class] preferredContentTextSize]];
}

- (void) setReadPersistAD:(BOOL)readPersistAD {
    if (!readPersistAD) {
        self.titleLabel.textColors = [TTUISettingHelper cellViewTitleColors];
    } else {
        self.titleLabel.textColors = SSThemedColors(@"999999", @"707070");
    }
    _readPersistAD = readPersistAD;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel{
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    [self setReadPersistAD:YES];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    [super didSelectWithContext:context];
    [self setReadPersistAD:YES];
}

@end

UIEdgeInsets const ExploreADCellContentInset = {15, 16, 16, 15};

@implementation ExploreBaseADCell (TTAdCellLayoutInfo)

- (nonnull NSDictionary *)adCellLayoutInfo {
    NSMutableDictionary *layoutInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    CGRect dislikeFrame = self.accessoryButton.bounds;
    dislikeFrame = [self convertRect:dislikeFrame fromView:self.accessoryButton];
    [layoutInfo setValue:@(CGRectGetMinX(dislikeFrame)) forKey:@"lu_x"];
    [layoutInfo setValue:@(CGRectGetMinY(dislikeFrame)) forKey:@"lu_y"];
    [layoutInfo setValue:@(CGRectGetMaxX(dislikeFrame)) forKey:@"rd_x"];
    [layoutInfo setValue:@(CGRectGetMaxY(dislikeFrame)) forKey:@"rd_y"];
    [layoutInfo setValue:@(CGRectGetWidth(self.frame)) forKey:@"width"];
    [layoutInfo setValue:@(CGRectGetHeight(self.frame)) forKey:@"height"];
    return layoutInfo;
}

@end
