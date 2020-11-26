//
//  FHHouseNewComponentViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNewComponentViewModelObserver <NSObject>

@end


@protocol FHHouseNewComponentViewModelProtocol <NSObject>

@property (nonatomic, assign) CGFloat cachedHeight;
@property (nonatomic, assign) BOOL needCalculateHeight;

- (void)setNeedCalculateHeight;

- (void)addObserver:(id<FHHouseNewComponentViewModelObserver>)observer;

- (void)removeObserver:(id<FHHouseNewComponentViewModelObserver>)observer;

- (BOOL)isValid;

@end


@interface FHHouseNewComponentViewModel : NSObject<FHHouseNewComponentViewModelProtocol> {
    NSHashTable *_observers;
}

@end

NS_ASSUME_NONNULL_END
