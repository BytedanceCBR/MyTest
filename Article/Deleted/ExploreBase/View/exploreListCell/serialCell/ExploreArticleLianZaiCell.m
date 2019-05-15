//
//  ExploreArticleLianZaiCell.m
//  Article
//
//  Created by 邱鑫玥 on 16/7/13.
//
//

#import "ExploreArticleLianZaiCell.h"
#import "ExploreArticleLianZaiCellView.h"
#import "LianZai.h"
#import "TTRoute.h"

@implementation ExploreArticleLianZaiCell

+ (Class)cellViewClass
{
    return [ExploreArticleLianZaiCellView class];
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    LianZai *lianzai = ((ExploreOrderedData *)self.cellData).lianZai;
    if(lianzai != nil){
        lianzai.hasRead = @(YES);
        NSURL *lianzaiURL = [TTStringHelper URLWithURLString:lianzai.openURL];
        if ([[TTRoute sharedRoute] canOpenURL:lianzaiURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:lianzaiURL];
            wrapperTrackEventWithCustomKeys(@"feed_novel", @"feed_novel_click", [NSString stringWithFormat:@"%@", lianzai.serialID], nil, nil);
        }
    }

}

@end
