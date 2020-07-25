# Test suite

This folder contains scripts to fire a batch of tests against the server. The script output will give you the details and a detailed transaction log will be available on a file called `test.log`

The main purpose is to serve as a validation point in the development process, for now we can only test the SMTP/SSMTP/SMTPS server but more test can be added in the future.

This tests can validate a working server for your curiosity or function as a check point for developers implementing new features

## What are we testing (so far)

- You can receive emails for your domain
- Authentication for the domain users is working while sending email via any secure protocol
- Authenticated users can send emails to the outside world
- Your server reject unknown recipients
- Your server is not and open relay
- The server rejects relaying mail though unauthenticated secure protocols
- The server does NOT allow id spoofing
- Mail size restriction is working
- National user's restrictions
- Local user's restrictions

## Assumptions and basic configuration

This scripts are designed to be run from a PC with access to the server but outside the address declared on the `MYNETWORK` variable in the `mailad.conf` file or they will give false results

This scripts has a few dependencies not satisfied by the `make deps` command and you can trigger the install of them using the command  `make test_deps`

The scripts does not work alone, you mut clone the repository and overwrite the default `mailad.conf` file from your server, also for authenticated purposes you must define a file named `.mailadmin.auth` _(note the dot at the beginning of the name)_ in the test folder with a text like this:

``` sh
PASS='sd!in0hfn8so2.d6iSf0hGdpfh'

# national user and credentials
NACUSER="starf@mailad.cu"
NACUSERPASSWD='$1mpl3r'

# local user and credentials
LOCUSER="pepa@mailad.cu"
LOCUSERPASSWORD='0 $1mp734'

```

Let's explain:

- PASS: Yes, that's the password for the user you declared in the `mailad.conf` file as the **ADMINMAIL**, remember to remove that file after testing
- NACUSER / NACUSERPASSWD: credentials for an user that has ONLY national access, see [Optional user privilege access via AD groups](Features.md#optional-user-privilege-access-via-ad-groups)
- LOCUSER / LOCUSERPASSWD: credentials for an user that has ONLY national access, see [Optional user privilege access via AD groups](Features.md#optional-user-privilege-access-via-ad-groups)

This file is and will be not tracked by git if you push your particular repo to a public server, but it's recommended that you erase the file ASAP when you are done testing

You need to copy the default config for your domain in a special file named `.mailad.test`, simply run this on the folder if your `mailad.conf` file is a copy of the one in teh mail server:

``` sh
cp mailad.conf .mailad.test
```

## How to test it

0. Clone the repository or copy over the mailad folder from the server to the PC you will use for testing
0. Create a file named `.mailadmin.auth` with the mail administrator password (see the previous section)
0. Create a local copy of the config used in the server in a test point (see the previous section regarding the `.mailad.test` file)
0. Install test dependencies with `make test-deps`
0. Setup the test env with the command `make test-setup` this will prepare the tests and configs (remember the `.mailad.test` file?)
0. Run the tests with `make test`

Developers my take a peek on the Makefile for targets like "test-reset" and others

If the script found an error it will output an error in the console and then a transaction log tail about the error.
