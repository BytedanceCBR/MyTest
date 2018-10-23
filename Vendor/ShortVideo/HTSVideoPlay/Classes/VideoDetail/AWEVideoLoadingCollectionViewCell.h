//
//  AWEVideoLoadingCollectionViewCell.h
//  Pods
//
//  Created by Zuyang Kou on 29/06/2017.
//
//

#import <UIKit/UIKit.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@interface AWEVideoLoadingCollectionViewCell : UICollectionViewCell

@property (nonatomic, nullable, strong) id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager;
@property (nonatomic, nullable, copy) void (^retryBlock)();
@property (nonatomic, copy, nullable) void (^closeButtonDidClick)();

@end
