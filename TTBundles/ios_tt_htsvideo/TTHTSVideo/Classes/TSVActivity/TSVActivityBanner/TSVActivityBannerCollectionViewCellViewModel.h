//
//  TSVActivityBannerCollectionViewCellViewModel.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <Foundation/Foundation.h>
#import "TSVActivityBannerModel.h"
#import "TTImageInfosModel.h"

@interface TSVActivityBannerCollectionViewCellViewModel : NSObject

- (instancetype)initWithModel:(TSVActivityBannerModel *)model;

@property (nonatomic, strong, readonly) TTImageInfosModel *coverImageModel;

@end
