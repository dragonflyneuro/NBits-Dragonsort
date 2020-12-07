% clc
% figure(1);
% clf(figure(1));
% ax = axes;
% tic
% p = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves(1:2:end,:)');
% drawnow
% toc
% hold(ax,'on');
% 
% tic
% temp = [p; line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves(2:2:end,:)')];
% p = temp;
% drawnow
% toc
% 
% tic
% delete(p(1:round(length(p)/2)));
% p(1:round(length(p)/2)) = [];
% drawnow
% toc
% 
% tic
% temp = [p; line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves(1:2:end,:)')];
% p = temp;
% drawnow
% toc

disp("hi")
figure(1);
clf(figure(1));
ax = axes;
tic
p = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves');
[p(2:2:end).Visible] = deal('off');
drawnow
toc
hold(ax,'on');

tic
[p(2:2:end).Visible] = deal('on');
drawnow
toc

tic
[p(1:2:end).Visible] = deal('off');
drawnow
toc

tic
[p(1:2:end).Visible] = deal('on');
drawnow
toc

disp("hi")
figure(2);
clf(figure(2));
ax = axes;
tic
p = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves');
for ii = p(2:2:end)'
    ii.Visible = 'off';
end
drawnow
toc
hold(ax,'on');

tic
for ii = p(2:2:end)'
    ii.Visible = 'on';
end
drawnow
toc

tic
for ii = p(1:2:end)'
    ii.Visible = 'off';
end
drawnow
toc

tic
for ii = p(1:2:end)'
    ii.Visible = 'on';
end
drawnow
toc

% disp("hi")
% figure(3);
% clf(figure(3));
% ax = axes;
% tic
% p = line(ax, -floor(size(waves,2)/2):floor(size(waves,2)/2), waves');
% [p(2:2:end).LineStyle] = deal('none');
% drawnow
% toc
% hold(ax,'on');
% 
% tic
% [p(2:2:end).LineStyle] = deal('-');
% drawnow
% toc
% 
% tic
% [p(1:2:end).LineStyle] = deal('none');
% drawnow
% toc
% 
% tic
% [p(1:2:end).LineStyle] = deal('-');
% drawnow
% toc