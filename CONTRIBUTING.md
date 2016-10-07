# Contributing guidelines
Anyone is more than welcome to contribute to the Hub Framework! Together we can make the framework even more capable, and help each other fix any issues that we might find.

Before you send a PR, however, please make sure your change complies with these quick guidelines:

- Always fully unit test your code.
- Always fully document APIs, in a way that makes new users of those APIs understand how they work, and highlight things that are good to keep in mind when using them.
- Use explicit storage and nullability specifiers. We run the static analyzer on every build, and by using explicit rules about nullability we can leverage the analyzer to increase our code quality & predictability. Being explicit also lets your fellow developers easily understand the intent of the code.
- Follow our [style guide for Objective-C](https://github.com/spotify/ios-style).
- For larger API changes, it's recommended (but not required) to open an RFC using an issue, where you can get quicker feedback on your API idea instead of having to wait until it has been implemented.

## Reporting Security Issues
Spotify takes security seriously. If you discover a security issue, please bring it to our attention right away!

Please **DO NOT** file a public issue, instead report it privately to our [bounty program hosted by Bugcrowd](https://bugcrowd.com/spotify). This will help ensure that any vulnerabilities that are found can be [disclosed responsibly](http://en.wikipedia.org/wiki/Responsible_disclosure) to any affected parties.

## Code of conduct
This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.

[code-of-conduct]: https://github.com/spotify/code-of-conduct/blob/master/code-of-conduct.md
