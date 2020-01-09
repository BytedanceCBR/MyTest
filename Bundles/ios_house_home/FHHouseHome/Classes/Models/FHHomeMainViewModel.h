//
//  FHHomeMainViewModel.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import <Foundation/Foundation.h>

#define kFHHomeMainCellTypeHouse 0
#define kFHHomeMainCellTypeFeed 1

typedef NS_ENUM (NSInteger , FHHomeMainTraceType){
    FHHomeMainTraceTypeHouse = 1, //房源
    FHHomeMainTraceTypeFeed = 2  //发现
};

typedef NS_ENUM (NSInteger , FHHomeMainTraceEnterType){
    FHHomeMainTraceEnterTypeClick = 1, //点击
    FHHomeMainTraceEnterTypeFlip = 2  //滑动
};


NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainViewModel : NSObject

@property(nonatomic , assign) NSInteger currentIndex;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController;

- (void)sendEnterCategory:(FHHomeMainTraceType)traceType enterType:(FHHomeMainTraceEnterType)enterType;

- (void)sendStayCategory:(FHHomeMainTraceType)traceType enterType:(FHHomeMainTraceEnterType)enterType;

@end

NS_ASSUME_NONNULL_END
