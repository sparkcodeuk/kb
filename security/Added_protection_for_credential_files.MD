# Added protection for your important credential files

Dotfiles and dotdirs like `~/.ssh`, `~/.aws` and the like can often contain juicy information for hackers.

You can of course (and should) protect your SSH private keys with a passphrase and ideally your AWS IAM credentials would be stored via something like [aws-vault](https://github.com/99designs/aws-vault) and not `~/.aws/credentials`.

In fact some things you should have already done before you even bother with this:

* A decent account password and system configured to lock when you walk away from your machine
* Full disk encryption (e.g., OSX filevault)
* Other application specific best-practices (e.g., SSH passphrases, secure credential storage wherever possible etc.)

But that still leaves things like your `~/.ssh/config` hanging out in the wind, cached SSH identities and other goodies that might prove useful for reconnaissance prior to attack.

## Implementation

A good kill-switch for when I go to lunch or otherwise leave my computer for a while is to have all these files in an encrypted sparsebundle (OSX) and symlink to them from my homedir.

So my home dir for my important credential files/dirs looks like this:

```text
.aws             -> /Volumes/privatedata/DOTDIRS/.aws
.b2_account_info -> /Volumes/privatedata/DOTDIRS/.b2_account_info
.ssh             -> /Volumes/privatedata/DOTDIRS/.ssh
```

I then, having moved these files into place, create an alias file on my desktop to the "privatedata" sparsebundle so I can quickly mount it with a double-click & password.

So even if I've cached my SSH identity for the day, if I need to protect against any access that would otherwise be granted with it, I just need to right-click the mounted volume on the desktop and eject it and things are left safely before I lock my computer.

## Other notes

* Don't add the password you use to mount the sparsebundle into your OSX keyring, you should enter it each time you mount it
* If you close your machine (sleep/shutdown) eject the volume to keep things safe
