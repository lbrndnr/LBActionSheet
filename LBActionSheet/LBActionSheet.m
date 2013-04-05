//
//  LBAlertSheet.m
//  Dashr
//
//  Created by Laurin Brandner on 14.02.13.
//
//

#import "LBActionSheet.h"

typedef enum _LBActionSheetButtonType {
    LBActionSheetDefaultButtonType = 0,
    LBActionSheetCancelButtonType = 1,
    LBActionSheetDestructiveButtonType = 2,
    LBActionSheetCustomButtonType = 3
} LBActionSheetButtonType;

const CGFloat kLBActionSheetAnimationDuration = 0.3f;
static UIWindow* blockWindow = nil;
static UIImageView* blockView = nil;

@interface LBActionSheet () {
    NSArray* controls;
    NSDictionary* buttonBackgroundImages;
    NSDictionary* buttonTitleAttributes;
    UIImageView* backgroundView;
}

@property (nonatomic, getter = isVisible) BOOL visible;
@property (nonatomic, strong) UILabel* titleLabel;

@property (nonatomic, strong) NSArray* controls;
@property (nonatomic, strong) NSDictionary* buttonBackgroundImages;
@property (nonatomic, strong) NSDictionary* buttonTitleAttribtues;
@property (nonatomic, strong) UIImageView* backgroundView;
@property (nonatomic, readonly) UIWindow* blockWindow;
@property (nonatomic, readonly) UIImageView* blockView;

-(void)_initialize;

-(void)insertControlsObject:(UIView *)object atIndex:(NSUInteger)index;

-(UIButton *)_buttonWithTitle:(NSString*)title orImage:(UIImage*)image type:(LBActionSheetButtonType)type;

-(void)_setButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state type:(LBActionSheetButtonType)type;
-(UIImage *)_buttonBackgroundImageForState:(UIControlState)state type:(LBActionSheetButtonType)type;

-(void)_setButtonTitleAttributes:(NSDictionary*)attributes forState:(UIControlState)state type:(LBActionSheetButtonType)type;
-(NSDictionary *)_buttonTitleAttributesForState:(UIControlState)state type:(LBActionSheetButtonType)type;
-(void)_button:(UIButton*)button setTitleAttributes:(NSDictionary*)attributes forState:(UIControlState)state;

-(void)_buttonWasPressed:(UIButton*)sender;
-(void)_applicationWillTerminate:(NSNotification*)notification;

-(void)_dismiss:(BOOL)animated completion:(void (^)(BOOL finished))completion;
-(void)_showInView:(UIView *)view;
-(void)_animateFromTransform:(CGAffineTransform)fromTransform fromAlpha:(CGFloat)fromAlpha toTransform:(CGAffineTransform)toTransform toAlpha:(CGFloat)toAlpha duration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

@end
@implementation LBActionSheet

@synthesize delegate, titleLabel, visible, dismissOnOtherButtonClicked, controls, buttonBackgroundImages, backgroundView, controlOffsets, contentInsets;

#pragma mark Accessors

