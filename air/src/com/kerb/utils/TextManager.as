


package com.kerb.utils {
	
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	
	public class TextManager {
		
		
		// singleton
		private static var instance:TextManager;
		
		// text data
		private var _xmlData:XML;
		
		// font override function
		private var _fontOverrideFunction:Function;
		
		
		
		public static function getInstance():TextManager {
			if (instance == null) {
				instance = new TextManager();
			}
			return instance;
		}
		
		public function get rawXmlData():XML {return _xmlData==null ? new XML() : _xmlData}
		public function initFromClass(_xmlClass:Class):void {
			var baa:ByteArray = ByteArray(new _xmlClass());
			//read the first 3 bytes and check if its a xmom BOM and ignore them - WHAT A HACK!!!
			var embeddedXML:XML;
			var firstCharacter:String = baa.readUTFBytes(3);
			
			if (firstCharacter.length == 1) {
				this._xmlData = new XML(baa.readUTFBytes(baa.length - 3));
			} 
			else {
				this._xmlData = new XML(firstCharacter + baa.readUTFBytes(baa.length - 3));
			}
		}
		
		
		public function init(_xmlData:XML):void {
			this._xmlData = _xmlData;		
		}
		
		
		public function getTextById(id:String):String {
			if (_xmlData) {
				var result:String = _xmlData.text.(@id == id);
				if (result) {
					return result;
				} 
				else {
					if (id != null) trace ("TextManager Unknown Field:"+id);
					return "[[" + id + "]]";
				}
			} 
			else {
				return id;
			}
		}
		
		public function hasId(id:String):Boolean {
			if (_xmlData) {
				var result:String = _xmlData.text.(@id == id);
				if (result) {
					return true;
				} 
			}
			return false;
		}
		
		public function setFontOverrideFunction(fontOverrideFunction:Function):void {
			_fontOverrideFunction = fontOverrideFunction;
		}
		
		public function setTextField(tf:TextField, id:String, html:Boolean = false):void {
			setRawTextField(tf, getTextById(id), html);
		}
		
		public function setRawTextField(tf:TextField, text:String, html:Boolean = false):void {
			if (_fontOverrideFunction != null) {
				_fontOverrideFunction(tf);
			}
			
			if (html) {
				tf.htmlText = text;
			} else {
				if (_fontOverrideFunction == null && tf.length > 0 && !tf.defaultTextFormat.bold && tf.getTextFormat(0).bold) {
					var b:TextFormat = new TextFormat();
					b.bold = true;
					tf.defaultTextFormat = b;
				}
				
				tf.text = text;
			}
		}
		
		public function centerTextField(tf:TextField, aroundZero:Boolean = true):void {
			tf.y = (aroundZero ? 0 : tf.y) + ((tf.height - (tf.textHeight + 4)) / 2);
		}
	}
}