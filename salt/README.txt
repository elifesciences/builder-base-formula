# builder-base-formula/salt/

This directory contains a load of symlinks. Why??

`builder-base-formula` was derived from the base states in `elife-builder`,
a private and internal project at eLife that was open sourced as `builder`.

Later, the individual projects would become their own formulas and in the
process of getting them to work with the new builder and the standard Salt
formula file structure, the emerged differently. 

Now, we need to treat the builder-base-formula the same as other formulas,
hence this hack. We don't expect it to be permanent and it only applies to
Vagrant.
