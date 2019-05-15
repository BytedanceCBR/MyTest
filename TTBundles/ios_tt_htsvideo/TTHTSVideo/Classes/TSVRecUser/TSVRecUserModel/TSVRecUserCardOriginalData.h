//
//  TSVRecUserCardOriginalData.h
//  Article
//
//  Created by 王双华 on 2017/9/25.
//

#import "ExploreOriginalData.h"
#import "TSVRecUserCardModel.h"

@interface TSVRecUserCardOriginalData : ExploreOriginalData

@property (nonatomic, copy, nullable) NSDictionary *originalDict;
@property (nonatomic, strong, nullable) TSVRecUserCardModel *cardModel;

@end
