# Gitup!

__Scenario:__ You are working on a simple web site. You make some changes to a bunch of files. You need to upload the changed files to the server (just SFTP, no fancy deployment or anything). Who knows what files you've modified in the past few days? Well, git knows. Run `gitup --since="last wednesday"`, and you're done.

# Installation

Put gitup.rb somewhere and alias it as `gitup`.

# Requirements

* Mac OS X
* Ruby (of course)
* Git
* [preferably] Transmit

Gitup is a Ruby script. It is intended to work on __OS X in conjunction with Git and Transmit__ using Transmit's _Dock Send_ feature. You need Ruby installed to run it. If you don't use a Mac, Git and Transmit, Gitup probably won't do you much good.

The one exception is if you have an app to which you want to send files other than Transmit. It can do that. You just have to specify the app.

# Usage

If you run gitup -h, you'll see this:

    Usage: gitup.rb [-s|--skip-preview] [--application=<app_name>] <git-log options>
    Calling gitup.rb without arguments will build the file list from the most recent commit.
    See Commit Limiting in git-log help for options on specifying the commits.
    
    Other options:
      --application=<app_name>   Specify an application other than Transmit.
      -h, --help                 Show this message.
      -s, --skip-preview         Send files straight to Transmit without a prompt.
        
That pretty much explains it. Run `git help log` to see how to specify exactly which commits you want to use.

# Examples

Send files modified in the last commit to Transmit (Gitup will let you know how many files will be sent and offer you the option to view a list of the files or abort.):

    gitup

Send files modified in the last 3 commits to Transmit:

    gitup -3

Send files modified in the last 3 commits to Transmit immediately (no prompting or anything):

    gitup -s -3
    
Send files modified since yesterday to Transmit:

    gitup --since=yesterday
    
Send files modified since Monday to Transmit (quotes are required):

    gitup --since="last monday"
    
Send files since the specified commit to Transmit:

    gitup dcd2c68..
    
Send files between the two specified commits to Textmate:

    gitup --application=Textmate dcd2c68..bf75dd6
    
# BETA WARNING

___This script was hacked together in a short time to scratch an itch. It works for me (using Git 1.6, Leopard, and Transmit), but systems vary greatly. USE GITUP AT YOUR OWN RISK!! I AM NOT RESPONSIBLE FOR DAMAGE CAUSED BY THIS SCRIPT.___

You may very well know more about Ruby and Git than I do. If you find any flaws with this code or have any recommendations as to how it can be improved, please fork it and let me know.