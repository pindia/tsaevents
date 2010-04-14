Advisor Guide
~~~~~~~~~~~~~~

As a chapter advisor, you have access to a variety of tools to make viewing and managing your chapter data easier. 

Chapter settings
===================

Basic chapter settings can be changed on the **Edit Chapter** page. The following settings are available:

* Chapter ID - Your chapter ID prefix. This is added to the beginning of all individual and team IDs.
* Allow new users - Uncheck this box to lock chapter registration. Any new user who tries to sign up into your chapter will receive an error message, so you must add new users manually.
* Key - You may enter a key that all new users must enter in order to sign up into your chapter. This is optional; leave the field blank and users will not be prompted for a key. A key is recommended as a basic security precaution to prevent anyone in the world from creating an account in your chapter. You will need to somehow inform your chapter's members of the key outside of this site.
* Chapter info - This text will be displayed to all users signing up for an account on the registration screen. Note that this will be visible to anyone in the world that selects your chapter from the main screen. You can use this text for anything you want. For instance, you could provide a hint for the key that only someone from your school would likely understand.
* Chapter message - This text will be displayed to all logged in chapter members on the main chapter page. You can use this text to advise members of what is going on in the chapter.

User management
===================

.. image:: /static/tsa/docs/member_list.png
    :align: right
    :target: /static/tsa/docs/raw/member_list.png
    
The **Member List** page is the main page for managing the members of your chapter. From here, you can view and edit the events of each member. Here is a description of the tasks you can perform on this page:

* **Add individual event:** Check the boxes next to the names of the members you wish to add the event to. Scroll to the bottom of the page, select the individual event in the top drop-down box, then click 'Update Users'.
* **Remove individual event:** Click on the red delete icon next to an individual event and confirm that you want to delete it.
* **Add a team:** Check the boxes next to the names of the members you want to be in the new team. Scroll to the bottom of the page, select the team event in the top drop-down box, then click 'Update Users'.
* **Remove a member from a team:** Click on the name of the team event to get to the team detail page. From here, click 'Remove' next to the name of the member you wish to remove.
* **Remove an entire team:** Click on the name of the team event to get to the team detail page. From here, scroll to the bottom and click 'Delete Team'.
* **Delete a member:** Check the boxes of the members you wish to delete. Scroll down and select 'Delete selected users' from the bottom drop-down box, and click 'Update Users'. Be warned that deletion is permanent and will also delete all teams the user is captain of and all team posts they have written.
* **Change account types:** The other options in the bottom drop-down box are used to change account types of members. The types are:
    1. Normal member - Can sign up for events, cannot access administrative functions
    2. Advisor - Cannot sign up for events, has full access to administrative functions
    3. Officer - Can sign up for events like normal members but has full access to administrative functions. Be careful when assigning this power; reserve it for your most trusted officers because they have total control of the chapter.
    
* **Set individual IDs:** Edit the individual IDs for each member with the text field next to there name. The chapter prefix can be changed on the `chapter settings`_ page. Click 'Update users' at the bottom when done.

Team management
===================

.. image:: /static/tsa/docs/team_list.png
    :align: right
    :target: /static/tsa/docs/raw/team_list.png

The **Team List** page provides a list of all of the teams in your chapter. The **View** link next to each team will take your to its `team detail page <member_guide#view-team-page>`_, which is the same as for its members. As an advisor, you have full administrative power over every team.

Team IDs can also be edited on the main team list page. Simply fill in the text boxes in each team's row and click 'Update IDs' at the bottom.

Teams are by default sorted by their event, and you can use the filter menu at the top to view only the teams in a certain event.

Event List
=================

.. image:: /static/tsa/docs/event_list_advisor.png
    :align: right
    :target: /static/tsa/docs/raw/event_list_advisor.png
    
As an advisor, the information displayed on the `event list <member_guide#event_list>`_ page is identical to that shown to members. However, there is an additional column of checkboxes on the left side of the list where you can lock events. After you edit the chackboxes, make sure to click 'Submit' at the bottom of the page to save your changes.

Members cannot sign up for locked individual events or create new teams for locked team events, but can join and leave existing teams in the event. You are always able to manually add individual events and create teams through the advisor interface, even for locked events.

