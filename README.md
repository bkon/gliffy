Gliffy API wrapper
==================

[![Gem Version](https://badge.fury.io/rb/gliffy.png)](http://badge.fury.io/rb/gliffy)
[![Code Climate](https://codeclimate.com/github/bkon/gliffy.png)](https://codeclimate.com/github/bkon/gliffy)

Basic usage
-----------

### Initialization

    api = Gliffy::API.new(ACCOUNT_ID, API_KEY, API_SECRET)
    api.impersonate('user@domain.com')
    api.account.root.documents

### Working with documents

    doc = account.document(DOCUMENT_ID)

    doc.name
    doc.rename("NEW NAME")

    doc.editor(RETURN_TO, RETURN_BUTTON_TEXT)

    doc.delete

#### Download document as PNG

    doc.png.full
    doc.png.medium
    doc.png.small
    doc.png.thumbnail

#### Download document as SVG

    doc.svg.content

#### Download document as XML

    doc.xml.content

### Working with folders

    root = account.root
    root.folders[0].documents
    root.folders[1].name
    root.folders[1].path

    folder.delete

### Users

    account.users

    account.users[0].username
    account.users[1].email

    account.create_user("john-smith")
