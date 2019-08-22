//
//  FHMapSearchPriceCell.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHMapSearchPriceCellDelegate;
@interface FHMapSearchPriceCell : UICollectionViewCell

@property(nonatomic , weak) id<FHMapSearchPriceCellDelegate> delegate;

-(BOOL)isInEditing;

-(void)updateWithLowerPlaceholder:(NSString * _Nullable)lowPrice higherPlaceholder:(NSString *_Nullable)highPrice;
-(void)updateWithLowerPrice:(NSString *_Nullable)lowPrice higherPrice:(NSString *_Nullable)highPrice;

@end

@protocol FHMapSearchPriceCellDelegate <NSObject>

@required

-(void)updateLowerPrice:(NSString *)price inCell:(FHMapSearchPriceCell *)cell;

-(void)updateHigherPrice:(NSString *)price inCell:(FHMapSearchPriceCell *)cell;

-(void)priceDidChange:(NSString *)price inCell:(FHMapSearchPriceCell *)cell;

@end

NS_ASSUME_NONNULL_END
