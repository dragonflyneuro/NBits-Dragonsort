function [] = addHotkeys(f)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Adds cool little hotkeys to breakout figures for easy zooming/panning
% 
% INPUT
% f = figure handle

mymenu = uimenu('Parent',f,'Label','Hot Keys');
uimenu('Parent',mymenu,'Label','ZoomIn','Accelerator','1','Callback',@(src,evt)zoom(f,'on'));
uimenu('Parent',mymenu,'Label','ZoomOut','Accelerator','2','Callback',@(src,evt)zoom(f,'out'));
uimenu('Parent',mymenu,'Label','Pan','Accelerator','3','Callback',@(src,evt)pan(f,'on'));
uimenu('Parent',mymenu,'Label','Pointer','Accelerator','4','Callback',@(src,evt)pointer());

end

function pointer(f)
%    allowes a hotkey for reverting back to pointer
zoom(f,'off')
pan(f,'off')
end