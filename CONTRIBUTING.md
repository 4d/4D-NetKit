# Contributing

All contributors are welcome to this project in the form of feedback, bug reports and even better - pull requests

## Issues

Issues are used to track **bugs** and **feature requests**.

* Before reporting a bug or requesting a feature, run a few searches to
see if a similar issue has already been opened and ensure you’re not submitting
a duplicate.

### Bugs

* Describe steps to reproduce
* Full error message if any
* Your code if relevant

Of course you could propose a fix using pull request

## Pull Request Guidelines

* Open a single Pull Request for each subject.
* Prefer to develop in a topic branch, not in `main` (feature/name, fix/name)
* Update documentation where applicable.
* If any bug related, add `#<id>` in commit message or pull request
* Test your code
* ⚠️ You need to sign the [Contribution Licence Agreement](cla/4DCLA.md) for the first pull request

### Method properties

* Methods must be private ie. set invisible by default, if not documented and not to be acceded from outside.
* Method must be set preemptive if possible.

### Naming rules

* Create a folder by category
  * Create a `Compiler_categoryName` inside each folders for compilation declarations

### Only touch relevant files

* Make sure your PR stays focused on a single feature or category.
* Don't change project configs or any files unrelated to the subject you're working.
* Don't reformat code you don't modify.