-(void)addControls:(NSSet *)objects {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons addObjectsFromArray:objects.allObjects];
    self.controls = newButtons;
    
    [objects enumerateObjectsUsingBlock:^(UIView* view, BOOL *stop) {
        [self addSubview:view];
    }];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)addControlsObject:(UIView *)object {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons addObject:object];
    self.controls = newButtons;
    
    [self addSubview:object];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)insertControlsObject:(UIView *)object atIndex:(NSUInteger)index {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons insertObject:object atIndex:index];
    self.controls = newButtons;
    
    [self addSubview:object];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)removeControls:(NSSet *)objects {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons removeObjectsInArray:objects.allObjects];
    self.controls = newButtons;
    
    [objects enumerateObjectsUsingBlock:^(UIView* view, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(void)removeControlsObject:(UIButton *)object {
    NSMutableArray* newButtons = self.controls.mutableCopy ?: [NSMutableArray new];
    [newButtons addObject:object];
    self.controls = newButtons;
    
    [object removeFromSuperview];
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(NSUInteger)numberOfButtons {
    return self.controls.count;
}

-(NSUInteger)cancelButtonIndex {
    __block NSUInteger index = NSNotFound;
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == LBActionSheetCancelButtonType) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(NSUInteger)destructiveButtonIndex {
    __block NSUInteger index = NSNotFound;
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == LBActionSheetDestructiveButtonType) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(NSUInteger)firstOtherButtonIndex {
    __block NSUInteger index = NSNotFound;
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == LBActionSheetDefaultButtonType) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(void)setVisible:(BOOL)value {
    if (visible != value) {
        visible = value;
        if (value) {
            CGRect newFrame = self.frame;
            newFrame.size = [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.blockWindow.frame), 0.0f)];
            newFrame.origin.y = CGRectGetHeight(self.blockWindow.frame)-CGRectGetHeight(newFrame);
            self.frame = newFrame;
            
            [self setNeedsLayout];
            
            [self.blockWindow makeKeyAndVisible];
            [self.blockWindow addSubview:self];
            [self.blockWindow bringSubviewToFront:self];
        }
        else {
            [self removeFromSuperview];
            self.blockWindow.hidden = YES;
        }
    }
}

-(NSString*)title {
    return self.titleLabel.text;
}

-(void)setTitle:(NSString *)value {
    if (value) {
        UILabel* newTitleLabel = [UILabel new];
        newTitleLabel.backgroundColor = [UIColor clearColor];
        newTitleLabel.textAlignment = NSTextAlignmentCenter;
        newTitleLabel.text = value;
        newTitleLabel.numberOfLines = 0;
        self.titleLabel = newTitleLabel;
        [self addSubview:self.titleLabel];
    }
    else {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
    
    if (self.visible) {
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

-(NSAttributedString*)attributedTitle {
    return self.titleLabel.attributedText;
}

-(void)setAttributedTitle:(NSAttributedString *)value {
    self.titleLabel.attributedText = value;
}

-(void)setBackgroundImage:(UIImage *)value {
    if (![self.backgroundView.image isEqual:value]) {
        if (value) {
            if (!self.backgroundView) {
                UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
                newBackgroundView.image = value;
                [self addSubview:newBackgroundView];
                [self sendSubviewToBack:newBackgroundView];
                self.backgroundView = newBackgroundView;
            }
            
            self.backgroundView.image = value;
        }
        else {
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
        }
    }
}

-(void)setControlOffsets:(UIEdgeInsets)value {
    if (!UIEdgeInsetsEqualToEdgeInsets(controlOffsets, value)) {
        controlOffsets = value;
        
        [self setNeedsLayout];
    }
}

-(void)setContentInsets:(UIEdgeInsets)value {
    if (!UIEdgeInsetsEqualToEdgeInsets(contentInsets, value)) {
        contentInsets = value;
        
        [self setNeedsLayout];
    }
}

-(UIImageView*)dimView {
    return self.blockView;
}

-(UIWindow*)blockWindow {
    if (blockWindow) {
        return blockWindow;
    }
    
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    window.windowLevel = UIWindowLevelAlert;
    
    blockWindow = window;
    return window;
}

-(UIImageView*)blockView {
    if (blockView) {
        return blockView;
    }
    
    UIImageView* view = [[UIImageView alloc] initWithFrame:self.blockWindow.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.blockWindow addSubview:view];
    [self.blockWindow sendSubviewToBack:view];
    
    blockView = view;
    return view;
}

#pragma mark -
#pragma mark Initialization

-(id)initWithTitle:(NSString *)title delegate:(id <LBActionSheetDelegate>)obj cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super init];
    if (self) {
        if (cancelButtonTitle || destructiveButtonTitle || otherButtonTitles) {
            NSMutableArray* newButtons = [NSMutableArray new];
            if (destructiveButtonTitle) {
                [newButtons addObject:[self _buttonWithTitle:destructiveButtonTitle orImage:nil type:LBActionSheetDestructiveButtonType]];
            }
            if (otherButtonTitles) {
                va_list otherTitles;
                va_start(otherTitles, otherButtonTitles);
                for (NSString* otherTitle = otherButtonTitles; otherTitle; otherTitle = (va_arg(otherTitles, NSString*))) {
                    [newButtons addObject:[self _buttonWithTitle:otherTitle orImage:nil type:LBActionSheetDefaultButtonType]];
                }
                va_end(otherTitles);
            }
            if (cancelButtonTitle) {
                [newButtons addObject:[self _buttonWithTitle:cancelButtonTitle orImage:nil type:LBActionSheetCancelButtonType]];
            }
            [newButtons enumerateObjectsUsingBlock:^(UIView* button, NSUInteger idx, BOOL *stop) {
                [self addSubview:button];
            }];
            self.controls = newButtons;
        }
        
        self.title = title;
        self.delegate = obj;
        [self _initialize];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    
    return self;
}

-(void)_initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    [self initializeAppearance];
    self.dismissOnOtherButtonClicked = YES;
    self.controlOffsets = UIEdgeInsetsMake(4.0f, 21.0f, 4.0f, 21.0f);
    self.contentInsets = UIEdgeInsetsMake(7.0f, 0.0f, 7.0f, 0.0f);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
}

-(void)initializeAppearance {}

#pragma mark -
#pragma mark Memory

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Appearance

-(UIButton *)_buttonWithTitle:(NSString *)title orImage:(UIImage *)image type:(LBActionSheetButtonType)type {
    UIButton* newButton = [UIButton new];
    newButton.tag = type;
    
    if (title) {
        [newButton setTitle:title forState:UIControlStateNormal];
    }
    else {
        [newButton setImage:image forState:UIControlStateNormal];
        newButton.adjustsImageWhenHighlighted = NO;
    }
    
    UIImage* backgroundImage = [self _buttonBackgroundImageForState:UIControlStateNormal type:type];
    UIImage* highlihgtedBackgroundImage = [self _buttonBackgroundImageForState:UIControlStateHighlighted type:type];
    [newButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [newButton setBackgroundImage:backgroundImage forState:UIControlStateSelected];
    [newButton setBackgroundImage:highlihgtedBackgroundImage forState:UIControlStateHighlighted];
    [newButton setBackgroundImage:highlihgtedBackgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
    [self _button:newButton setTitleAttributes:[self _buttonTitleAttributesForState:UIControlStateNormal type:type] forState:UIControlStateNormal];
    [self _button:newButton setTitleAttributes:[self _buttonTitleAttributesForState:UIControlStateHighlighted type:type] forState:UIControlStateHighlighted];
    [newButton addTarget:self action:@selector(_buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return newButton;
}

-(NSUInteger)addButtonWithTitle:(NSString *)title {
    UIButton* newButton = [self _buttonWithTitle:title orImage:nil type:LBActionSheetDefaultButtonType];
    [self addControlsObject:newButton];
    
    return self.controls.count-1;
}

-(NSUInteger)addButtonWithImage:(UIImage *)image {
    UIButton* newButton = [self _buttonWithTitle:nil orImage:image type:LBActionSheetDefaultButtonType];
    [self addControlsObject:newButton];
    
    return self.controls.count-1;
}

-(void)insertButtonWithTitle:(NSString *)title atIndex:(NSUInteger)index {
    UIButton* newButton = [self _buttonWithTitle:title orImage:nil type:LBActionSheetDefaultButtonType];
    [self insertControlsObject:newButton atIndex:index];
}

-(void)insertButtonWithImage:(UIImage *)image atIndex:(NSUInteger)index {
    UIButton* newButton = [self _buttonWithTitle:nil orImage:image type:LBActionSheetDefaultButtonType];
    [self insertControlsObject:newButton atIndex:index];
}

-(void)insertControl:(UIView *)control atIndex:(NSUInteger)index {
    control.tag = LBActionSheetCustomButtonType;
    [self insertControlsObject:control atIndex:index];
}

-(NSString *)buttonTitleAtIndex:(NSUInteger)buttonIndex {
    UIButton* button = self.controls[buttonIndex];
    return [button titleForState:UIControlStateNormal];
}

-(UIButton *)buttonAtIndex:(NSUInteger)buttonIndex {
    return self.controls[buttonIndex];
}

-(void)_setButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state type:(LBActionSheetButtonType)type {
    NSNumber* typeKey = @(type);
    NSNumber* stateKey = @(state);
    
    NSMutableDictionary* newButtonBackroundImages = self.buttonBackgroundImages.mutableCopy ?: [NSMutableDictionary new];
    NSMutableDictionary* newTypeInfo = [newButtonBackroundImages[typeKey] mutableCopy] ?: [NSMutableDictionary new];
    [newTypeInfo setObject:image forKey:stateKey];
    [newButtonBackroundImages setObject:newTypeInfo forKey:typeKey];
    
    self.buttonBackgroundImages = newButtonBackroundImages;
    
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag != LBActionSheetCustomButtonType && [obj isKindOfClass:[UIButton class]]) {
            [obj setBackgroundImage:[self _buttonBackgroundImageForState:UIControlStateNormal type:obj.tag] forState:UIControlStateNormal];
            [obj setBackgroundImage:[self _buttonBackgroundImageForState:UIControlStateHighlighted type:obj.tag] forState:UIControlStateHighlighted];
        }
    }];
}

-(UIImage *)_buttonBackgroundImageForState:(UIControlState)state type:(LBActionSheetButtonType)type {
    return (UIImage*)self.buttonBackgroundImages[@(type)][@(state)];
}

-(void)_button:(UIButton *)button setTitleAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    button.titleLabel.font = attributes[UITextAttributeFont];
    [button setTitleColor:attributes[UITextAttributeTextColor] forState:state];
    [button setTitleShadowColor:attributes[UITextAttributeTextShadowColor] forState:state];
    button.titleLabel.shadowOffset = [(NSValue*)attributes[UITextAttributeTextShadowOffset] CGSizeValue];
}

-(void)_setButtonTitleAttributes:(NSDictionary *)attributes forState:(UIControlState)state type:(LBActionSheetButtonType)type {
    NSNumber* typeKey = @(type);
    NSNumber* stateKey = @(state);
    
    NSMutableDictionary* newButtonBackroundImages = self.buttonTitleAttribtues.mutableCopy ?: [NSMutableDictionary new];
    NSMutableDictionary* newTypeInfo = [newButtonBackroundImages[typeKey] mutableCopy] ?: [NSMutableDictionary new];
    [newTypeInfo setObject:attributes forKey:stateKey];
    [newButtonBackroundImages setObject:newTypeInfo forKey:typeKey];
    
    self.buttonTitleAttribtues = newButtonBackroundImages;
    
    [self.controls enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag != LBActionSheetCustomButtonType && [obj isKindOfClass:[UIButton class]]) {
            [self _button:obj setTitleAttributes:[self _buttonTitleAttributesForState:UIControlStateNormal type:obj.tag] forState:UIControlStateNormal];
            [self _button:obj setTitleAttributes:[self _buttonTitleAttributesForState:UIControlStateHighlighted type:obj.tag] forState:UIControlStateHighlighted];
        }
    }];
}

