# LBActionSheet

## About
LBActionSheet is a drop-in replacement for UIActionSheet. However, its API makes it very easy to customize it. It's designed for this sole purpose only which makes it redundant when you don't need to implement a custom theme.

## Usage
LBActionSheet's API is almost the same as UIActionSheet's. It might change in the future though. You should hit it off with it anyway.

## Installation
1. Drag the `LBActionsSheet` folder into your project.
2. Import the `CoreImage.framework`.

### Example

```objc
LBActionSheet* sheet = [[LBActionSheet alloc] initWithTitle:@"Discard?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard" otherButtonTitles:@"Save as draft", nil];	[sheet setDefaultButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-button"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
[sheet setDefaultButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-button-pressed"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateHighlighted];
    sheet.backgroundImage = [UIImage imageNamed:@"actionsheet-background"];
    
NSMutableDictionary* titleAttributes = [NSMutableDictionary new];
[titleAttributes setObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f] forKey:UITextAttributeFont];
[titleAttributes setObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
[titleAttributes setObject:[UIColor colorWithWhite:0.0f alpha:0.5f] forKey:UITextAttributeTextShadowColor];
[titleAttributes setObject:[NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)] forKey:UITextAttributeTextShadowOffset];
[sheet setButtonTitleAttributes:titleAttributes forState:UIControlStateNormal];
[sheet setButtonTitleAttributes:titleAttributes forState:UIControlStateHighlighted];
    
UIImageView* separator = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].applicationFrame), 3.0f)];
separator.image = [UIImage imageNamed:@"actionsheet-separator"];
[sheet insertControl:separator atIndex:self.cancelButtonIndex];
    
[sheet showInView:self.view];
```

## Requirements
ARC.

## License
LBActionSheet is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php). 
