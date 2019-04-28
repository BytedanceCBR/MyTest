//
//  TSVCardCellNormalViewFlowLayout.m
//  Article
//
//  Created by dingjinlu on 2017/12/4.
//

#define kCellGap    1
#define kLeft       15

#import "TSVCardCellNormalViewFlowLayout.h"

@implementation TSVCardCellNormalViewFlowLayout

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = kCellGap;
        self.minimumLineSpacing = kCellGap;
        self.headerReferenceSize = CGSizeMake(kLeft, 0);
        self.footerReferenceSize = CGSizeMake(kLeft, 0);
    }
    return self;
}

@end
