//
//  TTCameraDetectionDelegate.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <Foundation/Foundation.h>

@protocol TTCameraDetectionDelegate <NSObject>

@optional
/** 使用配置的CIDetector识别，对Features数组判空来判断是否成功识别。并且注意CIFeature的bounds并未转换，皆为LandscapeRight，UIImage已经转换到拍摄用的orientation，建议通过UIImage的orientation来判断方向 */
- (void)didDetectSuccess:(BOOL)success
            withFeatures:(NSArray<CIFeature *> *)features
                 ofImage:(UIImage *)image;

@end
