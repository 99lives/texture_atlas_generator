package uk.co.ninety9lives.TextureAtlas {
	
	import com.pixelrevision.textureAtlas.Settings;
	
	public class MarmaladeGroupGenerator{
		
		private var _settings:Settings;
		public function MarmaladeGroupGenerator(){
			_settings = Settings.sharedInstance;
		}
		

		
		public function getString(basename:String) : String {
			var output:String = "";
			output += "CIwResGroup\n";
			output += "{\n";
			output += '/* Must always name the group */\n';
			output += 'name "'+basename+'"\n';
			output += 'useTemplate "image" "match3n"\n';
			output += '"./'+basename+'.png"\n';
			
			output += "}\n";
						
			
			return output;
			
		}
		

	}
}