-(NSDictionary *)_buttonTitleAttributesForState:(UIControlState)state type:(LBActionSheetButtonType)type {
    return (NSDictionary*)self.buttonTitleAttribtues[@(type)][@(state)];
}

-(void)setButtonTitleAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [self _setButtonTitleAttributes:attributes forState:state type:LBActionSheetDefaultButtonType];
    [self _setButtonTitleAttributes:attributes forState:state type:LBActionSheetCancelButtonType];
    [self _setButtonTitleAttributes:attributes forState:state type:LBActionSheetDestructiveButtonType];
}

-(NSDictionary*)buttonTitleAttributesForState:(UIControlState)state {
    return [self defaultButtonTitleAttributesForState:state];
}

-(void)setDefaultButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self _setButtonBackgroundImage:image forState:state type:LBActionSheetDefaultButtonType];
}

-(UIImage*)defaultButtonBackgroundImageForState:(UIControlState)state {
    return [self _buttonBackgroundImageForState:state type:LBActionSheetDefaultButtonType];
}

-(void)setDefaultButtonTitleAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [self _setButtonTitleAttributes:attributes forState:state type:LBActionSheetDefaultButtonType];
}

-(NSDictionary*)defaultButtonTitleAttributesForState:(UIControlState)state {
    return [self _buttonTitleAttributesForState:state type:LBActionSheetDefaultButtonType];
}

