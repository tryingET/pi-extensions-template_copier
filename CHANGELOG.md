# Changelog

## [0.4.0](https://github.com/tryingET/pi-extensions-template_copier/compare/v0.3.0...v0.4.0) (2026-02-26)


### Features

* add context-aware intake scaffolding and security dependency updates ([7cc7600](https://github.com/tryingET/pi-extensions-template_copier/commit/7cc76001be7bb88cb921db14710c8ea7f0650334))
* add pinned dependency update checker ([c86605a](https://github.com/tryingET/pi-extensions-template_copier/commit/c86605a7e0ff0816aac7fa052d0c2246af32a5d6))
* **scaffold:** add release-check baseline for generated repos ([f0b0d5a](https://github.com/tryingET/pi-extensions-template_copier/commit/f0b0d5a057ebdd9ee150768f6982101a601c4dee))
* **template:** add context-aware startup intake scaffolding ([cc01dc6](https://github.com/tryingET/pi-extensions-template_copier/commit/cc01dc677fe5c4ab3be45768f10629ade7bee431))
* **template:** add npm bootstrap publish helper ([e83fabf](https://github.com/tryingET/pi-extensions-template_copier/commit/e83fabf8c0c2a815bdeba81199d8e46d0e52b721))
* **template:** add npm release automation for template package ([90c0cd9](https://github.com/tryingET/pi-extensions-template_copier/commit/90c0cd9f792f04adeadc65e793a6f1ff504fc923))
* **template:** add profile-driven intake scaffolding ([0fe229d](https://github.com/tryingET/pi-extensions-template_copier/commit/0fe229d35e49cb26119a3670662412337a875023))
* **template:** add root vouch/issue templates and maintainer seeding ([064b474](https://github.com/tryingET/pi-extensions-template_copier/commit/064b47405638e3d8b4b94cd6596c62ee5cc6c9c4))
* **template:** add TS quality gate lane baseline ([dd52446](https://github.com/tryingET/pi-extensions-template_copier/commit/dd524462fd9523189ff0270166e6da1bc0246112))
* **template:** convert CODEOWNERS to jinja template ([08e278f](https://github.com/tryingET/pi-extensions-template_copier/commit/08e278f6ff723ba1d74c80a4eef9e1ed0ec64477))
* **template:** harden biome-first scaffold defaults ([7002230](https://github.com/tryingET/pi-extensions-template_copier/commit/70022306967e31d8791d101460158992c1523c24))
* **template:** make release-check.sh test settings configurable ([a1e03f5](https://github.com/tryingET/pi-extensions-template_copier/commit/a1e03f5f775d893fdbed2c86a092fab2bd23a697))
* **template:** package live-sync extension layout ([b5899c0](https://github.com/tryingET/pi-extensions-template_copier/commit/b5899c0d7baeee7927cdcaaddd09f3575b6f8f22))
* **template:** run node tests in generated quality gate ([cf63bf0](https://github.com/tryingET/pi-extensions-template_copier/commit/cf63bf0fe41abdfdb7db23fca60f11aabcae3290))
* **tooling:** add justfile for template maintenance tasks ([9eeaec4](https://github.com/tryingET/pi-extensions-template_copier/commit/9eeaec4460f544845da7adf074945683586da953))
* **tooling:** add update-generated-repos.sh for batch template sync ([8c02014](https://github.com/tryingET/pi-extensions-template_copier/commit/8c020148146cb53b623d60162e2ec7764793f0ab))


### Bug Fixes

* **release:** add provenance-safe repository metadata ([e737b23](https://github.com/tryingET/pi-extensions-template_copier/commit/e737b23a356c1ba922e4cc4025027e665f9c5084))
* **release:** stabilize release-check after first publish ([ab0ad66](https://github.com/tryingET/pi-extensions-template_copier/commit/ab0ad66716b984646f637dd8f4918867e86a477b))
* **scripts:** pre-commit only validates staged files ([76aeb0f](https://github.com/tryingET/pi-extensions-template_copier/commit/76aeb0fde5cc41124840965c930741de87c1c247))
* **security:** pin fast-xml-parser and add dependabot ([1fd9880](https://github.com/tryingET/pi-extensions-template_copier/commit/1fd98802cd79d65268febb670247607d8cdf27ff))
* **template:** default local scaffolding to HEAD for path2 knobs ([012aa2e](https://github.com/tryingET/pi-extensions-template_copier/commit/012aa2e0748bf8d3b86f40f74696a02422120c57))
* **update:** add --overwrite to recopy for conflict resolution ([7060cdb](https://github.com/tryingET/pi-extensions-template_copier/commit/7060cdb6da5f72cde65795df7271aee2fda48e58))

## [Unreleased]

### Features
* **tooling:** add justfile for template maintenance tasks
* **tooling:** add update-generated-repos.sh for batch template sync
* **template:** update interview tool config (later removed)
* **template:** make release-check.sh test settings configurable
* **template:** convert CODEOWNERS to jinja template
* **template:** extract validation to mjs and add sync-to-live symlink mode
* add pinned dependency update checker

### Changes
* **template:** remove startup intake workflow from scaffold (simplified)
* **cli:** remove intake options from generator wrappers
* **docs:** consolidate next_steps into NEXT_SESSION_PROMPT

### Fixes
* **scripts:** pre-commit only validates staged files
* **update:** add --overwrite to recopy for conflict resolution

### Maintenance
* **validation:** remove unused docs scaffolding (skills, goals, status, plans)
* **validation:** simplify required structure for generated repos

## [0.3.0](https://github.com/tryingET/pi-extensions-template_copier/compare/v0.2.1...v0.3.0) (2026-02-18)


### Features

* add context-aware intake scaffolding and security dependency updates ([7f5d144](https://github.com/tryingET/pi-extensions-template_copier/commit/7f5d1448dc7b93652bdb3cd60c9928dbbd8c73c7))
* **template:** add context-aware startup intake scaffolding ([402fa19](https://github.com/tryingET/pi-extensions-template_copier/commit/402fa19e6c4cd1450c7b1bb122fcaad39761bf2b))


### Bug Fixes

* **security:** pin fast-xml-parser and add dependabot ([a5209dd](https://github.com/tryingET/pi-extensions-template_copier/commit/a5209dd117a7234e4edccd5f815ad9a6b5dd2064))

### Maintenance

* update GitHub Actions majors to `actions/checkout@v6`, `actions/setup-node@v6`, `actions/setup-python@v6`, and `actions/upload-artifact@v6` across root/template workflows; close superseded Dependabot PRs ([9c02233](https://github.com/tryingET/pi-extensions-template_copier/commit/9c02233910d87f7088e6076f58f481f8303469f5))
* set `package-manager-cache: false` for `setup-node@v6`, document self-hosted runner requirement (`>=2.327.1`), and extend Dependabot to monitor `/copier-template` workflows ([9c02233](https://github.com/tryingET/pi-extensions-template_copier/commit/9c02233910d87f7088e6076f58f481f8303469f5))

## [0.2.1](https://github.com/tryingET/pi-extensions-template_copier/compare/v0.2.0...v0.2.1) (2026-02-18)


### Bug Fixes

* **release:** add provenance-safe repository metadata ([3ad4639](https://github.com/tryingET/pi-extensions-template_copier/commit/3ad4639eaac18606e38a99b5e898648be9d61b8d))

## [0.2.0](https://github.com/tryingET/pi-extensions-template_copier/compare/v0.1.0...v0.2.0) (2026-02-18)


### Features

* **scaffold:** add release-check baseline for generated repos ([f0b0d5a](https://github.com/tryingET/pi-extensions-template_copier/commit/f0b0d5a057ebdd9ee150768f6982101a601c4dee))
* **template:** add npm bootstrap publish helper ([e83fabf](https://github.com/tryingET/pi-extensions-template_copier/commit/e83fabf8c0c2a815bdeba81199d8e46d0e52b721))
* **template:** add npm release automation for template package ([90c0cd9](https://github.com/tryingET/pi-extensions-template_copier/commit/90c0cd9f792f04adeadc65e793a6f1ff504fc923))
* **template:** add profile-driven intake scaffolding ([0fe229d](https://github.com/tryingET/pi-extensions-template_copier/commit/0fe229d35e49cb26119a3670662412337a875023))
* **template:** add root vouch/issue templates and maintainer seeding ([064b474](https://github.com/tryingET/pi-extensions-template_copier/commit/064b47405638e3d8b4b94cd6596c62ee5cc6c9c4))
* **template:** add TS quality gate lane baseline ([dd52446](https://github.com/tryingET/pi-extensions-template_copier/commit/dd524462fd9523189ff0270166e6da1bc0246112))
* **template:** harden biome-first scaffold defaults ([7002230](https://github.com/tryingET/pi-extensions-template_copier/commit/70022306967e31d8791d101460158992c1523c24))
* **template:** package live-sync extension layout ([b5899c0](https://github.com/tryingET/pi-extensions-template_copier/commit/b5899c0d7baeee7927cdcaaddd09f3575b6f8f22))
* **template:** run node tests in generated quality gate ([cf63bf0](https://github.com/tryingET/pi-extensions-template_copier/commit/cf63bf0fe41abdfdb7db23fca60f11aabcae3290))


### Bug Fixes

* **release:** stabilize release-check after first publish ([ab0ad66](https://github.com/tryingET/pi-extensions-template_copier/commit/ab0ad66716b984646f637dd8f4918867e86a477b))
* **template:** default local scaffolding to HEAD for path2 knobs ([012aa2e](https://github.com/tryingET/pi-extensions-template_copier/commit/012aa2e0748bf8d3b86f40f74696a02422120c57))

## Changelog

All notable changes to this project will be documented in this file.
