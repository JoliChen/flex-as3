package com.jonlin.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	/**
	 * 同步文件输入输出工具
	 * @author Joli
	 * @date 2018-7-13 下午7:00:08
	 */
	public class IOUtil
	{
		/**
		 * 同步写入文件
		 * @param filePath:String 文件路径
		 * @param bytes:ByteArray 二进制数组
		 * @param fileMode:String 文件打开模式
		 * @see flash.filesystem.FileMode
		 */
		public static function write(filePath:String, bytes:ByteArray, fileMode:String=FileMode.WRITE):Boolean
		{
			return writeFile(FileUtil.newFile(filePath), bytes, fileMode);
		}
		
		/**
		 * 同步读取文件
		 * @param filePath:String 文件
		 * @param fileMode:String 文件打开模式
		 * @param bytes:ByteArray 二进制数组
		 * @see flash.filesystem.FileMode
		 */
		public static function read(filePath:String, bytes:ByteArray=null, fileMode:String=FileMode.READ):ByteArray
		{
			return readFile(FileUtil.newFile(filePath), bytes, fileMode);
		}
		
		/**
		 * 同步写入文件
		 * @param file:File 文件
		 * @param bytes:ByteArray 二进制数组
		 * @param fileMode:String 文件打开模式
		 * @see flash.filesystem.FileMode
		 */
		public static function writeFile(file:File, bytes:ByteArray, fileMode:String=FileMode.WRITE):Boolean
		{
			var isOk:Boolean = false;
			const stream:FileStream = new FileStream();
			try {
				stream.open(file, fileMode);
				stream.writeBytes(bytes);
				isOk = true;
			} catch(error:Error) {
				trace("==》写入文件错误：\n", error.message);
			} finally {
				stream.close();
			}
			return isOk;
		}
		
		/**
		 * 同步读取文件
		 * @param file:File 文件
		 * @param fileMode:String 文件打开模式
		 * @param bytes:ByteArray 二进制数组
		 * @see flash.filesystem.FileMode
		 */
		public static function readFile(file:File, bytes:ByteArray=null, fileMode:String=FileMode.READ):ByteArray
		{
			if (!file.exists) {
				return null;	
			}
			if (!bytes) {
				bytes = new ByteArray();
			}
			var stream:FileStream = new FileStream();
			try {
				stream.open(file, fileMode);
				stream.readBytes(bytes);
			} catch(error:Error) {
				trace("==》读出文件错误：\n", error.message);
			} finally {
				stream.close();
			}
			bytes.position = 0;
			return bytes;
		}
		
		public static function writeString(file:File, text:String):void
		{
			const bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(text);
			writeFile(file, bytes);
		}
		
		public static function readString(file:File):String
		{
			 const bytes:ByteArray = readFile(file);
			 if (!bytes) {
				 return null;
			 }
			 return bytes.readUTFBytes(bytes.bytesAvailable);
		}
		
		public static function readStringFromPath(path:String):String
		{	
			return readString(FileUtil.newFile(path));
		}
	}
}