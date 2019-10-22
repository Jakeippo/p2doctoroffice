# Project 2

By Jake, Toby, Christian, Cody

## Requirements

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

## Custom Objects

Org will use Patient and Appointment Objects to track data required for the web pages.

### Patient
Fields:
* Name
* Contact Information
* Email
* Password for login


### Appointment

* Date/Time
* Patient (Lookup)
* Description text field


## Page Design

First thing user sees is Login/Registration Pages.
Can login or register to create a new patient.

Patient then is logged in and can view a menu to go to the next pages:
view appointments
make appointments
symptom checker

### Login Page
* Input field for username and password
* Login button
  * On press, looks for matching username+password
    * can't find username error - prompt no user found
    * wrong password error - prompt wrong password
    * success - navigate to logged in user's menu page
* Registration button
  * Go to registration page
  
### Registration page
* Input fields to fill in each field for the new patient
* Create button
  * On press, creates new patient
    * make sure login username unique, prompt if issue creating the patient
    
### Navigation Menu Page
Buttons or other menu style to navigate to the symptom checker, appointment viewer, appointment maker
* Allow 

### Symptom Checker
Patient can choose a selection of symptoms, submit, then see list of possible diagnosis
* Page interacts with API to find information

### Appointment Viewer
Shows table or other view both for future appointments and past appointments of the logged in patient


### Appointment Maker
Wizard to create a new appointment tied to the logged in patient
* check for date conflicts with other appointments