-(void)setCancelButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self _setButtonBackgroundImage:image forState:state type:LBActionSheetCancelButtonType];
}

-(UIImage*)cancelButtonBackgroundImageForState:(UIControlState)state {
    return [self _buttonBackgroundImageForState:state type:LBActionSheetCancelButtonType];
}

-(void)setCancelButtonTitleAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [self _setButtonTitleAttributes:attributes forState:state type:LBActionSheetCancelButtonType];
}

-(NSDictionary*)cancelButtonTitleAttributesForState:(UIControlState)state {
    return [self _buttonTitleAttributesForState:state type:LBActionSheetCancelButtonType];
}

-(void)setDestructiveButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self _setButtonBackgroundImage:image forState:state type:LBActionSheetDestructiveButtonType];
}

-(UIImage*)destructiveButtonBackgroundImageForState:(UIControlState)state {
    return [self _buttonBackgroundImageForState:state type:LBActionSheetDestructiveButtonType];
}

-(void)setDestructiveButtonTitleAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [self _setButtonTitleAttributes:attributes forState:state type:LBActionSheetDestructiveButtonType];
}

-(NSDictionary*)destructiveButtonTitleAttributesForState:(UIControlState)state {
    return [self _buttonTitleAttributesForState:state type:LBActionSheetDestructiveButtonType];
}

