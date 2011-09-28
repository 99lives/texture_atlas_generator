package com.kerb.utils {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public final class KerbUtils {
		
		public function KerbUtils() {
			throw new Error("class is static");
		}
		
		public static function delayFunction(func:Function, ms:int):void {
            var delayer:Timer;
            var delayerUpdate:Function;
            
            
            delayerUpdate = 
				function (e:TimerEvent):void {
					e.target.removeEventListener(TimerEvent.TIMER, delayerUpdate);
				    if (func!=null) func.call();
				    delayer.stop();
				};
            delayer = new Timer(ms, 1);
            delayer.addEventListener(TimerEvent.TIMER, delayerUpdate);
            delayer.start();
         
        }
        
        public static function addDotsIfLongerThan(str:String, limit:int):String {
        	if (str.length > limit && limit > 2) {
        		return str.slice(0, limit-2) + "..";
        	} else {
        		return str;
        	}
        }
		
	}
}
