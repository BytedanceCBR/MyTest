//
//  FHSuggestionRealHouseTopCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/29.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"
#import <FHHouseBase/FHListBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@class FHSugListRealHouseTopInfoModel;

@interface FHSuggestionRealHouseTopCell : FHListBaseCell

@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *realHouseLabel;
@property (nonatomic, strong)   UILabel       *realHouseNumLabel;
@property (nonatomic, strong)   UILabel       *realHouseUnitLabel;
@property (nonatomic, strong)   UILabel       *falseHouseLabel;
@property (nonatomic, strong)   UILabel       *falseHouseNumLabel;
@property (nonatomic, strong)   UILabel       *falseHouseUnitLabel;
@property (nonatomic, strong)   UIButton      *allWebHouseBtn;
@property (nonatomic, strong)   UIView        *segementLine;
@property (nonatomic, strong)   UIImageView   *backImageView;

- (void)refreshUI:(JSONModel *)data;

@end


NS_ASSUME_NONNULL_END
