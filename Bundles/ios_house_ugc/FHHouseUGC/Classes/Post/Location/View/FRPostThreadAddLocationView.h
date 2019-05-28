//
//  FRPostThreadAddLocationView.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//

#import <TTThemed/SSThemed.h>
#import <TTUGCFoundation/FRLocationEntity.h>
#import <TTUGCFoundation/FRForumEntity.h>

@protocol FRPostThreadAddLocationViewDelegate <NSObject>

@optional

- (void)addLocationViewWillPresent;
- (void)addLocationViewDidDismiss;

@end

@interface FRPostThreadAddLocationView : SSThemedView

@property (nonatomic, strong, nullable) FRLocationEntity *selectedLocation;
@property (nonatomic, copy, nullable) NSString *concernId;
@property (nonatomic, copy, nullable) NSDictionary *trackDic;
@property (nonatomic, weak) id <FRPostThreadAddLocationViewDelegate> delegate;

@property (nonatomic, copy) NSString *categotyID;

- (nonnull instancetype)initWithFrame:(CGRect)frame andShowEtStatus:(FRShowEtStatus)showEtStatus NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCoder:(NSCoder *_Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)buttonClicked:(UIButton *_Nullable)sender;
- (void)refresh;
@end

@interface TTUGCPostThreadLocationButton : SSThemedButton

@property (nonatomic, assign) CGFloat maxTextWidth;

- (void)configWithActiveStatus:(BOOL)activeStatus text:(NSString *)text;


@end
