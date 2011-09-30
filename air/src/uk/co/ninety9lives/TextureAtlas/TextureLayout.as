package uk.co.ninety9lives.TextureAtlas
{
	import com.adobe.images.PNGEncoder;
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONEncoder;
	import com.pixelrevision.textureAtlas.LUAGenerator;
	import com.pixelrevision.textureAtlas.TextureItem;
	import com.pixelrevision.textureAtlas.TextureLayout;
	import com.pixelrevision.textureAtlas.events.TextureAtlasEvent;
	
	import deng.fzip.FZip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class TextureLayout extends com.pixelrevision.textureAtlas.TextureLayout
	{
		public function TextureLayout()
		{
			super();
		}
		public var scale:Number = 1;		
		protected var selected:MovieClip;
		protected var swf:MovieClip;
		protected var childIndex:Number;
		
		override public function processSWF(swf:MovieClip):void{
			clear();
			this.swf = swf;
			childIndex=0;
			getNextClip() ;
			swf.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		}
		
		protected function onEnterFrame(e:Event) : void {
			
			drawItem(selected, selected.name + "_" + appendIntToString(selected.currentFrame-1, 5), selected.name);
			if (selected.currentFrame  < selected.totalFrames) 
				selected.gotoAndStop(selected.currentFrame+1);
			else 
				getNextClip() ;
		}
		protected function getNextClip() {
			if (childIndex == swf.numChildren) {
				swf.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				layoutChildren();
				dispatchEvent(new Event(Event.COMPLETE));				
			} else {
				selected = MovieClip(swf.getChildAt(childIndex++));
				
			}
			
		}
		

		

		override protected function drawItem(clip:MovieClip, name:String = "", baseName:String =""):TextureItem{
			
			var label:String = "";
			var f:FilterScaler = new FilterScaler();
			f.processItems(clip,scale);
			var bounds:Rectangle = clip.getBounds(clip.parent);
			
			bounds.x *=scale;
			bounds.y *=scale;
			bounds.width *=scale;
			bounds.height *=scale;
			
			var itemW:Number = Math.ceil(bounds.x + bounds.width);
			var itemH:Number = Math.ceil(bounds.y + bounds.height);
			var matrix:Matrix = new Matrix();
			matrix.scale(scale,scale);
			var bmd:BitmapData = new BitmapData(itemW, itemH, true, 0x00000000);
			bmd.draw(clip, matrix);
			if(clip.currentLabel != _currentLab && clip.currentLabel != null){
				_currentLab = clip.currentLabel;
				label = _currentLab;
			}
			var item:TextureItem = new TextureItem(bmd, name, label, baseName);
			addItem(item);
			return item;
		}
		
		
		 public function saveLocal(basename:String, dest_dir:String):void{
			graphics.clear();
			// prepare files
			var bmd:BitmapData = new BitmapData(_settings.canvasWidth, _settings.canvasHeight, true, 0x000000);

			
			var xml:XML = new XML(<TextureAtlas></TextureAtlas>);
			xml.@imagePath = basename+".png"  ;
			
			var marmaladeGroupGenerator:MarmaladeGroupGenerator = new MarmaladeGroupGenerator();			
			
			for(var i:uint=0; i<_items.length; i++){
				var matrix:Matrix = new Matrix();
				matrix.tx = _items[i].x;
				matrix.ty = _items[i].y;
				bmd.draw(_items[i], matrix);
				// xml
				var subText:XML = new XML(<SubTexture />); 
				subText.@x = _items[i].x;
				subText.@y = _items[i].y;
				subText.@width = _items[i].width;
				subText.@height = _items[i].height;
				subText.@name = _items[i].textureName;
				if(_items[i].frameName != "") subText.@frameLabel = _items[i].frameName;
				xml.appendChild(subText);
				
				// json
				var textureData:Object = new Object();
				textureData.x = _items[i].x;
				textureData.y = _items[i].y;
				textureData.width = _items[i].width;
				textureData.height = _items[i].height;
				textureData.name = _items[i].textureName;
				if(_items[i].frameName != "") textureData.frameLabel = _items[i].frameName;
	
			}
			
		
			
			// now setup writeable objects
			var img:ByteArray = PNGEncoder.encode(bmd);
			var xmlString:String = xml.toString();		
			var groupString:String = marmaladeGroupGenerator.getString(basename);
			
			//Write Each file
			
			var imgFile:File = new File(dest_dir+basename+".png");
			var imgFileStream:FileStream = new FileStream();
			imgFileStream.open(imgFile, FileMode.WRITE); 			
			imgFileStream.writeBytes(img);
			
			var xmlFile:File = new File(dest_dir+basename+".xml");			
			var xmlFileStream:FileStream = new FileStream();
			xmlFileStream.open(xmlFile, FileMode.WRITE); 			
			xmlFileStream.writeUTFBytes(xmlString);
			
			var groupFile:File = new File(dest_dir+basename+".group");			
			var groupFileStream:FileStream = new FileStream();
			groupFileStream.open(groupFile, FileMode.WRITE); 			
			groupFileStream.writeUTFBytes(groupString);

			drawBounds(null);
		}
	}
}