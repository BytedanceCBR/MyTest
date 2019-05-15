//
//  TSVOriginalData.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <TTPlatformUIModel/ExploreOriginalData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSVOriginalData : ExploreOriginalData

@property (nonatomic, copy, nullable) NSDictionary *originalDict;
@property (nonatomic, strong, nullable) id model;

@end

NS_ASSUME_NONNULL_END
