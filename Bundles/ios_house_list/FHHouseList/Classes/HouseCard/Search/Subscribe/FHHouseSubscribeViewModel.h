//
//  FHHouseSubscribeViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSubscribeViewModel : FHHouseNewComponentViewModel

- (void)requestAddSubScribe:(NSString *)text;

- (void)requestDeleteSubScribe:(NSString *)subscribeId;

@end

NS_ASSUME_NONNULL_END
