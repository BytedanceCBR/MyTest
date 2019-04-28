//
//  TSVActivityEntranceCollectionViewCellViewModel.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <Foundation/Foundation.h>
#import "TSVActivityEntranceModel.h"
#import "TTImageInfosModel.h"

@interface TSVActivityEntranceCollectionViewCellViewModel : NSObject

- (instancetype)initWithModel:(TSVActivityEntranceModel *)model;

@property (nonatomic, strong, readonly) TTImageInfosModel *coverImageModel;
@property (nonatomic, copy, readonly) NSString *activityPromotionText;
@property (nonatomic, copy, readonly) NSString *activityNameText;
@property (nonatomic, copy, readonly) NSString *participateCountText;
@property (nonatomic, assign) TSVActivityEntranceStyle style;

@end
