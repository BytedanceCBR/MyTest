//
//  TTUGCDetailNatantLayoutProtocol.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/2/1.
//

#import <Foundation/Foundation.h>
#import <NSObject+TTAdditions.h>

@protocol TTUGCDetailNatantLayoutProtocol <NSObject,Singleton>

@property (nonatomic, assign, readonly) CGFloat leftMargin;
@property (nonatomic, assign, readonly) CGFloat rightMargin;
@property (nonatomic, assign, readonly) CGFloat topMargin;
@property (nonatomic, assign, readonly) CGFloat bottomMargin;
@property (nonatomic, assign, readonly) CGFloat spaceBeweenNantants;
@property (nonatomic, assign, readonly) CGFloat riskLabelFontSize;

@end
