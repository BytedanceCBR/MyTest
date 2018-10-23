//
//  TTVisitorCell.h
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTBaseUserProfileCell.h"
#import "TTVisitorModel.h"


/**
 * 访客Cell
 */
@interface TTVisitorCell : TTBaseUserProfileCell
@property (nonatomic, strong, readonly) SSThemedView *textContainerView;

- (void)reloadWithVisitorModel:(TTVisitorFormattedModelItem *)aModel;
@end
