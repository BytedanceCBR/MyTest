//
//  ExploreOrderedActionCell.m
//  Article
//
//  Created by SunJiangting on 14-9-11.
//
//

#import "ExploreOrderedActionCell.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ExploreCellViewBase.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTImageView.h"
#import "TTLabelTextHelper.h"
#import "TTLayOutCellViewBase.h"
#import <TTServiceKit/TTServiceCenter.h>

const CGSize ExploreOrderedActionCellDefaultSize = {320, 50};

@interface ExploreOrderedActionCell ()

@end

@implementation ExploreOrderedActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    CGRect frame = CGRectZero;
    frame.size = ExploreOrderedActionCellDefaultSize;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
        self.contentView.frame = frame;
        
        self.titleLabel.numberOfLines = 2;
        
        self.nameLabel = [[SSThemedLabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.cellView addSubview:self.nameLabel];
        
        self.actionButton = [[ExploreActionButton alloc] initWithFrame:CGRectZero];
        [self.actionButton setTitle:@"立即下载" forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(downloadButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [self.cellView addSubview:self.actionButton];
    }
    return self;
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    NSString *promote = @"广告";
    if ([data displayLabel].length > 0) {
        promote = [data displayLabel];
    }
    
    id<TTAdFeedModel> adModel = data.adModel;
    self.actionButton.actionModel = data;
    
    self.promoteLabel.text = promote;
    self.sourceLabel.text = adModel.source;
    TTImageInfosModel *imageModel = adModel.imageModel;
    if (imageModel == nil) {
        imageModel = data.article.listMiddleImageModel;
    }
    [self.displayImageView setImageWithModel:imageModel placeholderImage:nil];
    
    if ([adModel.type isEqualToString:@"app"]) {
        self.nameLabel.textColorThemeKey = kColorText3;
        self.nameLabel.numberOfLines = 1;
        self.nameLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.nameLabel.text = adModel.appName;
        self.titleLabel.text = adModel.descInfo;
        [self.actionButton setIconImageNamed:nil];
    } else {
        self.nameLabel.font = [UIFont systemFontOfSize:12.];
        self.nameLabel.textColorThemeKey = kColorText3;
        self.nameLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.text = adModel.descInfo;
        self.titleLabel.text = adModel.title;
    }
    
    if ([adModel.type isEqualToString:@"action"]) {
        [self.actionButton setIconImageNamed:@"callicon_ad_textpage"];
    }
    
    [super refreshWithData:data];
}

- (void)refreshUI {
    self.bottomView.frame = CGRectMake(0, self.height - 27, self.cellView.width, 27);
    [super refreshUI];
}

- (void)downloadButtonActionFired:(id) sender {
    [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click" eventName:@"embeded_ad" extra:@"2" clickTrackUrl:YES];
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    if (adModel.adType == ExploreActionTypeAction || adModel.adType == ExploreActionTypeLocationAction) {
        if (adModel.adType == ExploreActionTypeLocationAction) {
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"lbs_ad" extra:@"2" clickTrackUrl:NO];
        } else {
           [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"click_call" eventName:@"feed_call" extra:@"2" clickTrackUrl:NO];
        }
        
        [self listenCall:adModel];
    }
    [self.actionButton actionButtonClicked:sender showAlert:!(sender)];
}

//监听电话状态
- (void)listenCall:(id<TTAdFeedModel>)adModel
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adModel.ad_id forKey:@"ad_id"];
    [dict setValue:adModel.log_extra forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:adModel.dialActionType forKey:@"dailActionType"];
    if (adModel.adType == ExploreActionTypeAction) {
        [dict setValue:@"feed_call" forKey:@"position"];
    }
    else if (adModel.adType == ExploreActionTypeLocationAction){
        [dict setValue:@"lbs_ad" forKey:@"position"];
    }
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    [super didSelectWithContext:context];
    
    if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if ([self.actionButton isKindOfClass:[ExploreActionButton class]]) {
            [self.actionButton actionButtonClicked:nil showAlert:YES];
        }
    }
}

