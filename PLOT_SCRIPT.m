%LOAD DATA FILE
%file = uigetfile();
%load(file);

%LOAD BEST_MODEL
%file=uigetfile();
%load(file);

%VECTORIZATION COMPONENTS
edge_pot = best_model.theta.edge_potentials;
graph = best_model.structure;
node = best_model.theta.node_potentials;
G = best_model.theta.G;

%take only lower triangular to make visualization more intuitive
%edge_pot = tril(edge_pot);
%graph = tril(graph);

%CAN DO G FOR SPECIFIC OR EDGE OVERALL
%G_on = getEdgePot(graph,G,4 )
%G_var = G_on;
%G_var = G_var+G_var';
G_var  = edge_pot;
[s,t,ed] = vectorize_model(graph,G_var);
%ed = transpose(ed);

%NOW WE MAKE GRAPHICAL MODEL
MODEL = digraph(s,t,ed);

%GRAPHING SETTINGS
Lwidths=1;
colorweight = MODEL.Edges.Weight/max(MODEL.Edges.Weight);

%MAKE NODE INTEGER-SCALED
node_norm = normalize(node,'range',[1 10]);
node_wt = round(node_norm);

figure
MDL = plot(MODEL,'XData',coords(:,1),'YData',coords(:,2),'ZData',coords(:,3),'LineWidth',1);
MDL.ShowArrows='off';
MDL.Marker='d';
MDL.EdgeCData = colorweight;
colorbar;
title('Conditional Random Fields');

for i = 1:length(node)
    highlight(MDL,i,'MarkerSize',node_wt(i));
end

%HIGHLIGHT SPECIFIC NODE-SEED

p33 = predecessors(MODEL,q);
s33 = successors(MODEL,q);
i33 = inedges(MODEL,q);
o33 = outedges(MODEL,q);
e33 = [o33;i33];

highlight(MDL,q,'NodeColor','m');
highlight(MDL,q,'Marker','s');
highlight(MDL,q,'MarkerSize',10);
highlight(MDL,p33,'NodeColor','red');
highlight(MDL,s33,'NodeColor','red');

edge_mat = zeros(numel(ed),1);
edge_mat(e33)=1;
edge_mat=transpose(edge_mat);
MDL.EdgeCData=MDL.EdgeCData.*edge_mat;
MDL.EdgeCData(MDL.EdgeCData==0)=NaN;

A1 = graph(1:81,1:81);
M1 = sum(sum(A1))/numel(A1);

A2 = graph(82:end,82:end);
M2 = sum(sum(A2))/numel(A2);

M11 = M1*100;
M22 = M2*100;

A3 = G_var(1:81,1:81);
M3 = sum(sum(A3))/numel(A3);

A4 = G_var(82:end,82:end);
M4 = sum(sum(A4))/numel(A4);

M33=M3*100;
M44 = M4*100;

M11,M22,M33,M44
