//
//  TTInterestCell.h
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "TTSocialBaseCell.h"
#import "TTInterestResponseModel.h"


/**
 *  兴趣页面中，每个兴趣项cell
 */
@interface TTInterestCell : TTSocialBaseCell
@property (nonatomic, strong) TTInterestItemModel *interestModel;

- (void)reloadWithModel:(TTInterestItemModel *)aModel;
@end
