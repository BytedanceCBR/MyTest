//
//  FHIMShareItem.h
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"
@class FHDetailImShareInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHIMShareItem : NSObject<TTActivityContentItemProtocol>
@property (nonatomic, strong) FHDetailImShareInfoModel* imShareInfo;
@property (nonatomic, strong) NSDictionary* tracer;
@end

NS_ASSUME_NONNULL_END
