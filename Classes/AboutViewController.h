/* AboutViewController.h
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

#import <UIKit/UIKit.h>

#import "UICompositeViewController.h"

@interface AboutViewController : UIViewController<UICompositeViewDelegate, UIWebViewDelegate> {
}

@property (nonatomic, retain) IBOutlet UILabel *linphoneLabel;
@property (nonatomic, retain) IBOutlet UILabel *linphoneIphoneVersionLabel;
@property (nonatomic, retain) IBOutlet UILabel *linphoneCoreVersionLabel;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UILabel *linkLabel;
@property (nonatomic, retain) IBOutlet UILabel *copyrightLabel;
@property (nonatomic, retain) IBOutlet UILabel *licenseLabel;
@property (nonatomic, retain) IBOutlet UIWebView *licensesView;
@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *linkTapGestureRecognizer;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;


- (IBAction)onLinkTap:(id)sender;

@end
