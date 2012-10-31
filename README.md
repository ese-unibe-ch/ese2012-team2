ese2012-team2
=============

===================================
INSTALLATION
===================================

prerequisites: Ruby 1.8.7 installed

1. install Bundler with

    'gem install bundler'

2. install needed gems by running

    'bundle install'

    from the app root.

3. install ImageMagick library

    3.1 OSX

        use homebrew: http://mxcl.github.com/homebrew/

        then run 'brew install imagemagick'

    3.2. Linux (Deb,Ubuntu)

        run 'sudo apt-get install imagemagick'

    3.3. Windows

        see: http://www.imagemagick.org/script/binary-releases.php#windows

===================================
Running Tests
===================================

Please run the tests from within RubyMine with the option "All tests in folder" and the file name mask pattern: "**/{*_test,test_*}.rb"

===================================
STARTUP
===================================

   run 'ruby app.rb' from any directory (in trade/app)

   NOTE: starting the app from within the RubyMine IDE will not work for image resizing because the
   PATH environment variable needs to be accessed in order to call the command
   line interface of the ImageMagick library.

    user "ese" has password "qwertzuiop" (like every other user, check the test_data.json file for some more users...)