//
//  TTFollowedCell.m
//  Article
//
//  Created by it-test on 8/9/16.
//
//

#import "TTFollowedCell.h"
#import "TTProfileThemeConstants.h"


@implementation TTFollowedCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
    }
    return self;
}

- (void)reloadWithFollowedModel:(TTFollowedModel *)aModel {
    [self reloadWithModel:aModel];
}
@end