@end

const CGSize ExploreOrderedActionSmallCellDefaultSize = {320, 87};

@implementation ExploreOrderedActionSmallCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.displayImageView.clipsToBounds = YES;
        self.actionButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return self;
}

- (void) refreshWithData:(ExploreOrderedData *) data {
    [super refreshWithData:data];
}

- (void) refreshUI {
    [super refreshUI];
    /// layout
    CGFloat contentRightMargin = 23;
    CGFloat contentWidth = self.cellView.width - ExploreADCellContentInset.left - ExploreADCellContentInset.right - contentRightMargin - 72;
    CGFloat contentRight = self.cellView.width - ExploreADCellContentInset.right - contentRightMargin - 72;
    
    self.displayImageView.frame = CGRectMake(contentRight + contentRightMargin, ExploreADCellContentInset.top, 72, 72);
    
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    
    self.titleLabel.frame = CGRectMake(ExploreADCellContentInset.left, ExploreADCellContentInset.top, contentWidth, 9999);
    [self.titleLabel sizeToFit];
    self.titleLabel.width = contentWidth;

    CGFloat topMargin = ExploreADCellContentInset.top, imageTopMargin = ExploreADCellContentInset.top, nameTitleMargin = 6;
    
    BOOL actionType = [adModel.type isEqualToString:@"action"];
    if (actionType) {
        // Action
        CGFloat infoHeight = self.titleLabel.height + nameTitleMargin + 24;
        if (infoHeight < 72) {
            topMargin = ExploreADCellContentInset.top + (72 - infoHeight) / 2;
            self.nameLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        } else {
            imageTopMargin = (infoHeight - 72) / 2 + ExploreADCellContentInset.top;
            self.nameLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        }
        self.displayImageView.top = imageTopMargin;
        self.titleLabel.top = topMargin;
        self.actionButton.frame = CGRectMake(contentRight - 76, self.titleLabel.bottom + nameTitleMargin, 76, 28);
        self.nameLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + nameTitleMargin, self.actionButton.left - self.titleLabel.left - 15, 28);
    } else {
        /// 应用下载
        CGFloat nameTitleMargin = 6, nameRateMargin = 2;
        CGFloat infoHeight = self.titleLabel.height + nameTitleMargin + 30 + nameRateMargin;
        if (infoHeight < 72) {
            topMargin = ExploreADCellContentInset.top + (72 - infoHeight) / 2;
        } else {
            imageTopMargin = ExploreADCellContentInset.top + (infoHeight - 72) / 2;
        }
        self.titleLabel.top = topMargin;
        self.displayImageView.top = imageTopMargin;
        self.actionButton.frame = CGRectMake(contentRight - 66, self.titleLabel.bottom + nameTitleMargin, 66, 28);
        
        self.nameLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + nameTitleMargin, self.actionButton.left - self.titleLabel.left - 15, 15);
        self.nameLabel.centerY = self.actionButton.centerY;
    }
}

+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType {
    CGFloat basedWidth = (width - (ExploreADCellContentInset.left + ExploreADCellContentInset.right + 95));
    NSString *title = [TTLayOutCellDataHelper getTitleStyle1WithOrderedData:data];
    CGFloat height = [TTLabelTextHelper heightOfText:title fontSize:[self preferredContentTextSize] forWidth:basedWidth constraintToMaxNumberOfLines:2];
    height += ExploreADCellContentInset.top + ExploreADCellContentInset.bottom + 22;
    height += 29;
    return MAX(height, 120);
//    return MIN(MAX(122, height), 150);
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    
    if ([self.actionButton isKindOfClass:[ExploreActionButton class]]) {
        [self.actionButton actionButtonClicked:nil showAlert:YES];
    }
    
    if([self.cellView isKindOfClass:[TTLayOutCellViewBase class]]){
        TTLayOutCellViewBase *cellView = (TTLayOutCellViewBase *)self.cellView;
        [cellView.actionButton actionButtonClicked:nil showAlert:YES];
    }
}

@end
