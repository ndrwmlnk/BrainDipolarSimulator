%%
addpath(cd) % make sure current folder is in the path
clc
load('scalp_bem_mesh_fullres.mat')

cfg.dip.pos     = [0,-40,20; 0,-20,0; 0,60,40; 0,50,0];
cfg.dip.mom     = [[0;0;1],[-1;0;1],[1;0;0],[0;1;0]];
cfg.dip.frequency = [6, 8, 24, 12];
cfg.dip.phase = [0,0,0,0];
cfg.dip.amplitude = [10,10,1,1];

cfg.triallength = 3;
cfg.fsample = 400;
cfg.ntrials = 1;
c = 1;

%---------------------------
cfg.triallength = 0.5;
cfg.dip.pos     = [0,50,0];
cfg.dip.mom     = [0;1;0];
cfg.dip.frequency = [12];
cfg.dip.phase = [0];
cfg.dip.amplitude = [1];
%---------------------------
% choose BEM implementation (OpenMEEG, bemcp or dipoli)
% cfg.method = 'openmeeg';
cfg.method = 'dipoli';

pnt = scalp_bem_mesh.vertices;
tri = scalp_bem_mesh.faces;

% sens.unit='mm';
sens.pnt = pnt;
sens.label = {};
nsens = size(sens.pnt,1);
for ii=1:nsens
    sens.label{ii} = sprintf('v%d', ii);
end

% vol.unit='mm';
vol = [];
vol.bnd.pnt = pnt;
vol.bnd.tri = tri;
vol.cond = c;
vol = ft_prepare_bemmodel(cfg, vol);

cfg.vol = vol;
cfg.grid.pos = sens.pnt;
cfg.elec = sens;
datestr(now,13)
data = ft_dipolesimulation(cfg);

figure('Position',[100 100 640 480]);
triplot(pnt, tri, data.trial{1}(:,1), 'surface');

absmax = max(abs([min(data.trial{1}) max(data.trial{1})]));
set(gca,'Visible','on','XDir','reverse','YDir','reverse','YGrid','on','Box','on','TickDir','in','NextPlot','add','CLim',[-absmax absmax]);
for i = 1:200 %size(data.trial{1},2)
    triplot(pnt, tri, data.trial{1}(:,i),'faces_skin'); % faces_skin
    plot3(pnt(r,1),pnt(r,2),pnt(r,3),'Color','black','Marker','.','LineStyle','none')
    view(-45+360*(i/200), 20);pause(0.001);
    if mod(i,50) == 0, fprintf('%d ',i);end
end
fprintf('\n')
