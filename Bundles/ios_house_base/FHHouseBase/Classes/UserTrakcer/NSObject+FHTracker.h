//
//  NSObject+FHTracker.h
//  FHHouseBase
//
//  Created by bytedance on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "FHTracerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject(FHTracker)

@property (nonatomic, copy) NSString *fh_pageType;
@property (nonatomic, copy) NSString *fh_originFrom;


@property (nonatomic, strong) FHTracerModel *fh_trackModel;

@end

NS_ASSUME_NONNULL_END
