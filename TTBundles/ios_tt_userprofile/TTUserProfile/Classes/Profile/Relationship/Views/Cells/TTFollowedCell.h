//
//  TTFollowedCell.h
//  Article
//
//  Created by it-test on 8/9/16.
//
//

#import "TTFollowedModel.h"
#import "TTSocialBaseCell.h"


/**
 * TTFollowedCell：粉丝Cell
 */
@interface TTFollowedCell : TTSocialBaseCell
- (void)reloadWithFollowedModel:(TTFollowedModel *)aModel;
@end
