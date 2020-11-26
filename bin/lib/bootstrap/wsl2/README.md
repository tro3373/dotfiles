# setup arch linux on wsl2
## 1. enable windows feature

```
enable.bat
```

## 2. generate arch image (must be in linux!) and import bat

```
./gen_arch_image
```

## 3. import generated arch image via generated bat script

```
import_wsl_arch_image.bat
```

## 4. bootstrap in wsl2 arch

```
./bootstrap_arch -e
```

## 5. setup in wsl2

```
cd ~/.dot/bin
./setup wsl_arch -e
```

