//
//  FHIMShareActivity.h
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import <Foundation/Foundation.h>
#import "TTShareManager.h"
#import "TTActivityContentItemProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHIMShareActivity : NSObject<TTActivityProtocol>
@property (nonatomic, strong) id<TTActivityContentItemProtocol> contentItem;
@property (nonatomic, strong) NSDictionary *extraInfo;
@end

NS_ASSUME_NONNULL_END
