//
//  FHCommutePOIInputBar.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHCommutePOIInputBarDelegate;
@interface FHCommutePOIInputBar : UIView

@property(nonatomic , weak) id <FHCommutePOIInputBarDelegate> delegate;
@property(nonatomic , strong) NSString *text;
@property(nonatomic , strong) NSString *placeHolder;

-(void)showClear:(BOOL)show;

@end

@protocol FHCommutePOIInputBarDelegate <UITextFieldDelegate>

@optional
-(void)inputBarCancel;
-(void)textFieldClear;

@end

NS_ASSUME_NONNULL_END
