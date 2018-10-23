//
//  SSSocialActionButton.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-10-29.
//
//

#import <UIKit/UIKit.h>

typedef enum SSSocialActionButtonActionType{
    SSSocialActionButtonActionTypeNormal = 0,
    SSSocialActionButtonActionTypeSelected,
    SSSocialActionButtonActionTypeNormalWithDisable,
    SSSocialActionButtonActionTypeSelectedWithDisable
}SSSocialActionButtonActionType;

@interface SSSocialActionButton : UIButton

@property(nonatomic, assign, readonly)SSSocialActionButtonActionType actionType;

@property(nonatomic, retain)UIImage * normalImg;
@property(nonatomic, retain)UIImage * normalBGImg;
@property(nonatomic, retain)UIColor * normalTitleColor;

@property(nonatomic, retain)UIImage * selectedImg;
@property(nonatomic, retain)UIImage * selectedBGImg;
@property(nonatomic, retain)UIColor * selectedTitleColor;

@property(nonatomic, retain)UIImage * normalHighlightImg;
@property(nonatomic, retain)UIImage * normalHighlightBGImg;
@property(nonatomic, retain)UIColor * normalHighlightTitleColor;

@property(nonatomic, retain)UIImage * selectedHighlightImg;
@property(nonatomic, retain)UIImage * selectedHighlightBGImg;
@property(nonatomic, retain)UIColor * selectedHighlightTitleColor;

@property(nonatomic, retain)UIImage * normalDisableImg;
@property(nonatomic, retain)UIImage * normalDisableBGImg;
@property(nonatomic, retain)UIColor * normalDisableTitleColor;

@property(nonatomic, retain)UIImage * selectedDisableImg;
@property(nonatomic, retain)UIImage * selectedDisableBGImg;
@property(nonatomic, retain)UIColor * selectedDisableTitleColor;

- (void)changeStatus:(SSSocialActionButtonActionType)type;

@end
