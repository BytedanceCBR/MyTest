//
//  TTMomentEnterCell.h
//  Article
//
//  Created by yuxin on 11/13/15.
//
//

#import "SSThemed.h"
#import "TTMomentEnterView.h"

@interface TTMomentEnterCell : SSThemedTableViewCell

@property (nonatomic,weak) IBOutlet TTMomentEnterView * momentView;
@property (nonatomic,weak) IBOutlet SSThemedImageView *  rightImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeftMargin;

- (void)setCellImageName:(NSString*)imageName;

@end
