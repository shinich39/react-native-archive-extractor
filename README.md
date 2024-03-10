## react-native-archive-extractor

.

## Installation

- /ios/Podfile

```swift
...
target '<ReactNativeApplication>' do 
    config = use_native_modules!

    pod "UnrarKit", :modular_headers => true # add
end
```

```console
cd ios && pod install
```

## Usage

```js
import RNAE from 'react-native-archive-extractor';
```

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

- with libs

```console
npm install react-native-fs react-native-document-picker react-native-uuid
```

```js
import DocumentPicker from 'react-native-document-picker';
import RNFS from "react-native-fs";
import RNAE from 'react-native-archive-extractor';
import uuid from 'react-native-uuid';

async function getFilesFromZip() {
  const { fileCopyUri } = await DocumentPicker.pickSingle({
    copyTo: "cachesDirectory" // required
  });
  
  if (!fileCopyUri) {
    throw new Error("An error was occurred.");
  }

  const srcPath = decodeURIComponent(fileCopyUri.replace(/^file\:\/\//, ""));
  const dstPath = RNFS.TemporaryDirectoryPath + "/" + uuid.v4();

  // create temporary directory
  await RNFS.mkdir(dstPath);

  // extract
  await RNAE.extractZip(srcPath, dstPath);

  const files = await RNFS.readDir(dstPath);

  return files;
}
```

## Credits

- [zip4j](https://github.com/srikanth-lingala/zip4j)
- [junrar](https://github.com/junrar/junrar)
- [AndroidP7zip](https://github.com/hzy3774/AndroidP7zip)
- [UnrarKit](https://github.com/abbeycode/UnrarKit)
- [ZipArchive](https://github.com/ZipArchive/ZipArchive)
- [PLzmaSDK](https://github.com/OlehKulykov/PLzmaSDK)