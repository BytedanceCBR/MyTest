//
//  WDDetailContainerViewModel.h
//  Article
//
//  Created by 延晋 张 on 16/6/12.
//
//

#import <Foundation/Foundation.h>
#import "WDDetailModel.h"
#import "TTRoute.h"

typedef NS_ENUM(NSUInteger, WDFetchResultType)
{
    WDFetchResultTypeFailed = 0,
    WDFetchResultTypeDone,
    WDFetchResultTypeEndLoading,
    WDFetchResultTypeNoNetworkConnect,
};
typedef void(^WDFetchRemoteContentBlock)(WDFetchResultType type);

@class WDDetailModel;

@interface WDDetailContainerViewModel : NSObject <TTRouteInitializeProtocol>

@property (nonatomic, strong, nullable) WDDetailModel * detailModel;

@property (nonatomic, assign, readonly) BOOL isNewVersion;

- (nullable NSString *)classNameForSpecificDetailViewController;

- (void)fetchContentFromRemoteIfNeededWithComplete:(nullable WDFetchRemoteContentBlock)block;

@end
