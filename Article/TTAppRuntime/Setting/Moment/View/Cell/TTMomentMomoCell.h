//
//  TTMomentMomoCell.h
//  Article
//
//  Created by SunJiangting on 15-6-15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

#import "ArticleMomentModel.h"

@interface TTMomentMomoCell : SSThemedTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView   *avatarView;
@property (weak, nonatomic) IBOutlet SSThemedLabel *nameLabel;

@property (weak, nonatomic) IBOutlet SSThemedLabel *addressLabel;
@property (weak, nonatomic) IBOutlet SSThemedLabel *descLabel;

@property(nonatomic, weak) IBOutlet  SSThemedLabel *promoteLabel;
@property(nonatomic, strong) ArticleMomentModel *momentModel;

@end
