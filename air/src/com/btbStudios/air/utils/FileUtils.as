package com.btbStudios.air.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	
	public class FileUtils
	{
		/**
		 * Lists all files in a directory structure including subdirectories, except the folders themselves.
		 * 
		 * @param STARTINGFILE File the top level folder to list the contents of
		 * @param RELATIVETO File Optional If this is set all paths returned will be relative to this.
		 */
		public static function ListAllFiles(STARTINGFILE:File, RELATIVETO:File = null):String
		{
			var str:String = "";
			
			for each(var lstFile:File in STARTINGFILE.getDirectoryListing())
			{
				if(lstFile.isDirectory)
				{
					str+= ListAllFiles(lstFile, RELATIVETO);
				}
				else
				{
					if(RELATIVETO!=null)
					{
						str+= RELATIVETO.getRelativePath(lstFile) + "\n";
					}
					else
					{
						str+= lstFile.nativePath + "\n";
					}
				}
			}
			
			return str;
		}
		
		/**
		 * Returns an array populated with File objects representing all the files in the given directory
		 * including all the subdirectories but excluding the directory references themselves
		 * 
		 * @param STARTINGFILE File the top level directory to list the contents of
		 * @param INCSUB Boolean Optional Include subdirectories
		 */
		public static function GetAllFilesFromDir(STARTINGFILE:File, INCSUB:Boolean = true):Array
		{
			var arr:Array = [];
			
			for each(var lstFile:File in STARTINGFILE.getDirectoryListing())
			{
				if(lstFile.isDirectory && INCSUB)
				{
					for each(var subFile:File in GetAllFilesFromDir(lstFile, true))
					{
						arr.push(subFile);
					}
				}
				else
				{
					arr.push(lstFile);
				}
			}
			
			return arr;
		}
	}
}