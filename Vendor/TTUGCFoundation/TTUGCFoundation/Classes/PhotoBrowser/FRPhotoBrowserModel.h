//
//  FRPhotoBrowserModel.h
//  Article
//
//  Created by 王霖 on 17/1/19.
//
//

#import <Foundation/Foundation.h>

@class FRImageInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface FRPhotoBrowserModel : NSObject

@property (nonatomic, strong, nonnull) FRImageInfoModel * imageInfosModel;
@property (nonatomic, strong, nullable) UIImage * placeholderImage;
@property (nonatomic, strong, nullable) NSValue * originalFrame;
@property (nonatomic, strong, nullable) NSValue * animateFrame;

- (instancetype)initWithImageInfosModel:(FRImageInfoModel *)imageInfosModel
                       placeholderImage:(nullable UIImage *)placeholderImage
                          originalFrame:(nullable NSValue * )originalFrame;

@end

NS_ASSUME_NONNULL_END
