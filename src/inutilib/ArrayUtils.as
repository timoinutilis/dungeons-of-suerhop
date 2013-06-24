package inutilib
{
	import flash.utils.ByteArray;
	
	import flashx.textLayout.elements.BreakElement;

	public class ArrayUtils
	{
		private static const k_DIFF_CMD_COPY:int = 0;
		private static const k_DIFF_CMD_REPLACE:int = 1;
		private static const k_DIFF_CMD_ADD:int = 2;
		private static const k_DIFF_CMD_SKIP:int = 3;
		
		public static function shuffleArray(array:Array):void
		{
			
		}
		
		public static function encodeDifference(originalData:ByteArray, changedData:ByteArray):ByteArray
		{
			originalData.position = 0;
			changedData.position = 0;
			
			var difference:ByteArray = new ByteArray();
			
			var minLen:int = Math.min(originalData.length, changedData.length);
			var partLen:int;
			var mode:int = 0;
			var before:int = 0;
			var startEqual:int = 0;
			var startUnequal:int = 0;
			
			// compare
			for (var i:int = 0; i < minLen; i++)
			{
				var value1:int = originalData.readByte();
				var value2:int = changedData.readByte();
				if (value1 == value2)
				{
					if (before == -1) // was unequal
					{
						startEqual = i;
					}
					before = 1;

					if (mode == -1) // unequal
					{
						// change mode if there are at least 3 equal bytes
						if (i - startEqual == 2)
						{
							partLen = startEqual - startUnequal;
							writeDiffControl(difference, k_DIFF_CMD_REPLACE, partLen);
							difference.writeBytes(changedData, startUnequal, partLen);
							mode = 1;
						}
					}
					else
					{
						mode = 1;
					}
				}
				else
				{
					if (mode == 1) // was equal
					{
						writeDiffControl(difference, k_DIFF_CMD_COPY, i - startEqual);
						startUnequal = i;
					}
					mode = -1;
					before = -1;
				}
			}
			
			// finish compare
			if (mode == -1) // was unequal
			{
				partLen = minLen - startUnequal;
				writeDiffControl(difference, k_DIFF_CMD_REPLACE, partLen);
				difference.writeBytes(changedData, startUnequal, partLen);
			}
			else if (mode == 1) // was equal
			{
				writeDiffControl(difference, k_DIFF_CMD_COPY, minLen - startEqual);
			}
			
			// rest
			if (changedData.length > minLen)
			{
				partLen = changedData.length - minLen;
				writeDiffControl(difference, k_DIFF_CMD_ADD, partLen);
				difference.writeBytes(changedData, minLen, partLen);
			}

			return difference;
		}
		
		private static function writeDiffControl(data:ByteArray, command:int, count:int):void
		{
			var control:int = (command << 5) & 0x60;
			control |= (count & 0x1F);
			
			count >>= 5;
			if (count > 0)
			{
				control |= 0x80;
			}
			data.writeByte(control);
			while (count > 0)
			{
				var extCount:int = count & 0x7F;
				count >>= 7;
				if (count > 0)
				{
					extCount |= 0x80;
				}
				data.writeByte(extCount);
			}
		}

		public static function decodeDifference(originalData:ByteArray, difference:ByteArray):ByteArray
		{
			originalData.position = 0;
			difference.position = 0;
			
			var changedData:ByteArray = new ByteArray();
			var bytes:ByteArray = new ByteArray();
			
			while (difference.bytesAvailable > 0)
			{
				var control:int = difference.readUnsignedByte();
				var more:Boolean = (control & 0x80) != 0;
				var command:int = (control & 0x60) >> 5;
				var count:int = (control & 0x1F);
				
				var shift:int = 5;
				while (more)
				{
					control = difference.readUnsignedByte();
					var extCount:int = (control & 0x7F);
					more = (control & 0x80) != 0;
					
					count |= (extCount << shift);
					shift += 7;
				}
				
				switch (command)
				{
					case k_DIFF_CMD_COPY:
						originalData.readBytes(bytes, 0, count);
						changedData.writeBytes(bytes, 0, count);
						break;
					
					case k_DIFF_CMD_REPLACE:
						originalData.position += count;
						difference.readBytes(bytes, 0, count);
						changedData.writeBytes(bytes, 0, count);
						break;
					
					case k_DIFF_CMD_ADD:
						difference.readBytes(bytes, 0, count);
						changedData.writeBytes(bytes, 0, count);
						break;
					
					case k_DIFF_CMD_SKIP:
						originalData.position += count;
						break;
				}
			}
			
			changedData.position = 0;
			return changedData;
		}
		
		public static function byteArrayToArrayOfInts(byteArray:ByteArray):Array
		{
			var array:Array = new Array();
			byteArray.position = 0;
			while (byteArray.bytesAvailable > 0)
			{
				array.push(int(byteArray.readUnsignedByte()));
			}
			return array;
		}

	}
}