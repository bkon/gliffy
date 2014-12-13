Gliffy API wrapper
==================

[![Gem Version](https://badge.fury.io/rb/gliffy.png)](http://badge.fury.io/rb/gliffy)
[![Code Climate](https://codeclimate.com/github/bkon/gliffy.png)](https://codeclimate.com/github/bkon/gliffy)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/bkon/gliffy/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

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

    doc.public?
    doc.public = false

#### Download document as PNG

    doc.png.full
    doc.png.medium
    doc.png.small
    doc.png.thumbnail

#### Obtain a link to the PNG
    doc.png_url 'L' # Large (original) size

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

    folder.users
    folder.grant_access(user)
    folder.revoke_access(user)

### Users

    account.users

    account.users[0].username
    account.users[1].email

    account.create_user("john-smith")

    user.email = "new-email@test.com"
    user.password = "new-password"
    user.admin = true

    user.accessible_folders

Command-line client
-------------------

### Authenticating yourself to gliffy API

CLI client looks for credentials in `~/.gliffy-cli` file by default. It is
a YAML file with a following simple structure:

    gliffy:
      account: <YOUR ACCOUNT ID>
      oauth:
        consumer_key: <YOUR OAUTH CONSUMER KEY>
        consumer_secret: <YOUR OAUTH CONSUMER SECRET>

An alternative ways to specify API credentials are:
* use `--credentials` flag
```
gliffy-cli --credentials <PATH TO CREDENTIALS FILE> ...
```
* use `--account-id`, `--consumer-key` and `--consumer-secret` flags
```
gliffy-cli --account-id <ID> --consumer-key <KEY> --consumer-secret <SECRET> ...
```

The next step is to impersonate an user:

```
gliffy-cli ... --user <USERNAME> ...
```

Keep in mind that new users are provisioned automatically, so if
`<USERNAME>` does not exists, it will be created for you by Gliffy.

### List of available commands:

* `user add <USERNAME>`
* `user delete <USERNAME>`
* `user list`
* `user update email <USERNAME>`
* `user update password <USERNAME>`
* `user admin grant <USERNAME>`
* `user admin revoke <USERNAME>`
* `document add`
* `document content <ID>.<FORMAT>`
* `document name <ID>.<FORMAT>`
* `document delete <ID>`
* `document rename <ID> <NAME>`
* `document access public <ID>`
* `document access private <ID>`
* `folder documents <PATH>`
* `folder folders <PATH>`
* `folder users <PATH>`
* `folder access grant <PATH> <USERNAME>`
* `folder access revoke <PATH> <USERNAME>`
* `folder document create <PATH> <DOCUMENT>`
* `folder create <PATH>`
* `folder delete <PATH>`

### Misc functionality

* `--log-http` enables HTTP requests and response logging to STDERR
