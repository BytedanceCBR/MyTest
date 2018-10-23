//
//  WDDetailNatantLayout.h
//  Article
//
//  Created by Ray on 16/5/9.
//
//

#import "NSObject+TTAdditions.h"

@interface WDDetailNatantLayout : NSObject<Singleton>

@property (nonatomic, assign, readonly) CGFloat leftMargin;
@property (nonatomic, assign, readonly) CGFloat rightMargin;
@property (nonatomic, assign, readonly) CGFloat topMargin;
@property (nonatomic, assign, readonly) CGFloat bottomMargin;
@property (nonatomic, assign, readonly) CGFloat spaceBeweenNantants;
@property (nonatomic, assign, readonly) CGFloat riskLabelFontSize;

@end

@interface WDDetailNatantLayout (WDNatantLayout)
@property (nonatomic, assign, readonly) CGFloat wd_topMargin;
@property (nonatomic, assign, readonly) CGFloat wd_bottomMargin;
@end
