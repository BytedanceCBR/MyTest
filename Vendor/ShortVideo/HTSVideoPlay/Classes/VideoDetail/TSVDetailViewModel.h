//
//  TSVDetailViewModel.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 19/09/2017.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@class TSVControlOverlayViewModel;

@interface TSVDetailViewModel : NSObject

@property (nonatomic, nullable, strong) id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;

- (void)didShareToActivityNamed:(NSString *_Nonnull)activityName;

- (void)willShowLoadingCell;

@end
