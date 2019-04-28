//
//  TSVWaterfallCollectionViewCellProtocol.h
//  Article
//
//  Created by 邱鑫玥 on 2017/9/15.
//

#import <Foundation/Foundation.h>

@class ExploreOrderedData;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TTHTSWaterCollectionCellDislikeBlock)();

@protocol TSVWaterfallCollectionViewCellProtocol <NSObject>

@property (nonatomic, copy, nullable) TTHTSWaterCollectionCellDislikeBlock dislikeBlock;

- (nullable ExploreOrderedData *)cellData;

- (void)refreshWithData:(ExploreOrderedData *)data;

@end

NS_ASSUME_NONNULL_END
