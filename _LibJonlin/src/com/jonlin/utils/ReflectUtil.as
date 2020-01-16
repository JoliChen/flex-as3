package com.jonlin.utils
{
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;

	/**
	 * 反射工具类
	 * @author Joli
	 */
	public final class ReflectUtil
	{
		/**
		 * 获取类
		 * @param clsPath
		 * @param domain
		 * @return 
		 */
		static public function getClass(clsPath:String, domain:ApplicationDomain):Class
		{
			return domain.getDefinition(clsPath) as Class;
		}
		
		/**
		 * 获取实例的类
		 * @param instance
		 * @param domain
		 * @return
		 */
		static public function getInstanceClass(instance:*, domain:ApplicationDomain):Class
		{
			return getClass(getClassPath(instance, null), domain);
		}
		
		/**
		 * 获取类路径
		 * @param clsInstance
		 * @param split
		 * @return
		 */
		static public function getClassPath(clsInstance:*, split:String="."):String
		{
			var clsPath:String = getQualifiedClassName(clsInstance);
			if (split) {
				return clsPath.replace("::", split);
			}
			return clsPath;
		}
		
		/**
		 * 获取类名
		 * @param instance
		 * @return 
		 */
		static public function getClassName(clsInstance:*):String
		{
			var clsPath:String = getClassPath(clsInstance);
			return clsPath.substr(clsPath.lastIndexOf(".") + 1);
		}
		
		/**
		 * 注册别名
		 * @param targetClass
		 */		
		static public function registClassAlias(cls:Class):void
		{
			registerClassAlias(getClassPath(cls), cls);
		}
	}
}