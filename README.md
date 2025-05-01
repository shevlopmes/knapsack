If you're using SWI-Prolog:

In command line write swipl -s main.pl -- main  (this will run an app with argument "main" which triggers the default mode)

There's an interface for tests on some pre-determined data. For it you should write swipl -s main.pl -- test

If you're using GNU Prolog:

write gprolog --consult-file main.pl

Then for default mode make a query ?- userinput.

For tests make a query ?- test.
