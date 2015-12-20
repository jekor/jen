# jen - jekor's network

This is a definition of my network of servers. Currently it:

 * consists of 1 server (www)
 * hosts 3 websites (jekor.com, vocabulink.com, and minjs.com)
 * is managed by [NixOps](http://nixos.org/nixops/)

## fsrest, Nix, and union mounts

The way I originally designed [jekor.com](https://github.com/jekor/jekor.com) assumed it was running in a single writable directory (i.e. comments get written into the directory tree that contains the article that's being commented on). In fact, [fsrest](https://github.com/jekor/fsrest) encourages this sort of design. However, Nix assumes that a package is deployed into the read-only store.

This read-only restriction is a good thing. In fact, before switching to Nix I had realized some problems with the original approach. We have to explicitly track generated files and directories so that we can:

* exclude them from deployments (we don't want to deploy empty or test data overtop of production data)
* target them for backups (or waste backup space with files already tracked in revision control)
* be certain that the build generates all necessary empty resources (test a clean deployment from scratch)

It turns out that a union mount (as can be seen with unionfs-fuse in `jen.nix`) allows us to maintain the illusion of a single writable directory while keeping static content in the read-only Nix store and dynamic content in a separate writable directory. This keeps development repeatable (we build a clean result using a Nix expression each time), backups simple (we just backup the writable directory only), and deployments simple (we just deploy the result of the Nix expression), with the only downside that it's still possible to "overwrite" (mask) a read-only file (which could be seen as a feature depending on how you feel about programs that are allowed to mutate themselves while they run).

## setup

To create a VirtualBox deployment:

```
nixops create -d jen-vbox jen.nix jen-vbox.nix
nixops set-args --arg tld \"lan\" -d jen-vbox
```

Now setup the search path for extras that jen uses. You can see them in `jen.nix` (`<fsrest>`, `<jcoreutils>`, etc.). It can be as simple as:

```
NIX_PATH="$NIX_PATH:$HOME/path/to/repos"
```
