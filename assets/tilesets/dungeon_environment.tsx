<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.8" tiledversion="1.8.5" name="dungeon_environment" tilewidth="16" tileheight="16" tilecount="400" columns="21">
 <image source="RogueEnvironment16x16.png" width="336" height="256"/>
 <tile id="5" probability="0.9"/>
 <tile id="6" probability="0.1"/>
 <tile id="16">
  <objectgroup draworder="index" id="2">
   <object id="5" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="17">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="18">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="19" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="20" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="27" probability="0.1"/>
 <tile id="37">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="39">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="40" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="41" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="42" probability="0.95"/>
 <tile id="45" probability="0.05"/>
 <tile id="58">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="59">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="60">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="61" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="62" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="79">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="80">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="82" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="83" probability="0.1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="100">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="101">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="16" height="16"/>
  </objectgroup>
 </tile>
 <tile id="193">
  <objectgroup draworder="index" id="2">
   <object id="1" x="2" y="0" width="12" height="6"/>
  </objectgroup>
 </tile>
 <tile id="194">
  <objectgroup draworder="index" id="2">
   <object id="1" x="1" y="0" width="14" height="10"/>
  </objectgroup>
 </tile>
 <wangsets>
  <wangset name="blue-wall-blue-stone-floor" type="corner" tile="59">
   <wangcolor name="" color="#ff0000" tile="-1" probability="1"/>
   <wangtile tileid="5" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="6" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="16" wangid="0,1,0,0,0,1,0,1"/>
   <wangtile tileid="17" wangid="0,1,0,0,0,0,0,1"/>
   <wangtile tileid="18" wangid="0,1,0,1,0,0,0,1"/>
   <wangtile tileid="19" wangid="0,1,0,0,0,0,0,1"/>
   <wangtile tileid="20" wangid="0,0,0,1,0,1,0,0"/>
   <wangtile tileid="27" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="37" wangid="0,0,0,0,0,1,0,1"/>
   <wangtile tileid="39" wangid="0,1,0,1,0,0,0,0"/>
   <wangtile tileid="40" wangid="0,1,0,0,0,0,0,1"/>
   <wangtile tileid="41" wangid="0,0,0,1,0,1,0,0"/>
   <wangtile tileid="58" wangid="0,0,0,1,0,1,0,1"/>
   <wangtile tileid="59" wangid="0,0,0,1,0,1,0,0"/>
   <wangtile tileid="60" wangid="0,1,0,1,0,1,0,0"/>
   <wangtile tileid="61" wangid="0,0,0,0,0,1,0,1"/>
   <wangtile tileid="62" wangid="0,1,0,1,0,0,0,0"/>
   <wangtile tileid="79" wangid="0,0,0,0,0,0,0,1"/>
   <wangtile tileid="80" wangid="0,1,0,0,0,0,0,0"/>
   <wangtile tileid="82" wangid="0,0,0,0,0,1,0,1"/>
   <wangtile tileid="83" wangid="0,1,0,1,0,0,0,0"/>
   <wangtile tileid="100" wangid="0,0,0,0,0,1,0,0"/>
   <wangtile tileid="101" wangid="0,0,0,1,0,0,0,0"/>
  </wangset>
  <wangset name="broken-blue-stone-floor" type="corner" tile="126">
   <wangcolor name="" color="#ff0000" tile="-1" probability="1"/>
   <wangtile tileid="105" wangid="0,0,0,1,0,0,0,0"/>
   <wangtile tileid="106" wangid="0,0,0,1,0,1,0,0"/>
   <wangtile tileid="107" wangid="0,0,0,0,0,1,0,0"/>
   <wangtile tileid="108" wangid="0,1,0,0,0,1,0,1"/>
   <wangtile tileid="109" wangid="0,1,0,1,0,0,0,1"/>
   <wangtile tileid="126" wangid="0,1,0,1,0,0,0,0"/>
   <wangtile tileid="127" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="128" wangid="0,0,0,0,0,1,0,1"/>
   <wangtile tileid="129" wangid="0,0,0,1,0,1,0,1"/>
   <wangtile tileid="130" wangid="0,1,0,1,0,1,0,0"/>
   <wangtile tileid="147" wangid="0,1,0,0,0,0,0,0"/>
   <wangtile tileid="148" wangid="0,1,0,0,0,0,0,1"/>
   <wangtile tileid="149" wangid="0,0,0,0,0,0,0,1"/>
  </wangset>
 </wangsets>
</tileset>
