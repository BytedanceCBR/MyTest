//
//  FHHouseNewComponentView.h
//  FHHouseList
//
//  Created by bytedance on 2020/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNewComponentViewModelProtocol;
@protocol FHHouseNewComponentViewProtocol <NSObject>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel;

@optional
+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel;

@end

@interface FHHouseNewComponentView : UIView<FHHouseNewComponentViewProtocol>

@end

NS_ASSUME_NONNULL_END
