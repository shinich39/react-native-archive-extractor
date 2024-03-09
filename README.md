## RNArchiveExtractor

Extract archive, pdf in react native.

## Installation

```swift
// /react-native/ios/Podfile
...
target '<ReactNativeApplication>' do {
    ...
    # fix error "the following Swift pods cannot yet be integrated as static libraries"
    pod "UnrarKit", :modular_headers => true
    ...
}
```

```console
cd ios && pod install
```

```js
import RNAE from 'rn-archive-extractor';
```

## Usage

```js
const srcPath = "./archive.zip"; // archive path
const dstPath = "./destination"; // directory path
const password = "1234";

// zip
await RNAE.isProtectedZip(srcPath); // return boolean
await RNAE.extractZip(srcPath, dstPath); // return undefined
await RNAE.extractZipWithPassword(srcPath, dstPath, password); // return undefined

// rar
await RNAE.isProtectedRar(srcPath); // return boolean
await RNAE.extractRar(srcPath, dstPath); // return undefined
await RNAE.extractRarWithPassword(srcPath, dstPath, password); // return undefined

// 7z
await RNAE.extractSevenZip(srcPath, dstPath); // return undefined
await RNAE.extractSevenZipWithPassword(srcPath, dstPath, password); // return undefined

// pdf
await RNAE.isProtectedPdf(srcPath); // return boolean
await RNAE.extractPdf(srcPath, dstPath); // return undefined
```

## Credits

- [zip4j](https://github.com/srikanth-lingala/zip4j)
- [junrar](https://github.com/junrar/junrar)
- [AndroidP7zip](https://github.com/hzy3774/AndroidP7zip)
- [UnrarKit](https://github.com/abbeycode/UnrarKit)
- [ZipArchive](https://github.com/ZipArchive/ZipArchive)
- [PLzmaSDK](https://github.com/OlehKulykov/PLzmaSDK)