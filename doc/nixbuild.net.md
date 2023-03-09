nixbuild.net access
===================

The Smart Contracts tribe has a [nixbuild.net](https://nixbuild.net/) account which can be used to delegate Nix builds[^system] to powerful autoscaled hardware, with shared build results for all users of the account.

[^system]: As of this writing, only for Linux on x86 and ARM; up-to-date list of systems [here](https://docs.nixbuild.net/supported-systems/index.html).

Getting access
---------------

Pending at least the [initial prototype](https://input-output.atlassian.net/browse/PLT-4253) of the tribe-wide access control system, initial access for a user is a manual process. Please reach out to `Shea Levy` on Slack for access.

**Note that the given tokens are secrets and should be managed as such!**

Initial tokens will be set to expire around 2023-04-19, with the hope that by then an automated token server will exist. Use `biscuit inspect` (see [Managing access tokens](#managing-access-tokens)) to confirm the exact expiration.


Setting up remote builders
-------------------------

nixbuild.net has documentation for setting everything up on [NixOS](https://docs.nixbuild.net/getting-started/#quick-nixos-configuration), or for configuring [SSH](https://docs.nixbuild.net/getting-started/#ssh-configuration) and [Nix](https://docs.nixbuild.net/getting-started/#nix-configuration) separately. From there, you can find links to more detailed documentation on remote builders. However, due to our usage of biscuit tokens instead of SSH keys changes to the SSH configuration are needed.

Instead of an entry like:

```
Host eu.nixbuild.net
  PubkeyAcceptedKeyTypes ssh-ed25519
  IdentityFile /path/to/your/private/key
```

Your entry should look like:

```
# when connecting to eu.nixbuild.net
Host eu.nixbuild.net
  # don't use any authentication mechanisms SSH expects (password, SSH keys, etc.)
  PreferredAuthentications none
  # log in as the 'authtoken' user
  # The token itself contains user information that nixbuild.net needs
  User authtoken
  # Send the 'token' environment variable from Nix to nixbuild.net in the SSH session.
  SendEnv token
  # Alternatively to SendEnv, you can have a line like:
  #   SetEnv token=<token>
  # This will mean you don't have to modify Nix's environment (see below).
  # But this will involve putting your token, which is a secret, directly into
  # a configuration file.
```

and then you should ensure that the environment of your Nix daemon (or, if you're running in single-user mode, your Nix build command) has the `token` variable set to the contents of your token.

Managing access tokens
----------------------
We are using [Biscuit](biscuitsec.org/) tokens to access nixbuild.net. Among other things, these tokens allow for *offline attenuation*: If you have a token with a certain access, you can freely generate a new token with more restricted access without going through any central service. In this way, you can securely delegate capabilities; for example, given a token obtained as above, you could generate a new token that expires sooner (or, after future upgrades to nixbuild.net, can only spend a certain number of build hours per week) for use in CI.

**Note that Biscuit tokens are secrets and should be managed as such!**

There is a very rich language for attenuating biscuit tokens, and the nixbuild.net team hopes to provide various needed interfaces for limiting access based on various properties of a given build and account; see [the biscuit docs](https://www.biscuitsec.org/docs/getting-started/introduction/) for more information on the former. Currently, however, the only meaningful limitation on a token is having it expire sooner. Using the [biscuit-cli](https://lib.rs/crates/biscuit-cli)[^nixpkgs], you can achieve this with:

```shell
$ biscuit attenuate my-token --add-ttl "6 weeks" --block "" > new-token
```

This will take an existing token in the file `my-token`, adds a requirement that it only be used within the next 6 weeks, and stores the resulting token in `new-token`. The `--block ""` is needed to tell `biscuit` that you are not adding any additional policy restrictions beyond the TTL.

The `biscuit inspect` command can be used to get information about a token:

```shell
$ biscuit inspect test-token 
Authority block:
== Datalog ==
account(324);
check if time($time), $time < 2025-12-03T14:20:33Z;

== Revocation id ==
82cf79ba72cd974eb0227607f3cde9a41f252bf08ebd7f731d46e2464dbed0bb7d1a89a9aaeb67402338423688b37e07a82dbf130490f53b3d21f035478bf20a

==========

Block n°1:
== Datalog ==
user("shlevy");
check if time($time), $time <= 2023-04-18T15:53:13Z;

== Revocation id ==
b00eec83d2c05a95e9df35004635f19f0f5de138d9c125040e42db78bb41257be5b5005f5c4123b859aa130aaa639b5a789b9a1c82834c5800b8c85d58bb3603

==========

🙈 Public key check skipped 🔑
🙈 Datalog check skipped 🛡️
```

Particularly interesting information are the two time checks (both must succeed) and the two revocation IDs. The revocation IDs are automatically generated upon each successive token attenuation; in the future, nixbuild.net will support revocation lists, allowing specific tokens (including all those descending from them) to be revoked if need be.

[^nixpkgs]: Added to `nixpkgs` `master` in [NixOS/nixpkgs#220352](https://github.com/NixOS/nixpkgs/pull/220352) and `release-22.11` in [NixOS/nixpkgs#220353](https://github.com/NixOS/nixpkgs/pull/220353)
