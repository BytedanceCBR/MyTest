//
//  FHHomeRenderFlow.h
//  FHHouseHome
//
//  Created by bytedance on 2020/11/17.
//

#import <Foundation/Foundation.h>
#import "FHHomeHouseModel.h"
#import "FHHomeItemViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeRequestFlow : NSObject

- (void)traceSendRequest;

- (void)traceReceiveRequest;

- (void)traceBeginParseData;

- (void)traceEndParseData;

@end

@interface FHHomeHouseModel(RenderFlow)
@property (nonatomic, strong) FHHomeRequestFlow *requestFlow;
@end

@interface FHHomeItemRenderFlow : NSObject

- (instancetype)initWithHouseType:(NSInteger)houseType;

- (void)traceInit;

- (void)traceViewDidLoad;

- (void)traceSendRequest;

- (void)traceReceiveResponse:(FHHomeRequestFlow *)requestFlow;

- (void)traceReloadData;

- (void)submit;

- (void)submitWithError:(NSError *)error;

@end


@interface FHHomeItemViewController(RenderFlow)
@property (nonatomic, strong) FHHomeItemRenderFlow *renderFlow;
@end

@interface FHHomeRenderFlow : NSObject

+ (instancetype)sharedInstance;

- (void)traceHomeMainInit;

- (void)traceHomeMainViewDidLoad;

- (void)traceHomeInit;

- (void)traceHomeViewDidLoad;

- (FHHomeItemRenderFlow *)traceHomeItemWithHouseType:(NSInteger)houseType;

@end

NS_ASSUME_NONNULL_END
