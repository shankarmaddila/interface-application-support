### File Uploads
The local server will serve assets from the build directory but also handle GET and POST requests to the `upload` dir.
A small server script handles the file upload. This will take a file POST and upload to Azure file storage and report back the url.

### Azure Webjob 
When the server starts a webjob, you can view its status Azure:
http://interface-specials-framework.azurewebsites.net/api/publish/history

Additional monitoring and status tools are available in the Azure portal.