//
//  TTVDetailStateModel.m
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import "TTVDetailStateModel.h"
#import "TTVVideoDetailStayPageTracker.h"
#import "TTDetailModel.h"
#import "TTDetailModel+videoArticleProtocol.h"
#import "TTVDetailPlayControl.h"

@interface TTVDetailStateModel()
{
    __weak TTDetailModel *_detailModel;
}
@end

@implementation TTVDetailStateModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _entity = [[TTVDetailContentEntity alloc] init];
    }
    return self;
}

- (float)currentStayDuration
{
    TTVVideoDetailStayPageTracker *tracker = [self.whiteBoard valueForKey:@"tracker"];
    return [tracker currentStayDuration];
}

- (NSNumber *)detailReadPCT
{
    TTVDetailPlayControl *playControl = [self.whiteBoard valueForKey:@"playControl"];
    float readPct = [playControl watchPercent];
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    return @(percent);
}

@end

@implementation TTVDetailStateModel (Data)

- (NSString *)ttv_itemId
{
    return _detailModel.protocoledArticle.itemID;
}

- (NSString *)ttv_groupId
{
    return _detailModel.protocoledArticle.groupModel.groupID;
}

- (NSNumber *)ttv_aggrType
{
    return _detailModel.protocoledArticle.aggrType;
}

- (NSNumber *)ttv_adid
{
    NSNumber *adID = nil;
    if (self.fromType == TTVVideoDetailViewFromTypeCategory) {
        adID = _detailModel.articleExtraInfo.adID;
    } else if (self.fromType == TTVVideoDetailViewFromTypeRelated) {
        adID = _detailModel.protocoledArticle.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
    }
    if (!adID) {
        adID = _detailModel.adID;
    }
    return adID;
}

- (void)setDetailModel:(id)detailModel
{
    if (detailModel != _detailModel) {
        _detailModel = detailModel;
    }
}

- (NSString *)ttv_fromGid
{
    if (_detailModel.relateReadFromGID) {
        return [NSString stringWithFormat:@"%@",_detailModel.relateReadFromGID];
    }

    return nil;
}
@end

