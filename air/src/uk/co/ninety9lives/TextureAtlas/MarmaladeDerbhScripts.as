package uk.co.ninety9lives.TextureAtlas
{
	import com.btbStudios.air.utils.FileUtils;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class MarmaladeDerbhScripts
	{
		public var textureFormats:Array= ["gles1", "pvr","attic"];
		public var allowedExtensions:Array= ["xml", "group"];
		public var oDir:File;
		private var allGroups:Array = [];
		private var nameParts:Array;
		private var currentTextureFormat:String;
		
		
		public function MarmaladeDerbhScripts(outputDir:File)
		{
			oDir = outputDir;
		}		
		
		//generate _all.group for one dir
		public function generateFiles(dir:File) {
			for each (var item:String in textureFormats) {
				currentTextureFormat = item;
				determineFileName(dir, currentTextureFormat)
				generate(dir);
				
			}
		}
		
		public function generateXMLderbh(dir:File) {
			currentTextureFormat = "";
			determineFileName(dir, currentTextureFormat);
			
			var files:Array = FileUtils.GetAllFilesFromDir(dir,false);
			var sText:String = "";
			var filesfound:Number = 0;
			sText += 'archive ../../'+filename+'.dz\n';
			sText += 'basedir ../../../data'+sourcePath+'\n';			
			
			for each (var item:File in files) {
				//add each file if of allowed type
				if (allowedExtensions.indexOf(item.extension)!=-1) {
					filesfound++;
					if (item.extension=="group") 
						sText += 'file '+item.name+'.bin 0 lzma \n';
					if (item.extension=="xml") 
						sText += 'file '+item.name+' 0 lzma \n';
				}				
			}
			
			
			if (filesfound>0) {
				writeGroupFile(sText, dir)
			}	
		}
		
		private function generate(dir:File) {
			var files:Array = FileUtils.GetAllFilesFromDir(dir,false);
			var sText:String = "";
			var filesfound:Number = 0;
			sText += 'archive ../../'+filename+'.dz\n';
			sText += 'basedir ../../../data-ram/data'+sourcePath+'\n';			
			
			for each (var item:File in files) {
				//add each file if of allowed type
				if (allowedExtensions.indexOf(item.extension)) {
					filesfound++;
					if (item.extension=="group") 
						sText += 'file '+item.name+'.bin 0 lzma \n';
					if (item.extension=="xml") 
						sText += 'file '+item.name+' 0 lzma \n';
				}				
			}
			
			
			if (filesfound>0) {
				writeGroupFile(sText, dir)
			}		
			
		}
		
		//obtain the relative path parts
		private function determineFileName(dir:File, textureformat:String) {
			var parts:Array = dir.nativePath.split("/");
			var index:Number = parts.lastIndexOf(oDir.name);
			nameParts = parts.slice(index);
			
		} 
		
		private function get filename() : String {
			var s:String=currentTextureFormat == "" ? "" : currentTextureFormat+"_";
			for (var i:int =1; i < nameParts.length; i++) {
				s+=nameParts[i];
				if (i<nameParts.length-1) s+="_";				
			} 
			return s;			
		}

		
		private function get sourcePath() : String {
			var s:String=currentTextureFormat == "" ? "/" : "-"+currentTextureFormat+"/";
			for (var i:int =0; i < nameParts.length; i++) {
				s+=nameParts[i];
				s+="/";				
			} 
			return s;			
		}
		
		private function writeGroupFile (data:String, dir:File): void {
			var groupFile:File = oDir.resolvePath("derbh/"+filename+".dcl");			
			var groupFileStream:FileStream = new FileStream();
			groupFileStream.open(groupFile, FileMode.WRITE); 			
			groupFileStream.writeUTFBytes(data);
			allGroups.push(groupFile);
		}
		

		
		
		
	}
}