Locking events is useful when an event has filled up, is qualification-only, or when the registration deadline has passed. See the `suggested workflow <suggested_workflow>`_ page for the method we at State High use for locking events.



Chapter Log
================

.. image:: /static/tsa/docs/chapter_log.png
    :align: right
    :target: /static/tsa/docs/raw/chapter_log.png
    
    
The **chapter log** allows you to keep track of what has been happening within your chapter's system. A log message is generated when anything changes, like new users registering, users editing events, or your officers making changes. The most recent events are shown at the top of the list.

Since it contains such detailed information, the chapter log is visible only to chapter advisors and officers. Additionally, for security reasons, log entries cannot be deleted or otherwise hidden.

Fields
==========

Fields provide a way for you to store additional information about your members. For example, you can store contact information or whether members have paid their dues, turned in certain forms, etc. This is similar to a spreadsheet, but its advantages are consolidating your data in one system, allowing multiple advisors and officers to collaborate, and allowing members to view and edit their own field values (if you allow them to).

Fields are defined in the lower section of the **Edit Chapter** page.

Defining fields
----------------

.. image:: /static/tsa/docs/edit_fields.png
    :align: right
    :target: /static/tsa/docs/raw/edit_fields.png

The currently defined fields are shown in the large table. Each fields has numerous properties:

* **Name**: The full name for the field is displayed on this page and to chapter members on their individual pages. You should be long and descriptive with this name.
* **Short Name**: The short name for the field is displayed as the column header in the Member Fields page. This should be as short as possible; long headers will unnecessarily expand the column.
* **Category**: Fields are sorted into categories. When you go to edit field values, all the fields in the 'Main' category will be displayed by default. If you have many fields, you need to use categories to split them up into multiple pages because they will not all fit. All the fields with the same category label will be displayed at once. Category labels can be any text label that you choose.
* **Weight**: Weights are used to change the order of fields within a category. Fields are sorted first by their category, then by their weight in ascending order. In the example to the right (click it to enlarge), the 'Cell number' field has risen to the top of the 'Contact' category due to its negative weight, and the 'Riding states bus' field has sunk to the bottom of the 'Main category' due to its positive weight.
* **Who may view?**: Here you set who can view the value of this field. In most cases you should set this to 'User or admin' to allow every member to see their own value of the field on their Settings page, though in some cases you may want to hide the value from them and select 'Admin only'. In no case can users see the values of other users.
* **Who may edit?**: This setting will eventually control who is able to edit the field. Currently, only advisors and officers are able to edit fields and this setting cannot be changed, but in the future you will be able to allow users to edit their own values (useful for ex. contact information), log all field edits for sensitive information like dues, or lock editing altogether.
* **Type**: There are two types of fields: Text and Boolean. Text fields may hold any value that you enter and are represented by a text box, while Boolean fields may only be Yes or No, and are represented by a checkbox. The type of a field *cannot* be changed after it is created.
* **Default**: Each field has a default value that members will have for it before it is edited. For text fields, this can be any text value, and for Boolean fields it must be Yes or No. The default value of a field *cannot* be changed after it is created.

To create a new field, fill out and submit the 'New Field' form at the very bottom of the page. Make sure the type and default value are to your liking because you cannot change these once the field is created except by deleting and recreating the field. For Boolean fields, enter either 'Yes' or 'No' into the default field, and for text fields enter any value you wish.

To delete an existing field, change its name to 'DELETE' in all caps and submit the form. Be aware that deleting a field will *irreversibly destroy* all data values in it.

Using fields
-------------

.. image:: /static/tsa/docs/member_fields.png
    :align: right
    :target: /static/tsa/docs/raw/member_fields.png

Whew! Now that you've defined your fields, you can actually use them on the **Member Fields** page. Here, you will see a list of your chapter members (not including you or other advisors), with all the fields you've defined as columns like in a spreadsheet. At the top is a series of links you can use to switch between the categories you have defined. In the example to the right, the two columns are *two different pages* that can be toggled between using the category bar.

You can use this page as you do a spreadsheet, editing the text or checkboxes. Remember to press the Submit button at the bottom of the page to save your changes.

The Member Fields screen is available only to chapter advisors and officers. Other members cannot view or edit field values unless you have allowed them to in the field configuration, and even then only their own values on their Settings page.


