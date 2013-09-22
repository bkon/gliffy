Gliffy API wrapper
==================

Basic usage
-----------

### Initialization

api = Gliffy::API.new(ACCOUNT_ID, API_KEY, API_SECRET)
api.impersonate('user@domain.com')
api.account.root.documents

### Working with documents

doc = account.document(DOCUMENT_ID)
doc.name
doc.editor(RETURN_TO, RETURN_BUTTON_TEXT)
doc.png.full

### Navigating folders

root = account.root
root.folders[0].documents
root.folders[1].name
root.folders[1].path