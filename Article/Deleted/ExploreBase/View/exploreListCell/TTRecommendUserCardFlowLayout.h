//
//  TTRecommendUserCardFlowLayout.h
//  Article
//
//  Created by lipeilun on 2017/9/4.
//
//

#import <UIKit/UIKit.h>


@interface TTRecommendUserCardLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong) CABasicAnimation *transformAnimation;
@end

@interface TTRecommendUserCardFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger index;
@end
