package uk.co.ninety9lives.TextureAtlas
{
	import com.btbStudios.air.utils.FileUtils;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class MarmaladeGlobalGroupScripts
	{
		private var oDir:File;
		private var allGroups:Array = [];
		
		public function MarmaladeGlobalGroupScripts(outputDir:File)
		{
			oDir = outputDir;
		}		
		
		//generate _all.group for one dir
		public function generateFiles(dir:File) {
			var files:Array = FileUtils.GetAllFilesFromDir(dir,false);
			var sGroup:String = "";
			var groupsfound:Number = 0;
			sGroup += 'CIwResGroup\n';
			sGroup += '{\n';
			sGroup += '	/* Must always name the group */\n';
			sGroup += '	name "_all"\n';
			
			for each (var item:File in files) {
				
				if (item.extension=="group" && !item.isDirectory && item.name != "_all.group" ) {
					groupsfound++;
					sGroup += '"./'+item.name+'"\n';
				}				
			}
			
			sGroup += '}\n';
			
			if (groupsfound>0) {
				writeGroupFile(sGroup, dir)
			}		
			
		}
		
		private function writeGroupFile (data:String, dir:File): void  {
			var groupFile:File = dir.resolvePath("_all.group");			
			var groupFileStream:FileStream = new FileStream();
				groupFileStream.open(groupFile, FileMode.WRITE); 			
			groupFileStream.writeUTFBytes(data);
			allGroups[groupFile.nativePath] = groupFile;
		}	
		
		//write a file for inclusion in the c++ source code to build assets into textures		
		public function writeIncludeFile() : void {
			var sText:String = "";
			for each (var item:File in allGroups)  {
		
			}
			for each (var item:File in allGroups)  {
				var index:Number = item.nativePath.lastIndexOf(oDir.name);
				var path:String = item.nativePath.substr(index);
				var name:String = item.name.substr(0,item.name.lastIndexOf("."));
				sText += 'IwGetResManager()->LoadGroup("'+path+'");\n';
				sText += 'IwGetResManager()->DestroyGroup("'+name+'");\n';				
			}
			var groupFile:File = oDir.resolvePath("derbh/buildasssets.h");			
			var groupFileStream:FileStream = new FileStream();
			groupFileStream.open(groupFile, FileMode.WRITE); 			
			groupFileStream.writeUTFBytes(sText);
			
			
		}
		
	}
}