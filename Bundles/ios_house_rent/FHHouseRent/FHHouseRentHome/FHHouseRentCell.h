//
//  FHHouseRentCell.h
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYLabel;
@class FHHouseRentDataItemsHouseImageTagModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHImageCornerView : UIView

@end

@interface FHTagItem : NSObject
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSString* textColor;
@property (nonatomic, copy) NSString* bgColor;

+(instancetype)instanceWithText:(NSString*)text withColor:(NSString*)textColor withBgColor:(NSString*)bgColor;

-(instancetype)initWithText:(NSString*)text withColor:(NSString*)textColor withBgColor:(NSString*)bgColor;

@end

@interface FHHouseRentCell : UITableViewCell
@property (nonatomic , strong) UILabel *imageTagView;
@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, strong) UILabel* majorTitle;
@property (nonatomic, strong) UILabel* extendTitle;
@property (nonatomic, strong) YYLabel* tagsLabel;
@property (nonatomic, strong) UILabel* priceLabel;
@property (nonatomic, strong) UILabel* availableStateLabel;
-(void)setTags:(NSArray<FHTagItem*>*)tags;
-(void)setHouseImages:(FHHouseRentDataItemsHouseImageTagModel *)houseImageTagModel;
@end

NS_ASSUME_NONNULL_END
