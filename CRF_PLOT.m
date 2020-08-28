%% CRF_PLOT

%import app data

%% ADDRESS OPTIONS


%% determine triangular
if app.TRL == 1
    app.graph = tril(app.results.best_model.structure);
    app.edge_pot = tril(app.results.best_model.theta.edge_potentials);
    %technically == but this works
elseif app.TRL == 0
   app.graph = app.results.best_model.structure;
    app.edge_pot = app.results.best_model.theta.edge_potentials;
end

%% determine edges
app.G = app.results.best_model.theta.G;
if app.EGS == 'All';
    [app.G_all] = getEdgePotAll(app.graph,app.G);
    if app.TRL == 0
        app.G_all = app.G_all + app.G_all';
    end
    [app.s,app.t,app.edge_wt] = vectorize_model(app.graph, app.G_all);   
    app.edge_wt = transpose(app.edge_wt);
elseif app.EGS == 'Phi 00'
     [app.G_off] = getEdgePot(app.graph,app.G,1);
    [app.s,app.t,app.G_00] = vectorize_model(app.graph, app.G_off);
    app.edge_wt = transpose(app.G_00);
elseif app.EGS == 'Phi 01'
     [app.G_ofo] = getEdgePot(app.graph,app.G,2);
    [app.s,app.t,app.G_01] = vectorize_model(app.graph, app.G_ofo);
    app.edge_wt = transpose(app.G_01);
elseif app.EGS == 'Phi 10'
    [app.G_oof] = getEdgePot(app.graph,app.G,3);
    [app.s,app.t,app.G_10] = vectorize_model(app.graph, app.G_oof);
    app.edge_wt = transpose(app.G_10);
elseif app.EGS == 'Phi 11'
    [app.G_on] = getEdgePot(app.graph,app.G,4);
    [app.s,app.t,app.G_11] = vectorize_model(app.graph, app.G_on);
    app.edge_wt = transpose(app.G_11);
end

if app.NORM == 1
    app.edge_wt = normalize(app.edge_wt, 'range');
end
%% determine threshold
if app.THR > 0
    [app.edge_wt] = threshold_edge_weights2(app.edge_wt,app.THR);
end

%% create model
app.MODEL = digraph(app.s,app.t,app.edge_wt);

%% determine weights

if app.WT == 'None'
    app.LWidths = 1;
    app.colorweight(1,1:length(app.edge_wt))=1;
    
elseif app.WT == 'Line Widths'
    app.LWidths = 5*app.MODEL.Edges.Weight/max(app.MODEL.Edges.Weight);
    app.colorweight(1,1:length(app.edge_wt))=1
elseif app.WT == 'Color Weights'
    app.LWidths = 5;
    app.colorweight = app.MODEL.Edges.Weight/max(app.MODEL.Edges.Weight);
end

%% determine node size
%unclear

%% plot CRF

figure
MDL = plot(app.MODEL, 'LineWidth', app.LWidths, 'Layout', app.layout);
MDL.ShowArrows = 'off';
MDL.Marker = 's';
MDL.NodeColor = 'k';
colormap winter
MDL.EdgeCData = colorweight;

if app.WT == 'Color Weights'
    colorbar
end

title('Conditional Random Field Model of Ensemble Activity')
