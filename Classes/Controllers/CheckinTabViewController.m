/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import "CheckinTabViewController.h"
#import "BaseTabViewController.h"
#import "CheckinTableViewController.h"
#import "CheckinMapViewController.h"
#import "SettingsViewController.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"

@interface CheckinTabViewController ()

@property(nonatomic, retain) UserDialog *userDialog;

- (void) showInfoOnceOnly;

@end

@implementation CheckinTabViewController

@synthesize checkinTableViewController, checkinMapViewController, userDialog;

#pragma mark -
#pragma mark Handlers

- (IBAction) viewModeChanged:(id)sender {
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	BOOL populate = NO;
	BOOL animate = (segmentControl.tag == ShouldAnimateYes);
	BOOL resize = NO;
	if (segmentControl.selectedSegmentIndex == ViewModeTable) {
		if (self.checkinTableViewController.deployment != self.deployment) {
			self.checkinTableViewController.deployment = self.deployment;
			populate = YES;
			resize = YES;
		}
		DLog(@"ViewModeTable populate:%d animate:%d", populate, animate);
		[self showViewController:self.checkinTableViewController animated:animate];
		[self.checkinTableViewController populate:populate];
		segmentControl.tag = ShouldAnimateYes;
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeMap) {
		if (self.checkinMapViewController.deployment != self.deployment) {
			self.checkinMapViewController.deployment = self.deployment;
			populate = YES;
			resize = YES;
		}
		DLog(@"ViewModeMap populate:%d animate:%d resize:%d", populate, animate, resize);
		[self showViewController:self.checkinMapViewController animated:animate];
		[self.checkinMapViewController populate:populate resize:resize];
		segmentControl.tag = ShouldAnimateYes;
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setBackButtonTitle:NSLocalizedString(@"Checkins", nil)];
	self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
	self.userDialog = [[UserDialog alloc] initForDelegate:self];
} 

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"willBePushed: %d", self.willBePushed);
	if (self.checkinTableViewController.view.superview == nil && 
		self.checkinMapViewController.view.superview == nil) {
        DLog(@"XXXXXXXXXXXXX %d", self.willBePushed);
		self.checkinTableViewController.deployment = self.deployment;
		[self.checkinTableViewController populate:self.willBePushed];
		[self showViewController:self.checkinTableViewController animated:NO];
	}
	else if (self.checkinTableViewController.view.superview != nil) {
        DLog(@"YYYYYYYYYYYYY %d", self.willBePushed);
		[self.checkinTableViewController populate:self.willBePushed];
	}
	else if (self.checkinMapViewController.view.superview != nil) {
        DLog(@"ZZZZZZZZZZZZZ %d", self.willBePushed);
		[self.checkinMapViewController populate:self.willBePushed 
										 resize:self.willBePushed];
	}
	if ([self.viewMode numberOfSegments] >= ViewModeCheckin + 1) {
		self.viewMode.tag = ShouldAnimateNo;
		if (self.viewMode.selectedSegmentIndex == ViewModeCheckin) {
			[self.viewMode setSelectedSegmentIndex:ViewModeTable];
		}
		else {
			NSInteger selectedSegmentIndex = self.viewMode.selectedSegmentIndex;
			[self.viewMode setSelectedSegmentIndex:UISegmentedControlNoSegment];
			[self.viewMode setSelectedSegmentIndex:selectedSegmentIndex];
		}
		[self.viewMode removeSegmentAtIndex:ViewModeCheckin animated:NO];
	}
	if ([Device isIPad]) {
		[self.viewMode setFrameWidth:150];
	}
	else {
		[self.viewMode setFrameWidth:80];
	}
	if (animated) {
		[[Settings sharedSettings] setLastIncident:nil];
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([[Settings sharedSettings] hasFirstName] == NO && 
		[[Settings sharedSettings] hasLastName] == NO &&
		[[Settings sharedSettings] hasEmail] == NO) {
		[self.userDialog showWithTitle:NSLocalizedString(@"Contact Settings", nil) 
								 first:[[Settings sharedSettings] firstName] 
								  last:[[Settings sharedSettings] lastName]  
								 email:[[Settings sharedSettings] email]];
	}
	else {
		[self showInfoOnceOnly];
	}
}

- (void)dealloc {
	[checkinTableViewController release];
	[checkinMapViewController release];
	[super dealloc];
}

- (void) showInfoOnceOnly {
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"This map supports Checkins!\nClick the Filter button to only show checkins for a specific user or the Pin button to checkin now.", nil)];	
}

#pragma mark -
#pragma mark UserDialog

- (void) userDialogReturned:(UserDialog *)dialog first:(NSString *)first last:(NSString *)last email:(NSString *)email {
	[[Settings sharedSettings] setFirstName:first];
	[[Settings sharedSettings] setLastName:last];
	[[Settings sharedSettings] setEmail:email];
	[self showInfoOnceOnly];
}

- (void) userDialogCancelled:(UserDialog *)dialog {
	[self showInfoOnceOnly];
}

@end
