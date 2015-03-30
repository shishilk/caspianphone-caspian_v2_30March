/* DialerViewController.h
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DialerViewController.h"
#import "IncallViewController.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "Utils.h"
#import "ActivateSMSViewController.h"
#import "smsCaspianVC.h"

#include "linphone/linphonecore.h"

@interface DialerViewController()

@property (nonatomic, retain) UIView *dummyView;

@end

@implementation DialerViewController

@synthesize transferMode;

@synthesize addressField;
@synthesize addContactButton;
@synthesize backButton;
@synthesize addCallButton;
@synthesize transferButton;
@synthesize callButton;
@synthesize eraseButton;

@synthesize oneButton;
@synthesize twoButton;
@synthesize threeButton;
@synthesize fourButton;
@synthesize fiveButton;
@synthesize sixButton;
@synthesize sevenButton;
@synthesize eightButton;
@synthesize nineButton;
@synthesize starButton;
@synthesize zeroButton;
@synthesize sharpButton;

@synthesize backgroundView;
@synthesize videoPreview;
@synthesize videoCameraSwitch;

#pragma mark - Properties

- (UIView *)dummyView {
    if (!_dummyView) {
        _dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _dummyView;
}

#pragma mark - Lifecycle Functions

- (id)init {
    self = [super initWithNibName:@"DialerViewController" bundle:[NSBundle mainBundle]];
    if(self) {
        self->transferMode = FALSE;
    }
    return self;
}

- (void)dealloc {
	[addressField release];
    [addContactButton release];
    [backButton release];
    [eraseButton release];
	[callButton release];
    [addCallButton release];
    [transferButton release];

	[oneButton release];
	[twoButton release];
	[threeButton release];
	[fourButton release];
	[fiveButton release];
	[sixButton release];
	[sevenButton release];
	[eightButton release];
	[nineButton release];
	[starButton release];
	[zeroButton release];
	[sharpButton release];

    [videoPreview release];
    [videoCameraSwitch release];
    
    [_dummyView release];

    // Remove all observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[super dealloc];
}


#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"Dialer"
                                                                content:@"DialerViewController"
                                                               stateBar:@"UIStateBar"
                                                        stateBarEnabled:true
                                                                 tabBar:@"UIMainBar"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}


#pragma mark - ViewController Functions

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Set observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(coreUpdateEvent:)
                                                 name:kLinphoneCoreUpdate
                                               object:nil];

    // technically not needed, but older versions of linphone had this button
    // disabled by default. In this case, updating by pushing a new version with
    // xcode would result in the callbutton being disabled all the time.
    // We force it enabled anyway now.
    [callButton setEnabled:TRUE];

    // Update on show
    LinphoneManager *mgr    = [LinphoneManager instance];
    LinphoneCore* lc        = [LinphoneManager getLc];
    LinphoneCall* call      = linphone_core_get_current_call(lc);
    LinphoneCallState state = (call != NULL)?linphone_call_get_state(call): 0;
    [self callUpdate:call state:state];

    if([LinphoneManager runningOnIpad]) {
        BOOL videoEnabled = linphone_core_video_enabled(lc);
        BOOL previewPref  = [mgr lpConfigBoolForKey:@"preview_preference"];

		if( videoEnabled && previewPref ) {
            linphone_core_set_native_preview_window_id(lc, (unsigned long)videoPreview);

			if( !linphone_core_video_preview_enabled(lc)){
				linphone_core_enable_video_preview(lc, TRUE);
			}
			
            [backgroundView setHidden:FALSE];
            [videoCameraSwitch setHidden:FALSE];
        } else {
            linphone_core_set_native_preview_window_id(lc, (unsigned long)NULL);
            linphone_core_enable_video_preview(lc, FALSE);
            [backgroundView setHidden:TRUE];
            [videoCameraSwitch setHidden:TRUE];
        }
    }

    [addressField setText:@""];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0 // attributed string only available since iOS6
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // fix placeholder bar color in iOS7
        UIColor *color = [UIColor grayColor];
        NSAttributedString* placeHolderString = [[NSAttributedString alloc]
                                                 initWithString:NSLocalizedString(@"Enter an address", @"Enter an address")
                                                 attributes:@{NSForegroundColorAttributeName: color}];
        addressField.attributedPlaceholder = placeHolderString;
        [placeHolderString release];
    }
#endif

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCallUpdate
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCoreUpdate
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[zeroButton    setDigit:'0'];
	[oneButton     setDigit:'1'];
	[twoButton     setDigit:'2'];
	[threeButton   setDigit:'3'];
	[fourButton    setDigit:'4'];
	[fiveButton    setDigit:'5'];
	[sixButton     setDigit:'6'];
	[sevenButton   setDigit:'7'];
	[eightButton   setDigit:'8'];
	[nineButton    setDigit:'9'];
	[starButton    setDigit:'*'];
	[sharpButton   setDigit:'#'];

    [addressField setAdjustsFontSizeToFitWidth:TRUE]; // Not put it in IB: issue with placeholder size

    if([LinphoneManager runningOnIpad]) {
        if ([LinphoneManager instance].frontCamId != nil) {
            // only show camera switch button if we have more than 1 camera
            [videoCameraSwitch setHidden:FALSE];
        }
    }
    
    addressField.inputView = self.dummyView;
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    CGRect frame = [videoPreview frame];
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [videoPreview setTransform: CGAffineTransformMakeRotation(0)];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [videoPreview setTransform: CGAffineTransformMakeRotation(M_PI)];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [videoPreview setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [videoPreview setTransform: CGAffineTransformMakeRotation(-M_PI / 2)];
            break;
        default:
            break;
    }
    [videoPreview setFrame:frame];
}


#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:call state:state];
}

- (void)coreUpdateEvent:(NSNotification*)notif {
    if([LinphoneManager runningOnIpad]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        if(linphone_core_video_enabled(lc) && linphone_core_video_preview_enabled(lc)) {
            linphone_core_set_native_preview_window_id(lc, (unsigned long)videoPreview);
            [backgroundView setHidden:FALSE];
            [videoCameraSwitch setHidden:FALSE];
        } else {
            linphone_core_set_native_preview_window_id(lc, (unsigned long)NULL);
            [backgroundView setHidden:TRUE];
            [videoCameraSwitch setHidden:TRUE];
        }
    }
}

#pragma mark -

- (void)callUpdate:(LinphoneCall*)call state:(LinphoneCallState)state {
    LinphoneCore *lc = [LinphoneManager getLc];
    if(linphone_core_get_calls_nb(lc) > 0) {
        if(transferMode) {
            [addCallButton setHidden:true];
            [transferButton setHidden:false];
        } else {
            [addCallButton setHidden:false];
            [transferButton setHidden:true];
        }
        [callButton setHidden:true];
        [backButton setHidden:false];
        [addContactButton setHidden:true];
    } else {
        [addCallButton setHidden:true];
        [callButton setHidden:false];
        [backButton setHidden:true];
        [addContactButton setHidden:false];
        [transferButton setHidden:true];
    }
}

- (void)setAddress:(NSString*) address {
    [addressField setText:address];
}

- (void)setTransferMode:(BOOL)atransferMode {
    transferMode = atransferMode;
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    LinphoneCallState state = (call != NULL)?linphone_call_get_state(call): 0;
    [self callUpdate:call state:state];
}

- (void)call:(NSString*)address {
    NSString *displayName = nil;
    ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:address];
    if(contact) {
        displayName = [FastAddressBook getContactDisplayName:contact];
    }
    [self call:address displayName:displayName];
}

- (void)call:(NSString*)address displayName:(NSString *)displayName {
    NSString *cleanPhoneNumber = [[LinphoneManager instance] cleanPhoneNumber:address];
    [[LinphoneManager instance] call:cleanPhoneNumber displayName:displayName transfer:transferMode];
}


#pragma mark - UITextFieldDelegate Functions

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //[textField performSelector:@selector() withObject:nil afterDelay:0];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == addressField) {
        [addressField resignFirstResponder];
    }
    return YES;
}

// Added by  on 7 March to remove warnings

+ (UICompositeViewDescription*) compositeSMSViewDescription;
{
    return nil;
}
+ (UICompositeViewDescription*) compositeSMSViewController;
{
    return nil;
}
//// End of added by 
#pragma mark - Action Functions

- (IBAction)onAddContactClick: (id) event {
    [ContactSelection setSelectionMode:ContactSelectionModeEdit];
    [ContactSelection setAddAddress:[addressField text]];
    [ContactSelection setSipFilter:nil];
    [ContactSelection setNameOrEmailFilter:nil];
    [ContactSelection enableEmailFilter:FALSE];
    /*
    ContactsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ContactsViewController compositeViewDescription] push:TRUE], ContactsViewController);
    if(controller != nil) {

    }
    */
    ContactDetailsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ContactDetailsViewController compositeViewDescription] push:TRUE], ContactDetailsViewController);
    if(controller != nil) {
        if (addressField.text.length == 0) {
            [controller newContact];
        } else {
            [controller newContact:addressField.text];
        }
    }
}

