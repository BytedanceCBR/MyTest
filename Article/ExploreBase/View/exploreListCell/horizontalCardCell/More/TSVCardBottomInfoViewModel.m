//
//  TSVCardBottomInfoViewModel.m
//  Article
//
//  Created by 邱鑫玥 on 2017/10/11.
//

#import "TSVCardBottomInfoViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "HorizontalCard.h"
#import "AWEVideoConstants.h"
#import "TSVShortVideoOriginalData.h"
#import "TSVDownloadManager.h"
#import <TTRoute/TTRoute.h>
#import "TTHorizontalCardCell.h"

#define kBottomInfoViewHeight       40

static NSString * const kTSVOpenTabHost = @"ugc_video_tab";
static NSString * const kTSVOpenDetailHost = @"ugc_video_recommend";
static NSString * const kTSVOpenCategoryHost = @"ugc_video_category";
static NSString * const kTSVDownloadHost = @"ugc_video_download";

@interface TSVCardBottomInfoViewModel()

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) HorizontalCard *horizontalCard;

@end

@implementation TSVCardBottomInfoViewModel

#pragma mark -

+ (BOOL)shouldShowBottomInfoViewForData:(HorizontalCard *)data collectionViewCellStyle:(TTHorizontalCardContentCellStyle)style
{
    HorizontalCardMoreModel *moreModel = data.showMoreModel;
    
    if (isEmptyString(moreModel.title) || isEmptyString(moreModel.urlString)) {
        return NO;
    }
    
    NSURL *url = [TTStringHelper URLWithURLString:moreModel.urlString];
    TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    
    NSString *host = params.host;
    
    TSVCardBottomInfoContentStyle contentStyle = [self bottomInfoContentStyleForData:data];
    
    if (contentStyle == TSVCardBottomInfoContentStyleMore && [host isEqualToString:kTSVDownloadHost]) {
        host = params.queryParams[@"download_show_more_url"];
    }
    
    if (isEmptyString(host)) {
        return NO;
    }
    
    if ([host isEqualToString:kTSVOpenDetailHost] && ![SSCommonLogic shortVideoDetailInfiniteScrollEnable]) {
        [[TTMonitor shareManager] trackService:@"ugc_video_card_should_not_show_more" attributes:nil];
        return NO;
    } else if ([host isEqualToString:kTSVOpenCategoryHost] && ![TTShortVideoHelper canOpenShortVideoCategory]) {
        return NO;
    }
    
    if (style == TTHorizontalCardContentCellStyle1 || style == TTHorizontalCardContentCellStyle2) {
        return NO;
    }
    
    return YES;
}

+ (CGFloat)heightForData:(HorizontalCard *)data
{
    return kBottomInfoViewHeight;
}

+ (TSVCardBottomInfoViewStyle)bottomInfoViewStyleForData:(HorizontalCard *)data
{
    if ([data isHorizontalScrollEnabled]) {
        return TSVCardBottomInfoViewStyleHorizontalScroll;
    } else {
        return TSVCardBottomInfoViewStyleDoublePicture;
    }
}

+ (TSVCardBottomInfoContentStyle)bottomInfoContentStyleForData:(HorizontalCard *)data
{
    HorizontalCardMoreModel *moreModel = data.showMoreModel;
    
    NSURL *url = [TTStringHelper URLWithURLString:moreModel.urlString];
    TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    
    if ([params.host isEqualToString:kTSVDownloadHost]) {
        NSString *groupSource = [TTShortVideoHelper groupSourceForDownloadWithHorizontalCard:data];
        
        if ([TSVDownloadManager shouldDownloadAppForGroupSource:groupSource]) {
            return TSVCardBottomInfoContentStyleDownload;
        }
    }
    
    return TSVCardBottomInfoContentStyleMore;
}

#pragma mark -

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData
{
    if (self = [super init]) {
        self.orderedData = orderedData;
        self.horizontalCard = orderedData.horizontalCard;
        self.contentStyle = [[self class] bottomInfoContentStyleForData:self.horizontalCard];
    }
    return self;
}

- (NSString *)title
{
    HorizontalCardMoreModel *moreModel = self.horizontalCard.showMoreModel;
    
    if (self.contentStyle == TSVCardBottomInfoContentStyleDownload) {
        NSURL *url = [TTStringHelper URLWithURLString:moreModel.urlString];
        TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        NSString *groupSource = [TTShortVideoHelper groupSourceForDownloadWithHorizontalCard:self.horizontalCard];

        if ([groupSource isEqualToString:AwemeGroupSource]) {
            return params.queryParams[@"awe_download_title"];
        } else if ([groupSource isEqualToString:HotsoonGroupSource]) {
            return params.queryParams[@"huoshan_download_title"];
        } else {
            NSAssert(NO, @"Unknown Group Source");
            return nil;
        }
    } else {
        if (isEmptyString(moreModel.title)) {
            return @"更多小视频";
        } else {
            return moreModel.title;
        }
    }
}

- (NSString *)imageName
{
    if (self.contentStyle == TSVCardBottomInfoContentStyleDownload) {
        return @"tsv_feed_download_arrow";
    } else {
        return @"horizontal_more_arrow";
    }
}

- (ExploreOrderedData *)data
{
    return self.orderedData;
}

- (TTHorizontalCardContentCellStyle)cellStyle
{
    ExploreOrderedData *itemData = [self.horizontalCard.originalCardItems firstObject];
    return [TTShortVideoHelper contentCellStyleWithItemData:itemData];
}

- (TSVCardBottomInfoViewStyle)bottomInfoViewStyle
{
    return [[self class] bottomInfoViewStyleForData:self.horizontalCard];
}

- (void)handleClick
{
    [TTShortVideoHelper handleClickWithData:self.orderedData];
}
@end
