# Contributing to the PeakRDL-regblock-vhdl code generator
We love your input! We want to make contributing to this project as easy and
transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer


## Open an issue using the [Issue Tracker](https://github.com/SystemRDL/PeakRDL-regblock-vhdl/issues)
Talking to us is the easiest way to contribute! Report a bug or feature request by
[opening a new issue](https://github.com/SystemRDL/PeakRDL-regblock-vhdl/issues).

Issue submission expectations:
* Please keep each issue submission limited to one topic. This helps us stay organized.
* Before opening an issue, check if one already exists for your topic. It may have already been discussed.
    * Check the upstream SystemVerilog regblock exporter [issue tracker](https://github.com/SystemRDL/PeakRDL-regblock/issues) as well.
* If submitting a bug, provide enough details so we can reproduce it on our end. (version number, example SystemRDL, etc...)
* If submitting a feature request, please make sure ...
    * ... it does not violate the semantics of the SystemRDL standard.
      Submissions that would change the interpretation of the SystemRDL language
      and are not faithful to the [Accellera SystemRDL specification](http://accellera.org/downloads/standards/systemrdl) will be rejected.
      Additional notes on the spec's interpretation can be found in [our unofficial errata page](https://systemrdl-compiler.readthedocs.io/en/latest/dev_notes/rdl_spec_errata.html).
* Please be patient! This project is run by volunteers that are passionate about
  improving the state of register automation. Much of the work is done in their free time.


## Contribute code using a pull request
Pull requests are the best way to propose changes to the codebase. We actively
welcome your pull requests. To maximize the chance of your pull request getting accepted,
please review the expectations below.

Pull request expectations:
* Before starting a pull request, please consider discussing the change with us
  first by **opening an issue ticket**. Unfortunately many of the PRs that get rejected
  are because they implement changes that do not align with the  mission of this
  compiler project.
* PRs shall only contain only one feature/bug/concept change. **Bulk PRs that change numerous unrelated things will be rejected**.
* Your PR should provide proof that it works correctly and does not break the existing unit tests.
* Use meaningful commit messages, squash commits as appropriate.

How to submit a PR:
1. Fork the repo and create your feature/bugfix branch from `main`.
2. If you've added code that should be tested, add tests.
3. Ensure the test suite passes.
4. Submit the pull request!


## Any contributions you make will be under the GNU GPL-3.0 Software License
In short, when you submit code changes, your submissions are understood to be
under the same [GPL-3.0 License](https://choosealicense.com/licenses/gpl-3.0/) that
covers this project. Feel free to contact the maintainers if that's a concern.
