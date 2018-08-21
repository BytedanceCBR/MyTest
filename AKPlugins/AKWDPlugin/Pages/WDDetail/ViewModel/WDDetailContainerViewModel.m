//
//  WDDetailContainerViewModel.m
//  Article
//
//  Created by 延晋 张 on 16/6/12.
//
//

#import "WDDetailContainerViewModel.h"
#import "WDDetailModel.h"
#import "WDSettingHelper.h"
#import "TTRoute.h"
#import "WDFetchAnswerContentHelper.h"

@interface WDDetailContainerViewModel ()

@property (nonatomic, strong, nullable) WDFetchAnswerContentHelper *fetchContentHelper;

@property (nonatomic, assign, readwrite) BOOL isNewVersion;

@end

@implementation WDDetailContainerViewModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        
        _isNewVersion = ([[WDSettingHelper sharedInstance_tt] wdAnswerDetailShowSlideType] != AnswerDetailShowSlideTypeNoSlide);
        if (!_isNewVersion) {
            _fetchContentHelper = [[WDFetchAnswerContentHelper alloc] initWithRouteParamObj:paramObj];
            _detailModel = _fetchContentHelper.detailModel;
        }
    }
    return self;
}

- (nullable NSString *)classNameForSpecificDetailViewController
{
    if (self.isNewVersion) {
        return @"WDDetailSlideNewViewController";
    }
    return @"WDDetailViewController";
}

- (void)fetchContentFromRemoteIfNeededWithComplete:(nullable WDFetchRemoteContentBlock)block {
    [self.fetchContentHelper fetchContentFromRemoteIfNeededWithComplete:block];
}

@end
