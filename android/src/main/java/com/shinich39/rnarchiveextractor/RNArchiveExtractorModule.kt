package com.shinich39.rnarchiveextractor;

import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise

import java.io.File
import java.io.FileOutputStream
import java.io.IOException

import net.lingala.zip4j.ZipFile
import net.lingala.zip4j.exception.ZipException

import com.github.junrar.Archive
import com.github.junrar.Junrar
import com.github.junrar.exception.RarException

import com.hzy.libp7zip.P7ZipApi

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.graphics.pdf.PdfRenderer.Page
import android.os.ParcelFileDescriptor

class RNArchiveExtractorModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName() = "RNArchiveExtractor"

  // @ReactMethod(isBlockingSynchronousMethod = true)

  @ReactMethod
  fun isProtectedZip(srcPath: String, promise: Promise) {
    try {
      val zipFile = ZipFile(srcPath)
      promise.resolve(zipFile.isEncrypted());
    } catch(e: ZipException) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractZip(srcPath: String, dstPath: String, promise: Promise) {
    try {
      val zipFile = ZipFile(srcPath);
      zipFile.extractAll(dstPath);
      promise.resolve(null);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractZipWithPassword(srcPath: String, dstPath: String, password: String, promise: Promise) {
    try {
      val zipFile = ZipFile(srcPath, password.toCharArray());
      zipFile.extractAll(dstPath);
      promise.resolve(null);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun isProtectedRar(srcPath: String, promise: Promise) {
    try {
      val rarFile = Archive(File(srcPath));
      promise.resolve(rarFile.isEncrypted());
    } catch(e: RarException) {
      promise.reject(e);
    } catch(e: IOException) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractRar(srcPath: String, dstPath: String, promise: Promise) {
    try {
      val rarFile = File(srcPath);
      val dstDir = File(dstPath);
      Junrar.extract(rarFile, dstDir);
      promise.resolve(null);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractRarWithPassword(srcPath: String, dstPath: String, password: String, promise: Promise) {
    try {
      val rarFile = File(srcPath);
      val dstDir = File(dstPath);
      Junrar.extract(rarFile, dstDir, password);
      promise.resolve(null);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractSevenZip(srcPath: String, dstPath: String, promise: Promise) {
    try {
      val srcFile = File(srcPath);
      val dstDir = File(dstPath);
      val command = String.format("7z x '%s' '-o%s' -aoa", srcFile.getAbsolutePath(), dstDir.getAbsolutePath());
      val result = P7ZipApi.executeCommand(command);
      if (result == 2){
        throw Exception("Wrong password.");
      }
      promise.resolve(null);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractSevenZipWithPassword(srcPath: String, dstPath: String, password: String, promise: Promise) {
    try {
      val srcFile = File(srcPath);
      val dstDir = File(dstPath);
      val command = String.format("7z x '%s' '-o%s' '-p%s' -aoa", srcFile.getAbsolutePath(), dstDir.getAbsolutePath(), password);
      val result = P7ZipApi.executeCommand(command);
      if (result == 2){
        throw Exception("Wrong password.");
      }
      promise.resolve(null);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun isProtectedPdf(srcPath: String, promise: Promise) {
    try {
      val srcFile = File(srcPath);
      if (!srcFile.exists()) {
        throw Exception("File not found");
      }
      val parcelFileDescriptor = ParcelFileDescriptor.open(srcFile, ParcelFileDescriptor.MODE_READ_ONLY);
      val renderer = PdfRenderer(parcelFileDescriptor);
      promise.resolve(false);
    } catch(e: SecurityException) {
      promise.resolve(true);
    } catch(e: IOException) {
      promise.reject(e);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }

  @ReactMethod
  fun extractPdf(srcPath: String, dstPath: String, promise: Promise) {
    try {
      val quality = 100;
      val srcFile = File(srcPath);
      if (!srcFile.exists()) {
        throw Exception("File not found");
      }
      val parcelFileDescriptor = ParcelFileDescriptor.open(srcFile, ParcelFileDescriptor.MODE_READ_ONLY);
      // create a new renderer
      val renderer = PdfRenderer(parcelFileDescriptor);
      // let us just render all pages
      val pageCount = renderer.getPageCount();
      // check dupe
      for (i in 0 until pageCount) {
        val path = dstPath + "/" + String.valueOf(i) + ".jpg";
        val file = File(path);
        if (file.exists()) {
          throw Exception("File already exists");
        }
      }
      // extract
      var fos: FileOutputStream = null;
      try {
        for (i in 0 until pageCount) {
          val path = dstPath + "/" + String.valueOf(i) + ".jpg";
          val page = renderer.openPage(i);
          val pageWidth = page.getWidth();
          val pageHeight = page.getHeight();
          val bitmap = Bitmap.createBitmap(
            pageWidth,
            pageHeight,
            Bitmap.Config.ARGB_8888);
          // say we render for showing on the screen
          page.render(
            bitmap,
            null,
            null,
            Page.RENDER_MODE_FOR_DISPLAY);
          // do stuff with the bitmap
          val file = File(path);
          fos = FileOutputStream(file);
          // compress to jpeg
          bitmap.compress(Bitmap.CompressFormat.JPEG, quality, fos);
          // close the page
          page.close();
        }
      } catch(e: Exception) {
        promise.reject(e);
      } finally {
        // close the renderer
        renderer.close();
        promise.resolve(null);
      }
    } catch(e: IOException) {
      promise.reject(e);
    } catch(e: Exception) {
      promise.reject(e);
    }
  }
}
