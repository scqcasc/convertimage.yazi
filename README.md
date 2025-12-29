# convertimage.yazi
A Yazi plugin to convert image and text files.

When you invoke the plugin the selected or hovered files are queued for conversion.  The menu will depend on the type of file(s) involved.

## Conversion Tools
Image conversion is handled by ImageMagick.  Document conversion is handled by pandoc, which is great but cannot currently convert from PDF, so am looking for an alternative there.

Make sure your conversion tools are installed and working properly.

## TODO
- [ ] improve error handling
- [ ] handle multiple file types selected (right now can only handle multiple files of the same type at once)
- [ ] add configuration file for better modularity

## Installation

### Using `ya pkg`
```
ya pkg add scqcasc/convertimage
```

### Manual
**Linux/macOS**
```
git clone https://github.com/scqcasc/convertimage.yazi ~/.config/yazi/plugins/convertimage.yazi
```
