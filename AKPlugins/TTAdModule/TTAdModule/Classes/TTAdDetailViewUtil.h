//
//  TTAdDetailViewUtil.h
//  Article
//
//  Created by carl on 2017/6/22.
//
//

#import <Foundation/Foundation.h>

@class ArticleDetailADModel;

@interface TTAdDetailViewUtil : NSObject
+ (CGFloat)imageFitHeight:(ArticleDetailADModel *)adModel width:(CGFloat) width;
+ (CGSize)imgSizeForViewWidth:(CGFloat)width;
@end