-(void)layoutSubviews {
    UIEdgeInsets insets = self.contentInsets;
    UIEdgeInsets offsets = self.controlOffsets;
    CGFloat maxWidth = CGRectGetWidth(self.bounds)-offsets.left-offsets.right-insets.left-insets.right;
    __block CGPoint origin = CGPointMake(offsets.left+insets.left, offsets.top+insets.top);
    
    self.backgroundView.frame = self.bounds;
    CGSize neededTitleSize = [self.titleLabel sizeThatFits:CGSizeMake(maxWidth, 100.0f)];
    CGRect newTitleLabelFrame = (CGRect){origin, {maxWidth, neededTitleSize.height}};
    self.titleLabel.frame = newTitleLabelFrame;
    
    if (CGRectGetHeight(newTitleLabelFrame)>0.0f) {
        origin.y = CGRectGetMaxY(newTitleLabelFrame)+offsets.top+offsets.bottom;
    }
    
    [self.controls enumerateObjectsUsingBlock:^(UIView* control, NSUInteger idx, BOOL *stop) {
        if (control.tag == LBActionSheetCustomButtonType) {
            CGSize neededSize = control.frame.size;
            if (CGSizeEqualToSize(neededSize, CGSizeZero)) {
                neededSize = [control sizeThatFits:control.frame.size];
            }
            control.frame = (CGRect){{CGRectGetWidth(self.bounds)/2.0f-neededSize.width/2.0f, origin.y}, neededSize};
        }
        else {
            CGSize neededSize = [control sizeThatFits:control.frame.size];
            control.frame = (CGRect){origin, {maxWidth, neededSize.height}};
        }
        origin.y += CGRectGetHeight(control.frame)+offsets.top+offsets.bottom;
    }];
}

