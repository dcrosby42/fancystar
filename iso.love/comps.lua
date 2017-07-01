local Comp = require 'ecs/component'

Comp.define("event", {'data',''})
Comp.define("tag", {})
Comp.define("timer", {'t',0, 'reset',0, 'countDown',true, 'loop',false, 'alarm',false})
Comp.define("output", {'kind',''})

Comp.define('script',{'scriptName','','on','call'})
-- Comp.define("debug", {'value',''})
--
-- Comp.define("label", {'text','Label', 'color', {0,0,0},'font',nil, 'width', nil, 'align',nilj, 'height',nil,'valign',nil})
-- Comp.define("circle", {'offx',0,'offy',0,'radius',0, 'color',{0,0,0}})
-- Comp.define("rect", {'offx',0,'offy',0,'w',0, 'h',0, 'color',{0,0,0}, 'style','fill'})
--
-- Comp.define("scale", {'sx',1,'sy',1})
-- Comp.define("pos", {'x',0,'y',0})
-- Comp.define("vel", {'dx',0,'dy',0})
-- Comp.define("bounds", {'offx',0,'offy',0,'w',0,'h',0})
-- Comp.define("img", {'imgId','','offx',0,'offy',0,'sx',1,'sy',1,'r',0,'color',{255,255,255}})
-- Comp.define("controller", {'id','','leftx',0,'lefty',0,})
-- Comp.define("player", {})
-- Comp.define("map",{'id',''})
-- Comp.define("collidable", {})

--
Comp.define("color",{'color',{255,255,255}})
Comp.define("isoworld", {})
Comp.define("isoDebug", {'on',false})
Comp.define("isoSprite", {'id','', 'picname','', 'dir','fl', 'action','stand'})
Comp.define("isoSpriteAnimated", {'timer',''})
Comp.define("isoPos", {'x',0,'y',0,'z',0})
Comp.define("isoSize", {'x',0,'y',0,'z',0})
