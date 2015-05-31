/*
 ==============================================================================
 CEPrintPaneController
 
 CotEditor
 http://coteditor.com
 
 Created on 2014-04-18 by 1024jp
 encoding="UTF-8"
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2014-2015 1024jp
 
 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 Place - Suite 330, Boston, MA  02111-1307, USA.
 
 ==============================================================================
 */

#import "CEPrintPaneController.h"
#import "CEThemeManager.h"
#import "constants.h"


@interface CEPrintPaneController ()

@property (nonatomic, nullable, weak) IBOutlet NSTextField *fontField;
@property (nonatomic, nullable, weak) IBOutlet NSPopUpButton *colorPopupButton;

@end




#pragma mark -

@implementation CEPrintPaneController

#pragma mark Superclass Methods

// ------------------------------------------------------
/// clean up
- (void)dealloc
// ------------------------------------------------------
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// ------------------------------------------------------
/// setup UI
- (void)loadView
// ------------------------------------------------------
{
    [super loadView];
    
    [self setFontFamilyNameAndSize];
    [self setupColorMenu];
    
    // observe theme list update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupColorMenu)
                                                 name:CEThemeListDidUpdateNotification
                                               object:nil];
}



#pragma mark Action Messages

// ------------------------------------------------------
/// show font panel
- (IBAction)showFonts:(nullable id)sender
//-------------------------------------------------------
{
    NSFont *font = [NSFont fontWithName:[[NSUserDefaults standardUserDefaults] stringForKey:CEDefaultPrintFontNameKey]
                                   size:(CGFloat)[[NSUserDefaults standardUserDefaults] doubleForKey:CEDefaultPrintFontSizeKey]];
    
    [[[self view] window] makeFirstResponder:self];
    [[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:sender];
}


// ------------------------------------------------------
/// font in font panel did update
- (void)changeFont:(nullable id)sender
// ------------------------------------------------------
{
    NSFontManager *fontManager = (NSFontManager *)sender;
    NSFont *newFont = [fontManager convertFont:[NSFont systemFontOfSize:0]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[newFont fontName] forKey:CEDefaultPrintFontNameKey];
    [[NSUserDefaults standardUserDefaults] setDouble:[newFont pointSize] forKey:CEDefaultPrintFontSizeKey];
    
    [self setFontFamilyNameAndSize];
}


// ------------------------------------------------------
/// color setting did update
- (IBAction)changePrintTheme:(nullable id)sender
// ------------------------------------------------------
{
    NSPopUpButton *popup = (NSPopUpButton *)sender;
    NSUInteger index = [popup indexOfSelectedItem];
    
    NSString *theme = (index > 2) ? [popup titleOfSelectedItem] : nil;  // do not set theme on `Black and White` and `same as document's setting`
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:CEDefaultPrintThemeKey];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:CEDefaultPrintColorIndexKey];
}



#pragma mark Private Methods

//------------------------------------------------------
/// display font name and size in the font field
- (void)setFontFamilyNameAndSize
//------------------------------------------------------
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:CEDefaultPrintFontNameKey];
    CGFloat size = (CGFloat)[[NSUserDefaults standardUserDefaults] doubleForKey:CEDefaultPrintFontSizeKey];
    NSFont *font = [NSFont fontWithName:name size:size];
    NSString *localizedName = [font displayName];
    
    [[self fontField] setStringValue:[NSString stringWithFormat:@"%@ %g", localizedName, size]];
}


//------------------------------------------------------
/// setup popup menu for color setting
- (void)setupColorMenu
//------------------------------------------------------
{
    NSUInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:CEDefaultPrintColorIndexKey];
    NSString *themeName = [[NSUserDefaults standardUserDefaults] stringForKey:CEDefaultPrintThemeKey];
    NSArray *themeNames = [[CEThemeManager sharedManager] themeNames];
    
    [[self colorPopupButton] removeAllItems];
    
    // setup popup menu
    [[self colorPopupButton] addItemWithTitle:NSLocalizedString(@"Black and White", nil)];
    [[self colorPopupButton] addItemWithTitle:NSLocalizedString(@"Same as Document's Setting", nil)];
    [[[self colorPopupButton] menu] addItem:[NSMenuItem separatorItem]];
    [[self colorPopupButton] addItemWithTitle:NSLocalizedString(@"Theme", nil)];
    [[[self colorPopupButton] lastItem] setAction:nil];
    for (NSString *name in themeNames) {
        [[self colorPopupButton] addItemWithTitle:name];
        [[[self colorPopupButton] lastItem] setIndentationLevel:1];
    }
    
    // select menu
    if ([themeNames containsObject:themeName]) {
        [[self colorPopupButton] selectItemWithTitle:themeName];
    } else if (themeName || index == 1) {
        [[self colorPopupButton] selectItemAtIndex:1];  // same as document
    } else {
        [[self colorPopupButton] selectItemAtIndex:0];  // black and white
    }
}

@end
