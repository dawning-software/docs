<section>
> EOS / Overview
# Dawning Linux EOS
<tag>RnD</tag>
</section>

aims to provide an easy and highly configurable Linux distro, 
leveraging Dawning Kit to build an immutable core with zero 3rd party dependencies. 

These primitives evolved from [**Archived Dawning EOS R&D Repo**](https://github.com/dawnlarsson/dawning-linux)

### Building
Ensure to cd into `dawning-kit/linux` before running build.sh

Minimal config for x86_x64
```sh
sudo sh build.sh arch/x64 debug_none
```

Minimal config for raspberry pis (WIP)
```sh
sudo sh build.sh arch/arm.pi debug_none
```

if you want to run this in a virtual machine for testing:
```sh
sh build.run.sh
```
but, you need https://www.qemu.org/

## <tag>[Github](https://github.com/dawnlarsson/dawning-kit)</tag>