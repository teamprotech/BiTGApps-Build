## Build your own BiTGApps

**The example git commands assume you have a [GitHub account](https://github.com/join) and have set-up [SSH authentication](https://help.github.com/articles/set-up-git/#connecting-over-ssh).**

If you want to build your own version of BiTGApps, you'll need to fetch the git sources:

* Create initial path

```shellscript
mkdir -p BiTGApps
```

* Clone build sources

```shellscript
git clone https://github.com/BiTGApps/BiTGApps-Build BiTGApps
git clone https://github.com/BiTGApps/BiTGApps BiTGApps/BiTGApps
```

* Create sources path

```shellscript
mkdir BiTGApps/sources
```

* Clone package sources

```shellscript
git clone https://github.com/BiTGApps/arm-sources BiTGApps/sources/arm-sources
git clone https://github.com/BiTGApps/arm64-sources BiTGApps/sources/arm64-sources
git clone https://github.com/BiTGApps/aosp-sources BiTGApps/sources/aosp-sources
git clone https://github.com/BiTGApps/addon-sources BiTGApps/sources/addon-sources
```

**To build BiTGApps you'll need the Android build tools installed and set-up in your $PATH. If you use Ubuntu you can check out [@mfonville's Android build tools for Ubuntu](http://mfonville.github.io/android-build-tools/).**

Before building, set environmental variables. [Click here](https://github.com/BiTGApps/BiTGApps/blob/master/docs/variables.md) on How To Set.

```shellscript
nano scripts/env_vars.sh
```

After setting environmental variables:

```shellscript
. scripts/env_vars.sh
```

To build BiTGApps/Addons for all platforms and all Android releases:

```shellscript
make
```

To build BiTGApps for a specific Android release on a specific platform, define both the platform and the API
level of that release, seperated by a dash and optionally add the variant with another dash.

Examples (for building for Android 7.1 on ARM):

```shellscript
make arm-25
```

To build BiTGApps Additional package for a specific platform

Examples (for building for Android platform ARM):

```shellscript
make arm
```

To build specific BiTGApps Additional package variant for both platforms

```shellscript
make assistant
```

**For contributors, updated sources can be uploaded.**

Before uploading, set server credentials:

```shellscript
./upload_sources.sh creds
```

After setting server credentials:

* For BiTGApps packages and Additional package

```shellscript
./upload_sources.sh [arch]
```

* For BiTGApps Additional packages contain files of both platforms

```shellscript
./upload_sources.sh common
```

* For BiTGApps configuration files

```shellscript
./upload_sources.sh config
```

* For BiTGApps APK

```shellscript
./upload_sources.sh apk
```

## License

The BiTGApps Project itself is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt).
