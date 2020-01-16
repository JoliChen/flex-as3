package com.joli.extension.pngqunt
{
	/**
	 * PNG压缩错误码
	 * @author Amumu
	 */
	public final class CompressPngErrorCode
	{
		/**命令行程序不存在*/
		public static const CL_NOT_EXISTS:int = -10000;
		
		public static const SUCCESS:int = 0;
		public static const MISSING_ARGUMENT:int = 1;
		public static const READ_ERROR:int = 2;
		public static const INVALID_ARGUMENT:int = 4;
		public static const NOT_OVERWRITING_ERROR:int = 15;
		public static const CANT_WRITE_ERROR:int = 16;
		public static const OUT_OF_MEMORY_ERROR:int = 17;
		public static const WRONG_ARCHITECTURE:int = 18;// Missing SSE
		public static const PNG_OUT_OF_MEMORY_ERROR:int = 24;
		public static const LIBPNG_FATAL_ERROR:int = 25;
		public static const WRONG_INPUT_COLOR_TYPE:int = 26;
		public static const LIBPNG_INIT_ERROR:int = 35;
		public static const TOO_LARGE_FILE:int = 98;
		public static const TOO_LOW_QUALITY:int = 99;
	}
}