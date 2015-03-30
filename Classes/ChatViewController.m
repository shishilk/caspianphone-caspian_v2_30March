/* ChatViewController.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
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

#import "ChatViewController.h"
#import "PhoneMainView.h"

@implementation ChatViewController

@synthesize tableController;
@synthesize editButton;
@synthesize addressField;

#pragma mark - Lifecycle Functions

- (id)init {
    return [super initWithNibName:@"ChatViewController" bundle:[NSBundle mainBundle]];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [tableController release];
    [editButton release];
    [addressField release];
    
    [super dealloc];
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set selected+over background: IB lack !
    [editButton setBackgroundImage:[UIImage imageNamed:@"chat_ok_over.png"]
                forState:(UIControlStateHighlighted | UIControlStateSelected)];
    
    [LinphoneUtils buttonFixStates:editButton];

    [tableController.tableView setBackgroundColor:[UIColor clearColor]]; // Can't do it in Xib: issue with ios4
    [tableController.tableView setBackgroundView:nil]; // Can't do it in Xib: issue with ios4
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(textReceivedEvent:) 
                                                 name:kLinphoneTextReceived
                                               object:nil];
    if([tableController isEditing])
        [tableController setEditing:FALSE animated:FALSE];
    [editButton setOff];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kLinphoneTextReceived
                                                  object:nil];
}


#pragma mark - Event Functions

- (void)textReceivedEvent:(NSNotification *)notif {
    [tableController loadData];
}


#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"Chat" 
                                                                content:@"ChatViewController" 
                                                               stateBar:nil 
                                                        stateBarEnabled:false 
                                                                 tabBar: @"UIMainBar" 
                                                          tabBarEnabled:true 
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
        compositeDescription.statusBarMargin = 0.0f;
        compositeDescription.darkBackground = NO;
        compositeDescription.statusBarColor = [UIColor colorWithWhite:0.935f alpha:0.0f];
    }
    return compositeDescription;
}

// Added by  on 9 March 2015 for SMS View Controller Segue
static UICompositeViewDescription *smsConversationController = nil;

+ (UICompositeViewDescription *)smsConversationViewController {
    if(smsConversationController == nil) {
        smsConversationController = [[UICompositeViewDescription alloc] init:@"SMSConversationViewController"
                                                                content:@"SMSConversationViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar: @"UIMainBar"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
        smsConversationController.statusBarMargin = 0.0f;
        smsConversationController.darkBackground = NO;
        smsConversationController.statusBarColor = [UIColor colorWithWhite:0.935f alpha:0.0f];
    }
    return smsConversationController;
}

// End

// Added by  on 4 March 2015 for Activate SMS scene

static UICompositeViewDescription *compositeSMSDescription = nil;

+ (UICompositeViewDescription *)compositeSMSViewDescription {
    if(compositeSMSDescription == nil) {
        compositeSMSDescription = [[UICompositeViewDescription alloc] init:@"ActivateSMSViewController"
                                                                content:@"ActivateSMSViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar: @"UIMainBar"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
    //    compositeSMSDescription.statusBarMargin = 0.0f;
     //   compositeSMSDescription.darkBackground = NO;
       // compositeSMSDescription.statusBarColor = [UIColor colorWithWhite:0.935f alpha:0.0f];
    }
    return compositeSMSDescription;
}

static UICompositeViewDescription *compositeProcessSMSDescription = nil;

+ (UICompositeViewDescription *)compositeProcessSMSViewDescription {
    if(compositeProcessSMSDescription == nil) {
        compositeProcessSMSDescription = [[UICompositeViewDescription alloc] init:@"ProcessSMSViewController"
                                                                   content:@"ProcessSMSViewController"
                                                                  stateBar:nil
                                                           stateBarEnabled:false
                                                                    tabBar: @"UIMainBar"
                                                             tabBarEnabled:true
                                                                fullscreen:false
                                                             landscapeMode:[LinphoneManager runningOnIpad]
                                                              portraitMode:true];
        //    compositeSMSDescription.statusBarMargin = 0.0f;
        //   compositeSMSDescription.darkBackground = NO;
        // compositeSMSDescription.statusBarColor = [UIColor colorWithWhite:0.935f alpha:0.0f];
    }
    return compositeProcessSMSDescription;
}

static UICompositeViewDescription *compositeSMSViewController = nil;

+ (UICompositeViewDescription *)compositeSMSViewController {
    if(compositeSMSViewController == nil) {
        compositeSMSViewController = [[UICompositeViewDescription alloc] init:@"smsCaspianVC"
                                                                      content:@"smsCaspianVC"
                                                                     stateBar:nil
                                                              stateBarEnabled:false
                                                                       tabBar: @"UIMainBar"
                                                            tabBarEnabled:true
                                                                   fullscreen:false
                                                                landscapeMode:[LinphoneManager runningOnIpad]
                                                                 portraitMode:true];
            compositeSMSDescription.statusBarMargin = 0.0f;
           compositeSMSDescription.darkBackground = NO;
        
        compositeSMSDescription.statusBarColor = [UIColor colorWithWhite:0.935f alpha:0.0f];
    }
    return compositeSMSViewController;
}

// End of added by  for Activate SMS scene

#pragma mark - Action Functions

-(void) startChatRoom {
	//Push ChatRoom
    LinphoneChatRoom* room = linphone_core_get_or_create_chat_room([LinphoneManager getLc], [addressField.text UTF8String]);
    if( room != nil ){
	ChatRoomViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription] push:TRUE], ChatRoomViewController);
	if(controller != nil) {
        LinphoneChatRoom* room = linphone_core_get_or_create_chat_room([LinphoneManager getLc], [addressField.text UTF8String]);
		[controller setChatRoom:room];
	}
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid address", nil)
                                                        message:@"Please specify the entire SIP address for the chat"
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
	addressField.text = @"";
	
}
- (IBAction)onAddClick:(id)event {
    if ([[addressField text ]length] == 0) { // if no address is manually set, lauch address book
		[ContactSelection setSelectionMode:ContactSelectionModeMessage];
		[ContactSelection setAddAddress:nil];
		[ContactSelection setSipFilter: [LinphoneManager instance].contactFilter];
		[ContactSelection enableEmailFilter:FALSE];
		[ContactSelection setNameOrEmailFilter:nil];
		[[PhoneMainView instance] changeCurrentView:[ContactsViewController compositeViewDescription] push:TRUE];
	} else {
		[self startChatRoom]; 
	}
}

- (IBAction)onEditClick:(id)event {
    [tableController setEditing:![tableController isEditing] animated:TRUE];
}

#pragma mark - UITextFieldDelegate Functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [addressField resignFirstResponder];
    if ([[addressField text ]length]> 0) 
		[self startChatRoom];
	return YES;
}
@end
