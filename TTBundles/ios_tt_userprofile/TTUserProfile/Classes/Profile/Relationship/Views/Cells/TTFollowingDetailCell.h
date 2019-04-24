//
//  TTFollowingDetailCell.h
//  Article
//
//  Created by it-test on 8/9/16.
//
//

#import "TTFollowingModel.h"
#import "TTSocialBaseCell.h"



@interface TTFollowingDetailCell : TTSocialBaseCell

@property (nonatomic, copy) NSString *tipsCount;

- (void)reloadWithFollowingModel:(TTFollowingModel *)model;

@end
