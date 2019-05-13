//
//  FHMapDrawMaskView.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHMapDrawMaskViewDelegate;
@interface FHMapDrawMaskView : UIView

@property(nonatomic , weak) id <FHMapDrawMaskViewDelegate> delegate;

-(void)clear;

@end


@protocol FHMapDrawMaskViewDelegate <NSObject>

-(void)userDrawWithXcoords:(NSArray *)xcoords ycoords:(NSArray *)yxcoords inView:(FHMapDrawMaskView *)view;

-(void)userExit:(FHMapDrawMaskView *)view;

@end

NS_ASSUME_NONNULL_END
