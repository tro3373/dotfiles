# setup arch linux on wsl2
## 1. enable windows feature

```
enable.bat
install_ubuntu.bat
```

## 2. generate arch image (must be in linux!) and import bat

Optional: If setup ubuntu..

```
curl -fSsL git.io/tr3s |bash
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
.dot/bin/setup -e
```

```
cd .dot/bin/lib/bootstrap/arch/wsl2
./gen_arch_image -e
```

## 3. import generated arch image via generated bat script

```
import_wsl_arch_image.bat
```

## 4. bootstrap in wsl2 arch

```
../bootstrap -e
```

## 5. setup in wsl2

```
cd ~/.dot/bin
./setup wsl_arch -e
```
