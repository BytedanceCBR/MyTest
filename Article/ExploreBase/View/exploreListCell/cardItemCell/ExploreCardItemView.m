//
//  ExploreCardItemView.m
//  Article
//
//  Created by Chen Hong on 15/6/17.
//
//

#import "ExploreCardItemView.h"
#import "SSAppPageManager.h"
#import "TTStringHelper.h"

@implementation ExploreCardItemView


- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
}

- (void)setCardItemModel:(ExploreEmbedListCardItemModel *)cardItemModel {
    _cardItemModel = cardItemModel;
    
    self.nameLabel.text = cardItemModel.title;
    [self.avatarView setImageWithURLString:cardItemModel.avatarURLString placeholderImage:nil];
    
    if (!isEmptyString(cardItemModel.subtitle)) {
        self.recommendReasonLabel.text = cardItemModel.subtitle;
    } else {
        self.recommendReasonLabel.text = @"";
    }
    
    if (!isEmptyString(cardItemModel.desc)) {
        self.descLabel.text = cardItemModel.desc;
    }
    
    if (self.cardItemModel.nextCellType == ExploreOrderedDataCellTypeCard) {
        if (!self.bottomLineView.hidden) {
            self.bottomLineView.hidden = YES;
            [self setNeedsDisplay];
        }
    } else {
        if (self.bottomLineView.hidden) {
            self.bottomLineView.hidden = NO;
            [self setNeedsDisplay];
        }
    }
}

- (void)viewDidTapped {
    if (!isEmptyString(self.cardItemModel.openUrl)) {
        [[SSAppPageManager sharedManager] openURL:[TTStringHelper URLWithURLString:self.cardItemModel.openUrl]];
    }
//        // feed流卡片推荐pgc
//        if (self.isCardSubView) {
//            //ssTrackEvent(@"card", [NSString stringWithFormat:@"click_pgc_%d", self.cardSubCellIndex]);
//        }
//        
//        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
//        [dict setValue:@"pgc_profile" forKey:@"tag"];
//        [dict setValue:[NSString stringWithFormat:@"click_%@", self.pgcModel.categoryID] forKey:@"label"];
//        [dict setValue:self.pgcModel.mediaId forKey:@"media_id"];
//        [self trackClickEvent:dict];
//    }
}

@end
