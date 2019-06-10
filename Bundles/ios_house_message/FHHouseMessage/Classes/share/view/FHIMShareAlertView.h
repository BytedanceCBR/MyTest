//
//  FHIMShareAlertView.h
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import <UIKit/UIKit.h>
@class FHIMHouseShareView;
NS_ASSUME_NONNULL_BEGIN

@protocol FHIMShareAlertViewDelegate <NSObject>

-(void)onCancel;
-(void)onClickDone;

@end

@interface FHIMShareAlertView : UIView
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* avator;
@property (nonatomic, strong) UILabel* name;
@property (nonatomic, strong) FHIMHouseShareView* houseView;
@property (nonatomic, strong) UIButton* doneBtn;
@property (nonatomic, strong) UIButton* closeBtn;
@property (nonatomic, weak) id<FHIMShareAlertViewDelegate> delegate;
- (void)showFrom:(UIView *)parentView;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
