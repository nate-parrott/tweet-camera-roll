//
//  NSAttributedString+ResizeToFit.h
//  computer
//
//  Created by Nate Parrott on 9/22/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (ResizeToFit)

- (NSAttributedString *)resizeToFitInside:(CGSize)size;
- (NSAttributedString *)hack_replaceAppleColorEmojiWithSystemFont;

@end
