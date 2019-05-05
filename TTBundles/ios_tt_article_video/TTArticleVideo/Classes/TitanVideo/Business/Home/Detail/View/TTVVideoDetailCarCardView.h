//
//  TTVVideoDetailCarCardView.h
//  Article
//
//  Created by pei yun on 2017/8/25.
//
//

#import <UIKit/UIKit.h>
#import "TTVDetailCarCard.h"
#import <TTThemed/SSThemed.h>

@interface TTVVideoDetailCarCardView : SSThemedView

@property (nonatomic, strong) TTVDetailCarCard *card;
@property (nonatomic, strong) NSString *artileGroupID;

@end
