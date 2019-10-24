# Project 2

By Jake, Toby, Christian, Cody

## Requirements

Your team is tasked with creating a website which allows the user to enter in illness symptoms they are experiencing, such as cough, headache and etc. They should then be presented with a list of possible conditions. Based on their possible conditions, recommend doctors in the area that treat their symptoms. They should also be able to schedule an appointment with a doctor.

have a MVP to present by Monday 10/28.

Due 11/4, 8:30AM in GitHub
10-20 minute presentation/demo.



Set up a GitHub repository with a protected prod branch.
You should be pushing new features to this branch. Since prod is protected, you'll have to open up PRs for each new feature. A PR should require three approvals before being merged into prod. PRs should ONLY contain commits relevant to the current feature.

You should have a prod org with DevHub enabled. This is the Org that your team will do your presentation with. This should only ever contain a stable build. You'll develop on scratch-orgs.

High Priority
* appointment booking page
* symptom checker page

Medium Priority
* user can view upcoming/past appointments
* Set up a Community
* Create a Login page

Low Priority
* Self registration Page
* use code analysis tool to measure app

## The Community and Org setup
Patients are treated as external guest users by the org with a profile limited to the community pages and their information.
The community site follows a template which allows a choice of tabs and sidebar items which can lead to our custom visualforce pages.
The log in page and registration is handled automatically, with information for on the patient stored in a contact record.
Every patient is also automatically associated with an acoount record called "Patients".


## Custom Objects

Org will use Patient and Appointment Objects to track data required for the web pages.

### Patients
The Patient is stored in salesforce using the Contact standard object
Can access the
* Name
* Contact Information
* Email

Custom Fields: Add a Gender field to Contacts which will help the symptom checker

### Doctors
Doctors with certain specialties will be tracked to the allow symptom checker to give doctor suggestions.

Doctors could simply be another type of Contact record with a picklist of specialties


### Appointment
Users can view, create appointments with certain doctors
* Date/Time
* Patient (Lookup to Contact)
* Doctor (Lookup)
* Description text field


## Page Design

First thing user sees is Login/Registration Pages.
Can login or register to create a new patient.

Patient then is logged in and can view a menu to go to the next pages:
* view appointments
* make appointments
* symptom checker

### Login Page & Registration Page
 Handled by the community automatically, but has potential to be customized.
 
 #### Login Page
* Input field for username and password
* Login button
  * On press, looks for matching username+password
    * can't find username error - prompt no user found
    * wrong password error - prompt wrong password
    * success - navigate to logged in user's menu page
* Registration link
  * Go to registration page
* Forgot Password link
  * allows password reset given a username, emails a new pass
  
#### Registration page
* Input fields to fill in each field for the new patient
* Create button
  * On press, creates new patient
    * make sure login username unique, prompt if issue creating the patient
    
### Navigation Menu Page
Buttons or other menu style to navigate to the symptom checker, appointment viewer, appointment maker
* Add a button on the pages below to navigate back to this menu

### Symptom Checker
Patient can choose a selection of symptoms, submit, then see list of possible diagnosis
* Page interacts with API to find information

### Appointment Viewer
Shows tables, one for future appointments and another past appointments for the logged in patient
* Columns for date, time, details(?)


### Appointment Maker
Wizard to create a new appointment tied to the logged in patient
* check for date conflicts with other appointments


