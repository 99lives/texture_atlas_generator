package uk.co.ninety9lives.TextureAtlas
{
	import com.bit101.components.PushButton;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	public class FilterScaler
	{
		private var items:Array = [];
		private var scale:Number;
		
		public function FilterScaler()
		{
		}
		

		

		
		public function processItems(swf:MovieClip,  scale:Number) {
			this.scale = scale;
			findItems(swf);			
		}
		
		public function findItems(swf:MovieClip) : Array {
			recurse(swf);
			return items;
			
		}
		
		private function recurse(target:DisplayObjectContainer):void {
			
			var qty:uint = target.numChildren;
			for (var i:int = 0; i < qty; i++) {
				var child:DisplayObject = target.getChildAt(i);
				
				if (child != null && child.hasOwnProperty("filters") && child.filters.length > 0) {
					var nFilters:Array = [];
					
					for each (var item:* in child.filters) {
						//trace(item);
						if (item is GlowFilter) {
							var fg:GlowFilter = item;							
							nFilters.push(new GlowFilter(fg.color,fg.alpha * scale,Math.round(fg.blurX * scale), Math.round(fg.blurY * scale),Math.ceil(fg.strength * scale),fg.quality, fg.inner, fg.knockout));
							//nFilters.push(new GlowFilter(fg.color,fg.alpha,1, 1,1,fg.quality, fg.inner, fg.knockout));
									
						}
						if (item is BlurFilter) {
							var fb:BlurFilter = item;
							nFilters.push(new BlurFilter(Math.round(fb.blurX * scale), Math.round(fb.blurY * scale)));
							//nFilters.push(new BlurFilter(1, 1));							
						}
						
						if (item is DropShadowFilter) {
							var fd:DropShadowFilter = item;
							nFilters.push(new DropShadowFilter(Math.round(fd.distance * scale),fd.angle,fd.color, fd.alpha* scale, Math.round(fd.blurX * scale), Math.round(fd.blurY * scale),Math.ceil(fd.strength * scale), fd.quality, fd.inner, fd.knockout, fd.hideObject))
							//nFilters.push(new DropShadowFilter(1,fd.angle,fd.color, fd.alpha, 1, 1,1, fd.quality, fd.inner, fd.knockout, fd.hideObject))
							
							
						}
					}
					
					child.filters = nFilters;		
					
				}
				
				if (child is DisplayObjectContainer) {
					recurse(child as DisplayObjectContainer);
				}
			}
		}
	}
}