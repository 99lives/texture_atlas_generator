package uk.co.ninety9lives.TextureAtlas
{
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class AnimationProcessor
	{
		private var animations:Array;
		
		public function AnimationProcessor()
		{
			reset();
		}
		
		public function reset() : void {
			animations=[];
		}
		
		//determine if a given mc is set up for animation - i.e
		//name ends with _anim
		public static function isAnimation(mc:MovieClip): Boolean {
			return  (mc.name.lastIndexOf("_anim") != -1); 			
		}
		
		public function processMC(mc:MovieClip): void  {
			var xml:XML = new XML(<animation></animation>);
			xml.@fps = 30;
			var frameLable:String
			for (var i:int =1;i<mc.totalFrames+1;i++) {
				mc.gotoAndStop(i);
				if (mc.hasOwnProperty("target_mc")) {
					trace(mc.currentFrameLabel);
					if (mc.currentFrameLabel!=null) frameLable = mc.currentFrameLabel;
					var target:MovieClip = mc.target_mc;
					var framexml:XML = new XML(<frame></frame>);
					framexml.@id = frameLable;
					framexml.@x = target.x;
					framexml.@y = target.y;
					xml.appendChild(framexml);
					
				}				
			}
			animations.push( {name:mc.name, xml:xml});
		}
		
		public function writeXML(basename:String, dest_dir:String) : void  {
			for each (var item:Object in animations) {
				var xmlFile:File = new File(dest_dir+"../"+"xml/"+basename+"_"+item.name+".xml");			
				var xmlFileStream:FileStream = new FileStream();
				xmlFileStream.open(xmlFile, FileMode.WRITE); 			
				xmlFileStream.writeUTFBytes(item.xml.toXMLString());
			}
			
		}
	}
}