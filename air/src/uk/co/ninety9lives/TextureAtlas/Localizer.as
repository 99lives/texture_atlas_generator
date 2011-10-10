package uk.co.ninety9lives.TextureAtlas
{
	import com.btbStudios.air.utils.FileUtils;
	import com.kerb.utils.TextManager;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.utils.ByteArray;

	public class Localizer
	{
		private var textFields:Array = [];
		private var localeFiles:Array;
		public var locales:Array=[];
		public function Localizer()
		{
			
		}
		public function discoverLocales(dir:File) : void {
			
			localeFiles = FileUtils.GetAllFilesFromDir(dir, false);
			
			for each (var item:File in localeFiles) {
				var fs:FileStream = new FileStream();
				var b:ByteArray = new ByteArray();
				fs.open(item, FileMode.READ);
				locales.push ( XML(fs.readUTFBytes(fs.bytesAvailable)));
			}
		}
		
		public function get hasText() : Boolean {
			return (textFields.length > 0);			
		}
		
		public function localize(locale:String, swf:MovieClip) : void {
			var xml:XML = getLocale(locale);
			if (xml != null) {
				findTextFields(swf);
				var tm:TextManager = TextManager.getInstance();
				tm.init(xml);
				for each (var text_field:TextField in textFields) {
					//if (tm.hasId(text_field.name)) {
						tm.setTextField(text_field,text_field.name);
					//}					
				}				
			}			
		}
		
		public function getLocale(locale:String) : XML {
			var xml:XML;
			for each (var item:XML in locales) {
				if (String(item.@locale) == locale)  {
					trace ("found locale", item.@locale);
					xml = item;					
				}
			}
			return xml;
		}
		
		public function getLocalesListForSwf(swf:MovieClip) : Array {
			findTextFields(swf);
			if (!hasText) {
				return ["common"];
			} else {
				var list:Array = [];
				for each (var item:XML in locales) {
					list.push(String(item.@locale).toLowerCase());					
				}
				return list;
			}
		}
		
		public function findTextFields(swf:MovieClip) : Array {
			textFields= [];
			recurse(swf);
			return textFields;			
		}
		
		private function recurse(target:DisplayObjectContainer):void {
			var qty:uint = target.numChildren;
			for (var i:int = 0; i < qty; i++) {
				var child:DisplayObject = target.getChildAt(i);
				
				if (child is TextField ) {
					
					textFields.push(child);
					
				}
				if (child is DisplayObjectContainer) {
					recurse(child as DisplayObjectContainer);
				}
			}
		}
	}
}