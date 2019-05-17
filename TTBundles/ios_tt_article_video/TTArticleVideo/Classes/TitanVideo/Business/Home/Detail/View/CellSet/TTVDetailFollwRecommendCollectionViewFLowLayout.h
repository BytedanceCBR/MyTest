//
//  TTVDetailFollwRecommendCollectionViewFLowLayout.h
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import <UIKit/UIKit.h>

@interface TTVDetailFollwRecommendCollectionViewFLowLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong) CABasicAnimation *transformAnimation;
@end

@interface TTVDetailFollwRecommendCollectionViewFLowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger index;

@end
