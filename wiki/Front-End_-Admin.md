Access the admin panel by navigating to interface.specials.com/admin

### Admin Panel Features

**Upload a New .csv**
1) Drag and drop the .csv file into the uploader hitbox.

_What happens in the app logic:_
1) Client JS sends file to the Azure Webjob.
2) Webjob process data and writes it to the Firebase database
3) Client JS retrieves the new Firebase entry and displays it in the admin

**Publish a Firebase Product Dataset**
1) Select the a dataset revision from the select dropdown. 
2) Click Publish.

_What happens in the app logic:_
1) Client JS updates the Firebase production revision reference.
2) Client JS loads the Firebase production revision.

**Add a Color Tag to the Product Data**
1) Find the product in the list. 
2) Click on the input box to open the color tag list. 
3) Select a color or type in a new color.

_What happens in the app logic:_
1) Client JS updates the Firebase reference.