- (IBAction)onBackClick: (id) event {
    NSLog(@"Activate SMS");
    // Commented by  on 8 March for SMS Change  [[PhoneMainView instance] changeCurrentView:[InCallViewController compositeViewDescription]];
}

- (IBAction)onAddressChange: (id)sender {
    if([[addressField text] length] > 0) {
        [addContactButton setEnabled:TRUE];
        [eraseButton setEnabled:TRUE];
        [addCallButton setEnabled:TRUE];
        [transferButton setEnabled:TRUE];
    } else {
        [addContactButton setEnabled:FALSE];
        [eraseButton setEnabled:FALSE];
        [addCallButton setEnabled:FALSE];
        [transferButton setEnabled:FALSE];
    }
}
// Added by  on 7 March to remove warnings

+ (UICompositeViewDescription*) compositeProcessSMSViewDescription;
{
    return nil;
}

//// End of added by 

// Added by  on 9 March 2015 for SMS View Controller Segue

// End

// Added by  on 4 March 2015 for Activate SMS scene
- (IBAction)onActivateSMS:(id)sender {
        NSString *str_SMS_Active_State = [[NSUserDefaults standardUserDefaults] objectForKey:@"SMS_Active_State"];
    int initialValue = 1;
    NSString *initState = [NSString stringWithFormat: @"%d", initialValue];
    if (![str_SMS_Active_State isEqualToString:initState])   {
    NSLog(@"Activate SMS");

    ChatViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatViewController compositeSMSViewDescription]
                                                                                         push:TRUE], ChatViewController);
        if (controller) {
            NSLog(@"Switching view to SMS view controller");
        }
    }
    else {
        NSLog(@"The User has already been verified. Code being forwarded to SMS screen");
   /*     ChatViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatViewController compositeSMSViewController]
                                                                                             push:TRUE], ChatViewController);
    
    */
        
        smsCaspianVC *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[smsCaspianVC compositeViewDescription]
                                                                                             push:TRUE], smsCaspianVC);
        if (controller) {
            NSLog(@"Changing to smsCaspianVC View Controller");
        }
        
    }
}
// End
          
- (IBAction)onChatTap:(id)sender {
    ChatViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatViewController compositeViewDescription]
                                                                                         push:TRUE], ChatViewController);
    if (addressField.text.length != 0) {
        controller.addressField.text = addressField.text;
        [controller onAddClick:nil];
    }
}

@end
