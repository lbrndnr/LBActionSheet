//
//  LBAlertSheet.h
//  Dashr
//
//  Created by Laurin Brandner on 14.02.13.
//
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@protocol LBActionSheetDelegate;

@interface LBActionSheet : UIView {
    id <LBActionSheetDelegate> __weak delegate;
    
    CIFilter* dimFilter;
    UIEdgeInsets controlOffsets;
    UIEdgeInsets contentInsets;
    BOOL visible;
}

@property (nonatomic, weak) id <LBActionSheetDelegate> delegate;

@property (nonatomic, readonly) NSUInteger numberOfButtons;
@property (nonatomic) NSUInteger cancelButtonIndex;
@property (nonatomic) NSUInteger destructiveButtonIndex;
@property (nonatomic, readonly) NSUInteger firstOtherButtonIndex;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSAttributedString* attributedTitle;
@property (nonatomic, readonly) UILabel* titleLabel;

@property (nonatomic, strong) CIFilter* dimFilter;
@property (nonatomic, strong) UIImage* backgroundImage;
@property (nonatomic) UIEdgeInsets controlOffsets;
@property (nonatomic) UIEdgeInsets contentInsets;

-(id)initWithTitle:(NSString *)title delegate:(id <LBActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

-(NSUInteger)addButtonWithTitle:(NSString *)title;
-(void)insertControl:(UIView*)control atIndex:(NSUInteger)index;
-(NSString *)buttonTitleAtIndex:(NSUInteger)buttonIndex;
-(UIButton *)buttonAtIndex:(NSUInteger)buttonIndex;

-(void)setButtonTitleAttributes:(NSDictionary*)attributes forState:(UIControlState)state;
-(NSDictionary*)buttonTitleAttributesForState:(UIControlState)state;

-(void)setDefaultButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state;
-(UIImage*)defaultButtonBackgroundImageForState:(UIControlState)state;
-(void)setDefaultButtonTitleAttributes:(NSDictionary*)attributes forState:(UIControlState)state;
-(NSDictionary*)defaultButtonTitleAttributesForState:(UIControlState)state;

-(void)setCancelButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state;
-(UIImage*)cancelButtonBackgroundImageForState:(UIControlState)state;
-(void)setCancelButtonTitleAttributes:(NSDictionary*)attributes forState:(UIControlState)state;
-(NSDictionary*)cancelButtonTitleAttributesForState:(UIControlState)state;

-(void)setDestructiveButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state;
-(UIImage*)destructiveButtonBackgroundImageForState:(UIControlState)state;
-(void)setDestructiveButtonTitleAttributes:(NSDictionary*)attributes forState:(UIControlState)state;
-(NSDictionary*)destructiveButtonTitleAttributesForState:(UIControlState)state;

-(void)showFromToolbar:(UIToolbar *)view;
-(void)showFromTabBar:(UITabBar *)view;
//-(void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_2);
//-(void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_2);
-(void)showInView:(UIView *)view;

-(void)dismissWithClickedButtonIndex:(NSUInteger)buttonIndex animated:(BOOL)animated;

@end
@protocol LBActionSheetDelegate <NSObject>
@optional

-(void)actionSheet:(LBActionSheet *)actionSheet clickedButtonAtIndex:(NSUInteger)buttonIndex;
-(void)actionSheetCancel:(LBActionSheet *)actionSheet;
-(void)willPresentActionSheet:(LBActionSheet *)actionSheet;
-(void)didPresentActionSheet:(LBActionSheet *)actionSheet;
-(void)actionSheet:(LBActionSheet *)actionSheet willDismissWithButtonIndex:(NSUInteger)buttonIndex;
-(void)actionSheet:(LBActionSheet *)actionSheet didDismissWithButtonIndex:(NSUInteger)buttonIndex;

@end