-(CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = self.contentInsets;
    UIEdgeInsets offsets = self.controlOffsets;
    CGFloat maxWidth = size.width-offsets.left-offsets.right-insets.left-insets.right;
    CGSize neededTitleSize = [self.titleLabel sizeThatFits:CGSizeMake(maxWidth, 100.0f)];
    __block CGFloat neededHeight = CGSizeEqualToSize(neededTitleSize, CGSizeZero) ? 0.0f : neededTitleSize.height+offsets.top+offsets.bottom;
    
    [self.controls enumerateObjectsUsingBlock:^(UIView* control, NSUInteger idx, BOOL *stop) {
        CGSize neededSize;
        if (control.tag == LBActionSheetCustomButtonType) {
            neededSize = control.frame.size;
            if (CGSizeEqualToSize(neededSize, CGSizeZero)) {
                neededSize = [control sizeThatFits:control.frame.size];
            }
        }
        else {
            neededSize = [control sizeThatFits:control.frame.size];
        }
        neededHeight += neededSize.height+offsets.top+offsets.bottom;
    }];
    
    return CGSizeMake(size.width, neededHeight+insets.top+insets.bottom);
}

#pragma mark -
#pragma mark Presentation

-(void)_animateFromTransform:(CGAffineTransform)fromTransform fromAlpha:(CGFloat)fromAlpha toTransform:(CGAffineTransform)toTransform toAlpha:(CGFloat)toAlpha duration:(CGFloat)duration completion:(void (^)(BOOL))completion {
    self.transform = fromTransform;
    self.blockView.alpha = fromAlpha;

    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = toTransform;
        self.blockView.alpha = toAlpha;
    } completion:completion];
}

-(void)_showInView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:self];
    }
    
    self.visible = YES;
    CGAffineTransform fromTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, CGRectGetHeight(self.bounds));
    
    [self _animateFromTransform:fromTransform fromAlpha:0.0f toTransform:CGAffineTransformIdentity toAlpha:1.0f duration:kLBActionSheetAnimationDuration completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
    }];
}

-(void)showInView:(UIView *)view {
    [self _showInView:view];
}

-(void)showFromTabBar:(UITabBar *)tabBar {
    [self _showInView:tabBar.superview];
}

-(void)showFromToolbar:(UIToolbar *)toolbar {
    [self _showInView:toolbar.superview];
}

-(void)_dismiss:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self _animateFromTransform:self.transform fromAlpha:1.0f toTransform:CGAffineTransformTranslate(self.transform, 0.0f, CGRectGetHeight(self.frame)) toAlpha:0.0f duration:(animated) ? kLBActionSheetAnimationDuration : 0.0f completion:^(BOOL finished) {
        self.visible = NO;
        
        if (completion) {
            completion(finished);
        }
    }];
}

-(void)dismissWithClickedButtonIndex:(NSUInteger)buttonIndex animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self willDismissWithButtonIndex:buttonIndex];
    }
    
    [self _dismiss:animated completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self didDismissWithButtonIndex:buttonIndex];
        }
    }];
}

#pragma mark -
#pragma mark Other Methods

-(void)_buttonWasPressed:(UIButton *)sender {
    NSUInteger index = [self.controls indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:index];
    }
    
    BOOL dismiss = (sender.tag != LBActionSheetDefaultButtonType) ?: self.dismissOnOtherButtonClicked;
    if (dismiss) {
        [self dismissWithClickedButtonIndex:index animated:YES];
    }
}

-(void)_applicationWillTerminate:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.delegate actionSheetCancel:self];
    }
    
    [self _dismiss:NO completion:nil];
}

#pragma mark -

@end
